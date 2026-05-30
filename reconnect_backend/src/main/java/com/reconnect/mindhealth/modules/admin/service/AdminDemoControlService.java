package com.reconnect.mindhealth.modules.admin.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.admin.dto.AdminDemoControlResultDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;
import com.reconnect.mindhealth.modules.risk.repository.DailyRiskLogRepository;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AdminDemoControlService {

    private static final Logger log = LoggerFactory.getLogger(AdminDemoControlService.class);

    private final PatientProfileRepository patientProfileRepository;
    private final DailyRiskLogRepository dailyRiskLogRepository;
    private final RoadmapDailyAssignmentService roadmapDailyAssignmentService;

    public AdminDemoControlService(
            PatientProfileRepository patientProfileRepository,
            DailyRiskLogRepository dailyRiskLogRepository,
            RoadmapDailyAssignmentService roadmapDailyAssignmentService) {
        this.patientProfileRepository = patientProfileRepository;
        this.dailyRiskLogRepository = dailyRiskLogRepository;
        this.roadmapDailyAssignmentService = roadmapDailyAssignmentService;
    }

    @Transactional
    public AdminDemoControlResultDto unlockPhq9(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setLastPhq9Date(null);
        patientProfileRepository.save(patient);
        log.info("Admin demo control unlock PHQ-9 adminId={}, patientId={}", adminId, patientId);
        return new AdminDemoControlResultDto(patientId, "UNLOCK_PHQ9",
                "Đã mở khóa PHQ-9. Bệnh nhân có thể vào app để làm lại bài đánh giá.");
    }

    @Transactional
    public AdminDemoControlResultDto triggerPhq9(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setLastPhq9Date(null);
        patientProfileRepository.save(patient);
        log.info("Admin demo control trigger PHQ-9 adminId={}, patientId={}", adminId, patientId);
        return new AdminDemoControlResultDto(patientId, "TRIGGER_PHQ9",
                "Đã kích hoạt PHQ-9 đột xuất cho demo. Bệnh nhân có thể làm ngay trên app.");
    }

    public AdminDemoControlResultDto runDailyRoadmap(UUID patientId, LocalDate date, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        LocalDate effectiveDate = date != null ? date : LocalDate.now();
        List<PatientQuest> created = roadmapDailyAssignmentService.ensureDailySystemQuests(patient, effectiveDate);
        AdminDemoControlResultDto result = new AdminDemoControlResultDto(patientId, "RUN_DAILY_ROADMAP",
                created.isEmpty()
                        ? "Bệnh nhân đã có bài CBT hệ thống trong ngày, không tạo trùng."
                        : "Đã tạo bài CBT hệ thống cho hôm nay.");
        result.setCreatedQuests(created.size());
        log.info("Admin demo control run daily roadmap adminId={}, patientId={}, date={}, created={}",
                adminId, patientId, effectiveDate, created.size());
        return result;
    }

    @Transactional
    public AdminDemoControlResultDto setRisk(UUID patientId, int score, boolean redFlag, UUID adminId) {
        int normalizedScore = Math.max(0, Math.min(score, 100));
        PatientProfile patient = getPatient(patientId);
        patient.setCurrentRiskScore(normalizedScore);
        patient.setIsRedFlagActive(redFlag);
        patientProfileRepository.save(patient);

        DailyRiskLog riskLog = dailyRiskLogRepository.findByPatientProfile_IdAndRiskDate(patientId, LocalDate.now())
                .orElseGet(DailyRiskLog::new);
        riskLog.setPatientProfile(patient);
        riskLog.setRiskDate(LocalDate.now());
        riskLog.setRiskScore(normalizedScore);
        riskLog.setScorePhq9(normalizedScore);
        riskLog.setScoreAi(0);
        riskLog.setScoreMood(0);
        riskLog.setOverrideTriggered(redFlag || normalizedScore >= 70);
        riskLog.setRedFlagActive(redFlag);
        riskLog.setCalculatedAt(LocalDateTime.now());
        dailyRiskLogRepository.save(riskLog);

        AdminDemoControlResultDto result = new AdminDemoControlResultDto(patientId, "SET_RISK",
                "Đã cập nhật risk/red flag demo cho bệnh nhân.");
        result.setCurrentRiskScore(normalizedScore);
        result.setRedFlagActive(redFlag);
        log.info("Admin demo control set risk adminId={}, patientId={}, score={}, redFlag={}",
                adminId, patientId, normalizedScore, redFlag);
        return result;
    }

    @Transactional
    public AdminDemoControlResultDto clearRisk(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setCurrentRiskScore(0);
        patient.setIsRedFlagActive(false);
        patientProfileRepository.save(patient);

        DailyRiskLog riskLog = dailyRiskLogRepository.findByPatientProfile_IdAndRiskDate(patientId, LocalDate.now())
                .orElseGet(DailyRiskLog::new);
        riskLog.setPatientProfile(patient);
        riskLog.setRiskDate(LocalDate.now());
        riskLog.setRiskScore(0);
        riskLog.setScorePhq9(0);
        riskLog.setScoreAi(0);
        riskLog.setScoreMood(0);
        riskLog.setOverrideTriggered(false);
        riskLog.setRedFlagActive(false);
        riskLog.setCalculatedAt(LocalDateTime.now());
        dailyRiskLogRepository.save(riskLog);

        AdminDemoControlResultDto result = new AdminDemoControlResultDto(patientId, "CLEAR_RISK",
                "Đã tắt cảnh báo risk/red flag demo.");
        result.setCurrentRiskScore(0);
        result.setRedFlagActive(false);
        log.info("Admin demo control clear risk adminId={}, patientId={}", adminId, patientId);
        return result;
    }

    @Transactional
    public AdminDemoControlResultDto resetGraduation(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setGraduatedAt(null);
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);
        log.info("Admin demo control reset graduation adminId={}, patientId={}", adminId, patientId);
        return new AdminDemoControlResultDto(patientId, "RESET_GRADUATION",
                "Đã reset trạng thái tốt nghiệp. Bệnh nhân quay lại luồng đang điều trị.");
    }

    private PatientProfile getPatient(UUID patientId) {
        return patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ bệnh nhân: " + patientId));
    }
}
