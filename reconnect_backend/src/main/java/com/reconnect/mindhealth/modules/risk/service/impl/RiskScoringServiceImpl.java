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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.assessment.entity.Phq9Submission;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.repository.Phq9Repository;
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

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private Phq9Repository phq9Repository;

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private UserMoodRepository userMoodRepository;

    @Autowired
    private DailyRiskLogRepository dailyRiskLogRepository;

    @Override
    public RiskCalculationResultDto calculateAndPersist(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }

        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));

        RiskCalculationResultDto result = calculateRisk(patientId);

        patient.setCurrentRiskScore(result.getRiskIndex());
        if (result.getRiskIndex() >= RED_FLAG_THRESHOLD) {
            patient.setIsRedFlagActive(true);
            patient.setStatus(Status.WARNING);
        }
        PatientProfile savedPatient = patientProfileRepository.save(patient);
        persistDailyRiskLog(savedPatient, result);

        return result;
    }

    @Override
    public int calculateAndPersistForAllActivePatients() {
        List<PatientProfile> active = patientProfileRepository.findByIsActiveTrue();
        int count = 0;
        for (PatientProfile p : active) {
            try {
                calculateAndPersist(p.getId());
                count++;
            } catch (Exception e) {
                log.error("Risk scoring failed for patient {}", p.getId(), e);
            }
        }
        return count;
    }

    private void persistDailyRiskLog(PatientProfile patient, RiskCalculationResultDto result) {
        LocalDate today = LocalDate.now(ZoneId.of("Asia/Bangkok"));
        DailyRiskLog log = dailyRiskLogRepository
                .findByPatientProfile_IdAndRiskDate(patient.getId(), today)
                .orElseGet(DailyRiskLog::new);

        log.setPatientProfile(patient);
        log.setRiskDate(today);
        log.setRiskScore(result.getRiskIndex());
        log.setScorePhq9(result.getScorePhq9());
        log.setScoreAi(result.getScoreAi());
        log.setScoreMood(result.getScoreMood());
        log.setOverrideTriggered(result.isOverrideTriggered());
        log.setRedFlagActive(Boolean.TRUE.equals(patient.getIsRedFlagActive()));
        log.setCalculatedAt(LocalDateTime.now());
        dailyRiskLogRepository.save(log);
    }

    private RiskCalculationResultDto calculateRisk(UUID patientId) {
        LocalDate today = LocalDate.now(ZoneId.systemDefault());
        Date startOfDay = Date.from(today.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date endOfDay = Date.from(today.atTime(LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant());

        // Latest PHQ-9
        Phq9Submission lastPhq9 = phq9Repository.findTopByPatientProfile_IdOrderByCreateDateDesc(patientId);
        int q9Score = lastPhq9 != null && lastPhq9.getQ9Score() != null ? lastPhq9.getQ9Score() : 0;

        // Override: Q9>0 OR AI life-threat keyword today (aiRiskScore=100)
        int maxAiToday = journalRepository.getMaxAiRiskScoreInDay(patientId, startOfDay, endOfDay);
        boolean override = q9Score > 0 || maxAiToday >= 100;

        RiskCalculationResultDto dto = new RiskCalculationResultDto();
        dto.setPatientId(patientId);
        dto.setOverrideTriggered(override);

        if (override) {
            dto.setRiskIndex(100);
            dto.setScorePhq9(100);
            dto.setScoreAi(100);
            dto.setScoreMood(0);
            return dto;
        }

        int scorePhq9 = calculatePhq9Score(lastPhq9);
        int scoreAi = maxAiToday >= 70 ? 70 : 0;
        int scoreMood = calculateMoodScore(patientId);

        double risk = (0.4 * scorePhq9) + (0.4 * scoreAi) + (0.2 * scoreMood);
        int riskIndex = (int) Math.round(risk);

        dto.setScorePhq9(scorePhq9);
        dto.setScoreAi(scoreAi);
        dto.setScoreMood(scoreMood);
        dto.setRiskIndex(riskIndex);
        return dto;
    }

    private int calculatePhq9Score(Phq9Submission lastPhq9) {
        if (lastPhq9 == null) {
            return 0;
        }
        int q9 = lastPhq9.getQ9Score() != null ? lastPhq9.getQ9Score() : 0;
        int q2 = lastPhq9.getQ2Score() != null ? lastPhq9.getQ2Score() : 0;

        if (q9 > 0) {
            return 100;
        }
        if (q9 == 0 && q2 == 3) {
            return 70;
        }
        return 0;
    }

    private int calculateMoodScore(UUID patientId) {
        List<UserMood> last3 = userMoodRepository.findTop3ByPatientProfile_IdOrderByCreateDateDesc(patientId);
        if (last3 == null || last3.size() < 3) {
            return 100; // no check-in 3 days -> treat as avg=0
        }
        int sum = 0;
        for (UserMood m : last3) {
            sum += m.getMoodScore() != null ? m.getMoodScore() : 0;
        }
        double avg = sum / 3.0;
        if (avg < 20.0) {
            return 100;
        }
        if (avg < 35.0) {
            return 50;
        }
        return 0;
    }
}
