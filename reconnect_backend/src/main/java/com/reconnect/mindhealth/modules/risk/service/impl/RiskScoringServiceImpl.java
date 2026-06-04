package com.reconnect.mindhealth.modules.risk.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.journal.repository.JournalRepository;
import com.reconnect.mindhealth.modules.risk.dto.RiskCalculationResultDto;
import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;
import com.reconnect.mindhealth.modules.risk.repository.DailyRiskLogRepository;
import com.reconnect.mindhealth.modules.risk.service.IRiskScoringService;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class RiskScoringServiceImpl implements IRiskScoringService {

    private static final Logger log = LoggerFactory.getLogger(RiskScoringServiceImpl.class);
    private static final int RED_FLAG_THRESHOLD = 70;

    private final PatientProfileRepository patientProfileRepository;
    private final JournalRepository journalRepository;
    private final UserMoodRepository userMoodRepository;
    private final DailyRiskLogRepository dailyRiskLogRepository;

    public RiskScoringServiceImpl(
            PatientProfileRepository patientProfileRepository,
            JournalRepository journalRepository,
            UserMoodRepository userMoodRepository,
            DailyRiskLogRepository dailyRiskLogRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.journalRepository = journalRepository;
        this.userMoodRepository = userMoodRepository;
        this.dailyRiskLogRepository = dailyRiskLogRepository;
    }

    @Override
    public RiskCalculationResultDto calculateAndPersist(UUID patientId) {
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
        RiskCalculationResultDto result = calculateRisk(patientId);
        patient.setCurrentRiskScore(result.getRiskIndex());
        if (result.getRiskIndex() >= RED_FLAG_THRESHOLD) {
            patient.setIsRedFlagActive(true);
            patient.setStatus(Status.WARNING);
        }
        PatientProfile saved = patientProfileRepository.save(patient);
        persistDailyRiskLog(saved, result);
        return result;
    }

    @Override
    public int calculateAndPersistForAllActivePatients() {
        int count = 0;
        for (PatientProfile patient : patientProfileRepository.findByIsActiveTrue()) {
            try {
                calculateAndPersist(patient.getId());
                count++;
            } catch (Exception e) {
                log.warn("Risk scoring failed patientId={}, reason={}", patient.getId(), e.getMessage());
            }
        }
        return count;
    }

    private RiskCalculationResultDto calculateRisk(UUID patientId) {
        LocalDate today = LocalDate.now(ZoneId.systemDefault());
        Date startOfDay = Date.from(today.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date endOfDay = Date.from(today.atTime(LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant());

        int maxAiToday = journalRepository.getMaxAiRiskScoreInDay(patientId, startOfDay, endOfDay);
        int scoreAi = maxAiToday >= 100 ? 100 : (maxAiToday >= 70 ? 70 : 0);
        int scoreMood = calculateMoodScore(patientId);
        int scoreSafety = scoreAi >= 100 ? 100 : 0;

        boolean override = scoreAi >= 70 || scoreSafety >= 70;
        int riskIndex;
        if (scoreAi >= 100 || scoreSafety >= 100) {
            riskIndex = 100;
        } else if (scoreAi >= 70) {
            riskIndex = 70;
        } else {
            riskIndex = (int) Math.round((0.6 * scoreAi) + (0.3 * scoreMood) + (0.1 * scoreSafety));
        }

        RiskCalculationResultDto dto = new RiskCalculationResultDto();
        dto.setPatientId(patientId);
        dto.setScoreAi(scoreAi);
        dto.setScoreMood(scoreMood);
        dto.setScoreSafety(scoreSafety);
        dto.setRiskIndex(riskIndex);
        dto.setOverrideTriggered(override);
        return dto;
    }

    private void persistDailyRiskLog(PatientProfile patient, RiskCalculationResultDto result) {
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Bangkok"));
        DailyRiskLog dailyLog = dailyRiskLogRepository
                .findByPatientProfile_IdAndRiskDate(patient.getId(), today)
                .orElseGet(DailyRiskLog::new);
        dailyLog.setPatientProfile(patient);
        dailyLog.setRiskDate(today);
        dailyLog.setRiskScore(result.getRiskIndex());
        dailyLog.setScoreAi(result.getScoreAi());
        dailyLog.setScoreMood(result.getScoreMood());
        dailyLog.setScoreSafety(result.getScoreSafety());
        dailyLog.setOverrideTriggered(result.isOverrideTriggered());
        dailyLog.setRedFlagActive(Boolean.TRUE.equals(patient.getIsRedFlagActive()));
        dailyLog.setCalculatedAt(LocalDateTime.now());
        dailyRiskLogRepository.save(dailyLog);
    }

    private int calculateMoodScore(UUID patientId) {
        List<UserMood> last3 = userMoodRepository.findTop3ByPatientProfile_IdOrderByCreateDateDesc(patientId);
        if (last3 == null || last3.size() < 3) {
            return 0;
        }
        double average = last3.stream()
                .mapToInt(mood -> mood.getMoodScore() != null ? mood.getMoodScore() : 0)
                .average()
                .orElse(100);
        if (average < 20) {
            return 100;
        }
        if (average < 35) {
            return 50;
        }
        return 0;
    }
}
