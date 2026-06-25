package com.reconnect.mindhealth.modules.risk.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import com.reconnect.mindhealth.modules.journal.repository.JournalRepository;
import com.reconnect.mindhealth.modules.risk.dto.TherapistPatientRiskAnalyticsDto;
import com.reconnect.mindhealth.modules.risk.dto.TherapistPatientRiskPointDto;
import com.reconnect.mindhealth.modules.risk.service.TherapistRiskAnalyticsService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class TherapistRiskAnalyticsServiceImpl implements TherapistRiskAnalyticsService {

    private static final int DEFAULT_DAYS = 14;
    private static final int MAX_DAYS = 90;
    private static final int TREND_THRESHOLD = 5;

    private final PatientProfileRepository patientProfileRepository;
    private final UserMoodRepository userMoodRepository;
    private final JournalRepository journalRepository;

    public TherapistRiskAnalyticsServiceImpl(
            PatientProfileRepository patientProfileRepository,
            UserMoodRepository userMoodRepository,
            JournalRepository journalRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.userMoodRepository = userMoodRepository;
        this.journalRepository = journalRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public TherapistPatientRiskAnalyticsDto getPatientRiskAnalytics(User therapistUser, UUID patientId, int days) {
        int safeDays = normalizeDays(days);
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
        if (patient.getTherapist() == null || !patient.getTherapist().getId().equals(therapistUser.getId())) {
            throw new SecurityException("Bạn chỉ được xem analytics của bệnh nhân đang phụ trách.");
        }

        LocalDate to = LocalDate.now();
        LocalDate from = to.minusDays(safeDays - 1L);
        Date startDate = Date.from(from.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date endDate = Date.from(to.atTime(LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant());

        List<UserMood> moods = userMoodRepository
                .findByPatientProfile_IdAndCreateDateBetweenOrderByCreateDateAsc(patientId, startDate, endDate);
        List<Journal> journals = journalRepository
                .findByPatientProfile_IdAndCreateDateBetweenOrderByCreateDateAsc(patientId, startDate, endDate);

        List<TherapistPatientRiskPointDto> points = buildDailyPoints(moods, journals, from, to);

        TherapistPatientRiskAnalyticsDto dto = new TherapistPatientRiskAnalyticsDto();
        dto.setPatientId(patientId);
        dto.setDays(safeDays);
        dto.setPoints(points);
        dto.setRedFlagDays(points.stream().filter(point -> Boolean.TRUE.equals(point.getRedFlagActive())).count());
        dto.setTrend(calculateTrend(points));

        if (!points.isEmpty()) {
            TherapistPatientRiskPointDto latest = points.get(points.size() - 1);
            dto.setLatestRiskScore(latest.getRiskScore());
            dto.setLatestRedFlagActive(latest.getRedFlagActive());
            dto.setMaxRiskScore(points.stream()
                    .map(TherapistPatientRiskPointDto::getRiskScore)
                    .max(Comparator.naturalOrder())
                    .orElse(null));
            double average = points.stream()
                    .map(TherapistPatientRiskPointDto::getRiskScore)
                    .filter(score -> score != null)
                    .mapToInt(Integer::intValue)
                    .average()
                    .orElse(0);
            dto.setAverageRiskScore(Math.round(average * 10.0) / 10.0);
        } else {
            dto.setLatestRiskScore(patient.getCurrentRiskScore());
            dto.setLatestRedFlagActive(patient.getIsRedFlagActive());
            dto.setMaxRiskScore(patient.getCurrentRiskScore());
            dto.setAverageRiskScore(null);
        }
        return dto;
    }

    private List<TherapistPatientRiskPointDto> buildDailyPoints(
            List<UserMood> moods,
            List<Journal> journals,
            LocalDate from,
            LocalDate to) {
        Map<LocalDate, DailyRiskAggregate> aggregateByDay = new TreeMap<>();

        LocalDate cursor = from;
        while (!cursor.isAfter(to)) {
            aggregateByDay.put(cursor, new DailyRiskAggregate(cursor));
            cursor = cursor.plusDays(1);
        }

        for (UserMood mood : moods) {
            LocalDate date = resolveDate(mood.getCreateDate());
            DailyRiskAggregate aggregate = aggregateByDay.get(date);
            if (aggregate == null) {
                continue;
            }
            aggregate.scoreMood = Math.max(
                    aggregate.scoreMood,
                    max(
                            mood.getAnxietyScore(),
                            mood.getSadnessScore(),
                            mood.getAvoidanceUrgeScore()));
            if ("UNSAFE".equalsIgnoreCase(mood.getSafetyResponse())) {
                aggregate.scoreSafety = 100;
            }
        }

        for (Journal journal : journals) {
            LocalDate date = resolveDate(journal.getCreateDate());
            DailyRiskAggregate aggregate = aggregateByDay.get(date);
            if (aggregate == null) {
                continue;
            }
            aggregate.scoreAi = Math.max(aggregate.scoreAi, safeInt(journal.getAiRiskScore()));
        }

        List<TherapistPatientRiskPointDto> points = new ArrayList<>();
        for (DailyRiskAggregate aggregate : aggregateByDay.values()) {
            aggregate.finalizeScores();
            if (aggregate.hasSignal()) {
                points.add(new TherapistPatientRiskPointDto(
                        aggregate.riskDate,
                        aggregate.riskScore,
                        aggregate.scoreSafety,
                        aggregate.scoreAi,
                        aggregate.scoreMood,
                        aggregate.overrideTriggered,
                        aggregate.redFlagActive));
            }
        }
        return points;
    }

    private int normalizeDays(int days) {
        if (days <= 0) {
            return DEFAULT_DAYS;
        }
        return Math.min(days, MAX_DAYS);
    }

    private String calculateTrend(List<TherapistPatientRiskPointDto> points) {
        if (points.size() < 2) {
            return "NO_DATA";
        }
        int delta = safeInt(points.get(points.size() - 1).getRiskScore()) - safeInt(points.get(0).getRiskScore());
        if (delta >= TREND_THRESHOLD) {
            return "UP";
        }
        if (delta <= -TREND_THRESHOLD) {
            return "DOWN";
        }
        return "STABLE";
    }

    private LocalDate resolveDate(Date value) {
        if (value == null) {
            return LocalDate.now();
        }
        return LocalDateTime.ofInstant(value.toInstant(), ZoneId.systemDefault()).toLocalDate();
    }

    private int max(Integer... values) {
        int out = 0;
        for (Integer value : values) {
            out = Math.max(out, safeInt(value));
        }
        return out;
    }

    private int safeInt(Integer value) {
        return value != null ? value : 0;
    }

    private static final class DailyRiskAggregate {
        private final LocalDate riskDate;
        private int riskScore;
        private int scoreSafety;
        private int scoreAi;
        private int scoreMood;
        private boolean overrideTriggered;
        private boolean redFlagActive;

        private DailyRiskAggregate(LocalDate riskDate) {
            this.riskDate = riskDate;
        }

        private void finalizeScores() {
            if (scoreSafety >= 100) {
                riskScore = 100;
            } else if (scoreAi >= 100) {
                riskScore = 100;
            } else if (scoreAi >= 70) {
                riskScore = 70;
            } else {
                riskScore = 0;
            }
            overrideTriggered = riskScore >= 70;
            redFlagActive = riskScore >= 70;
        }

        private boolean hasSignal() {
            return riskScore > 0 || scoreSafety > 0 || scoreAi > 0 || scoreMood > 0;
        }
    }
}
