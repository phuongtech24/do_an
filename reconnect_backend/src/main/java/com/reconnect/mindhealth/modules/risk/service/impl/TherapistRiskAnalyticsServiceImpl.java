package com.reconnect.mindhealth.modules.risk.service.impl;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.risk.dto.TherapistPatientRiskAnalyticsDto;
import com.reconnect.mindhealth.modules.risk.dto.TherapistPatientRiskPointDto;
import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;
import com.reconnect.mindhealth.modules.risk.repository.DailyRiskLogRepository;
import com.reconnect.mindhealth.modules.risk.service.TherapistRiskAnalyticsService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class TherapistRiskAnalyticsServiceImpl implements TherapistRiskAnalyticsService {

    private static final int DEFAULT_DAYS = 14;
    private static final int MAX_DAYS = 90;
    private static final int TREND_THRESHOLD = 5;

    private final PatientProfileRepository patientProfileRepository;
    private final DailyRiskLogRepository dailyRiskLogRepository;

    public TherapistRiskAnalyticsServiceImpl(
            PatientProfileRepository patientProfileRepository,
            DailyRiskLogRepository dailyRiskLogRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.dailyRiskLogRepository = dailyRiskLogRepository;
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
        List<DailyRiskLog> logs = dailyRiskLogRepository
                .findByPatientProfile_IdAndRiskDateBetweenOrderByRiskDateAsc(patientId, from, to);

        TherapistPatientRiskAnalyticsDto dto = new TherapistPatientRiskAnalyticsDto();
        dto.setPatientId(patientId);
        dto.setDays(safeDays);
        dto.setPoints(logs.stream().map(TherapistPatientRiskPointDto::new).toList());
        dto.setRedFlagDays(logs.stream().filter(log -> Boolean.TRUE.equals(log.getRedFlagActive())).count());
        dto.setTrend(calculateTrend(logs));

        if (!logs.isEmpty()) {
            DailyRiskLog latest = logs.get(logs.size() - 1);
            dto.setLatestRiskScore(latest.getRiskScore());
            dto.setLatestRedFlagActive(latest.getRedFlagActive());
            dto.setMaxRiskScore(logs.stream()
                    .map(DailyRiskLog::getRiskScore)
                    .max(Comparator.naturalOrder())
                    .orElse(null));
            double average = logs.stream().mapToInt(DailyRiskLog::getRiskScore).average().orElse(0);
            dto.setAverageRiskScore(Math.round(average * 10.0) / 10.0);
        } else {
            dto.setLatestRiskScore(patient.getCurrentRiskScore());
            dto.setLatestRedFlagActive(patient.getIsRedFlagActive());
            dto.setMaxRiskScore(patient.getCurrentRiskScore());
            dto.setAverageRiskScore(null);
        }
        return dto;
    }

    private int normalizeDays(int days) {
        if (days <= 0) {
            return DEFAULT_DAYS;
        }
        return Math.min(days, MAX_DAYS);
    }

    private String calculateTrend(List<DailyRiskLog> logs) {
        if (logs.size() < 2) {
            return "NO_DATA";
        }
        int delta = logs.get(logs.size() - 1).getRiskScore() - logs.get(0).getRiskScore();
        if (delta >= TREND_THRESHOLD) {
            return "UP";
        }
        if (delta <= -TREND_THRESHOLD) {
            return "DOWN";
        }
        return "STABLE";
    }
}
