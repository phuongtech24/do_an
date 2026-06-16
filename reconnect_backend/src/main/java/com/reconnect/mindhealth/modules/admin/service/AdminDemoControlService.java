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
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentStatus;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.service.ClinicalTriageService;
import com.reconnect.mindhealth.modules.journal.dto.JournalDto;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;
import com.reconnect.mindhealth.modules.journal.service.IJournalService;
import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;
import com.reconnect.mindhealth.modules.risk.repository.DailyRiskLogRepository;
import com.reconnect.mindhealth.modules.roadmap.entity.FearLadderItem;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.BehavioralExperimentRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.FearLadderItemRepository;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapProgramStateService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AdminDemoControlService {

    private static final Logger log = LoggerFactory.getLogger(AdminDemoControlService.class);

    private final PatientProfileRepository patientProfileRepository;
    private final DailyRiskLogRepository dailyRiskLogRepository;
    private final RoadmapDailyAssignmentService roadmapDailyAssignmentService;
    private final UserMoodRepository userMoodRepository;
    private final IJournalService journalService;
    private final AppointmentRepository appointmentRepository;
    private final ClinicalTriageService clinicalTriageService;
    private final FearLadderItemRepository fearLadderItemRepository;
    private final BehavioralExperimentRepository behavioralExperimentRepository;
    private final RoadmapProgramStateService roadmapProgramStateService;

    public AdminDemoControlService(
            PatientProfileRepository patientProfileRepository,
            DailyRiskLogRepository dailyRiskLogRepository,
            RoadmapDailyAssignmentService roadmapDailyAssignmentService,
            UserMoodRepository userMoodRepository,
            IJournalService journalService,
            AppointmentRepository appointmentRepository,
            ClinicalTriageService clinicalTriageService,
            FearLadderItemRepository fearLadderItemRepository,
            BehavioralExperimentRepository behavioralExperimentRepository,
            RoadmapProgramStateService roadmapProgramStateService) {
        this.patientProfileRepository = patientProfileRepository;
        this.dailyRiskLogRepository = dailyRiskLogRepository;
        this.roadmapDailyAssignmentService = roadmapDailyAssignmentService;
        this.userMoodRepository = userMoodRepository;
        this.journalService = journalService;
        this.appointmentRepository = appointmentRepository;
        this.clinicalTriageService = clinicalTriageService;
        this.fearLadderItemRepository = fearLadderItemRepository;
        this.behavioralExperimentRepository = behavioralExperimentRepository;
        this.roadmapProgramStateService = roadmapProgramStateService;
    }

    @Transactional
    public AdminDemoControlResultDto unlockLsas(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setLastLsasDate(null);
        patientProfileRepository.save(patient);
        log.info("Admin demo control unlock LSAS adminId={}, patientId={}", adminId, patientId);
        return snapshot(
                patient,
                "UNLOCK_LSAS",
                "Đã mở khóa LSAS/re-rating. Bệnh nhân có thể vào app để làm lại đánh giá.");
    }

    @Transactional
    public AdminDemoControlResultDto triggerLsas(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setLastLsasDate(null);
        patientProfileRepository.save(patient);
        log.info("Admin demo control trigger LSAS adminId={}, patientId={}", adminId, patientId);
        return snapshot(
                patient,
                "TRIGGER_LSAS",
                "Đã kích hoạt LSAS/re-rating đột xuất cho demo. Bệnh nhân có thể làm ngay trên app.");
    }

    @Transactional
    public AdminDemoControlResultDto runDailyRoadmap(UUID patientId, LocalDate date, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        LocalDate effectiveDate = date != null ? date : LocalDate.now();
        List<PatientQuest> created = roadmapDailyAssignmentService.ensureDailySystemQuests(patient, effectiveDate);
        AdminDemoControlResultDto result = snapshot(
                patient,
                "RUN_DAILY_ROADMAP",
                created.isEmpty()
                        ? "Bệnh nhân đã có bài hệ thống trong ngày, không tạo trùng."
                        : "Đã tạo bài hệ thống cho hôm nay.");
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
        patient.setStatus(redFlag ? Status.WARNING : Status.STABLE);
        if (!redFlag) {
            patient.setTriageRequired(false);
            patient.setTriageStatus(null);
            patient.setTriagePriority(null);
        }
        patientProfileRepository.save(patient);
        upsertRiskLog(patient);

        log.info("Admin demo control set risk adminId={}, patientId={}, score={}, redFlag={}",
                adminId, patientId, normalizedScore, redFlag);
        return snapshot(patient, "SET_RISK", "Đã cập nhật risk/red flag demo cho bệnh nhân.");
    }

    @Transactional
    public AdminDemoControlResultDto clearRisk(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setCurrentRiskScore(0);
        patient.setIsRedFlagActive(false);
        patient.setStatus(Status.STABLE);
        patient.setTriageRequired(false);
        patient.setTriageStatus(null);
        patient.setTriagePriority(null);
        patientProfileRepository.save(patient);
        upsertRiskLog(patient);

        log.info("Admin demo control clear risk adminId={}, patientId={}", adminId, patientId);
        return snapshot(patient, "CLEAR_RISK", "Đã tắt cảnh báo risk/red flag demo.");
    }

    @Transactional
    public AdminDemoControlResultDto setLsasBand(UUID patientId, String band, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        String normalizedBand = band == null ? "" : band.trim().toUpperCase();
        int score = switch (normalizedBand) {
            case "REASSURANCE", "LOW", "UNDER_30" -> 18;
            case "SELF_HELP", "MILD", "BETWEEN_30_59" -> 45;
            case "THERAPIST_TRACK", "MODERATE", "BETWEEN_60_89" -> 72;
            case "URGENT_RED_FLAG", "SEVERE", "OVER_90" -> 104;
            default -> throw new IllegalArgumentException("Band demo không hợp lệ: " + band);
        };

        patient.setCurrentLsasScore(score);
        patient.setLastLsasDate(LocalDateTime.now());
        patient.setLsasDemoCompleted(true);
        patient.setGraduatedAt(null);
        patient.setTaperingStage(TaperingStage.NONE);

        boolean urgent = score >= 90;
        patient.setCurrentRiskScore(urgent ? 100 : 0);
        patient.setIsRedFlagActive(urgent);
        patient.setStatus(urgent ? Status.WARNING : Status.STABLE);
        patientProfileRepository.save(patient);
        if (urgent) {
            clinicalTriageService.openUrgentTriage(patient);
        } else {
            patient.setTriageRequired(false);
            patient.setTriageStatus(null);
            patient.setTriagePriority(null);
            patientProfileRepository.save(patient);
        }
        upsertRiskLog(patient);

        log.info("Admin demo control set LSAS band adminId={}, patientId={}, band={}, score={}",
                adminId, patientId, normalizedBand, score);
        return snapshot(patient, "SET_LSAS_BAND", "Đã chuyển bệnh nhân sang nhánh demo LSAS: " + normalizedBand + ".");
    }

    @Transactional
    public AdminDemoControlResultDto setProgramWeek(UUID patientId, Integer requestedWeek, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        int programWeek = Math.max(1, Math.min(requestedWeek == null ? 1 : requestedWeek, 14));
        patient.setCurrentProgramWeek(programWeek);
        patient.setTherapyProgramStartedAt(LocalDateTime.now().minusDays(Math.max(0, (programWeek - 1) * 7L)));
        patient.setGraduatedAt(null);
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);
        clearBehavioralExperiments(patientId);

        log.info("Admin demo control set program week adminId={}, patientId={}, week={}",
                adminId, patientId, programWeek);
        return snapshot(patient, "SET_PROGRAM_WEEK", "Đã đặt tuần trị liệu demo thành tuần " + programWeek + ".");
    }

    @Transactional
    public AdminDemoControlResultDto setFearLadderMastery(UUID patientId, Integer requestedMasteredCount, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        List<FearLadderItem> items = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId);
        if (items.isEmpty()) {
            throw new IllegalStateException("Bệnh nhân chưa có Fear Ladder để ép tiến độ demo.");
        }

        int masteredCount = Math.max(0, Math.min(requestedMasteredCount == null ? 0 : requestedMasteredCount, items.size()));
        for (int index = 0; index < items.size(); index++) {
            FearLadderItem item = items.get(index);
            if (index < masteredCount) {
                item.setStatus(FearLadderStatus.MASTERED);
                item.setCurrentFearScore(0);
                item.setCurrentAvoidanceScore(0);
            } else {
                item.setStatus(FearLadderStatus.ACTIVE);
            }
        }
        fearLadderItemRepository.saveAll(items);
        clearBehavioralExperiments(patientId);

        log.info("Admin demo control set fear ladder mastery adminId={}, patientId={}, masteredCount={}",
                adminId, patientId, masteredCount);
        return snapshot(
                patient,
                "SET_FEAR_LADDER_MASTERY",
                "Đã cập nhật tiến độ Fear Ladder demo: " + masteredCount + "/" + items.size() + " bậc đã làm chủ.");
    }

    @Transactional
    public AdminDemoControlResultDto resetFearLadderProgress(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        List<FearLadderItem> items = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId);
        for (FearLadderItem item : items) {
            item.setStatus(FearLadderStatus.ACTIVE);
        }
        fearLadderItemRepository.saveAll(items);
        clearBehavioralExperiments(patientId);

        log.info("Admin demo control reset fear ladder progress adminId={}, patientId={}", adminId, patientId);
        return snapshot(patient, "RESET_FEAR_LADDER_PROGRESS", "Đã reset tiến độ Fear Ladder để demo lại từ đầu.");
    }

    @Transactional
    public AdminDemoControlResultDto seedDailyCheckin(UUID patientId, String mode, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        String normalizedMode = mode == null ? "STABLE" : mode.trim().toUpperCase();

        UserMood userMood = new UserMood();
        userMood.setPatientProfile(patient);
        userMood.setDailyAgenda("Demo daily check-in: " + normalizedMode);

        switch (normalizedMode) {
            case "STABLE", "COPING_0_3" -> {
                userMood.setAnxietyScore(20);
                userMood.setAvoidanceUrgeScore(18);
                userMood.setSadnessScore(15);
                userMood.setAnticipatoryAnxietyScore(2);
                userMood.setPostEventRuminationScore(1);
                userMood.setSafetyCheckRequired(false);
                patient.setCurrentRiskScore(0);
                patient.setIsRedFlagActive(false);
                patient.setStatus(Status.STABLE);
            }
            case "CHOICE_4_5", "MILD" -> {
                userMood.setAnxietyScore(48);
                userMood.setAvoidanceUrgeScore(42);
                userMood.setSadnessScore(24);
                userMood.setAnticipatoryAnxietyScore(4);
                userMood.setPostEventRuminationScore(5);
                userMood.setSafetyCheckRequired(false);
                patient.setCurrentRiskScore(25);
                patient.setIsRedFlagActive(false);
                patient.setStatus(Status.STABLE);
            }
            case "THOUGHT_RECORD_6_8", "HIGH" -> {
                userMood.setAnxietyScore(68);
                userMood.setAvoidanceUrgeScore(62);
                userMood.setSadnessScore(34);
                userMood.setAnticipatoryAnxietyScore(7);
                userMood.setPostEventRuminationScore(6);
                userMood.setSafetyCheckRequired(false);
                patient.setCurrentRiskScore(45);
                patient.setIsRedFlagActive(false);
                patient.setStatus(Status.STABLE);
            }
            case "UNSAFE", "RED_FLAG" -> {
                userMood.setAnxietyScore(95);
                userMood.setAvoidanceUrgeScore(88);
                userMood.setSadnessScore(94);
                userMood.setAnticipatoryAnxietyScore(8);
                userMood.setPostEventRuminationScore(8);
                userMood.setSafetyCheckRequired(true);
                userMood.setSafetyResponse("UNSAFE");
                userMood.setSafetyRespondedAt(LocalDateTime.now());
                patient.setCurrentRiskScore(100);
                patient.setIsRedFlagActive(true);
                patient.setStatus(Status.WARNING);
            }
            default -> throw new IllegalArgumentException("Mode daily check-in không hợp lệ: " + mode);
        }

        userMood.setMoodScore(Math.max(0, 100 - userMood.getAnxietyScore()));
        userMoodRepository.save(userMood);
        patientProfileRepository.save(patient);
        upsertRiskLog(patient);

        log.info("Admin demo control seed daily check-in adminId={}, patientId={}, mode={}",
                adminId, patientId, normalizedMode);
        return snapshot(patient, "SEED_DAILY_CHECKIN", "Đã tạo daily check-in demo: " + normalizedMode + ".");
    }

    @Transactional
    public AdminDemoControlResultDto seedThoughtRecord(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        JournalDto dto = new JournalDto();
        dto.setPatientId(patientId);
        dto.setJournalType(JournalType.THOUGHT_RECORD);
        dto.setSituation("Đang họp nhóm thì bị gọi phát biểu đột ngột.");
        dto.setWorstPrediction("Mọi người sẽ nghĩ mình kém cỏi và run rẩy.");
        dto.setAutomaticThought("Nếu mình nói vấp, họ sẽ đánh giá mình rất tệ.");
        dto.setEmotion("Lo âu");
        dto.setEmotionScore(82);
        dto.setBodySymptoms(List.of("Tim đập nhanh", "Tay run nhẹ"));
        dto.setSafetyBehaviors(List.of("Nhìn xuống bàn", "Nói thật nhanh để kết thúc sớm"));
        dto.setDistortions(List.of("MIND_READING", "CATASTROPHIZING"));
        dto.setAdaptiveResponse("Mình có thể hồi hộp nhưng điều đó không có nghĩa là mình thất bại.");
        dto.setSafetyBehaviorCommitment("Ngẩng đầu lên và nói chậm lại ít nhất 1 câu.");
        dto.setReRatedScore(46);
        dto.setReRatedBeliefScore(40);
        dto.setBehavioralExperimentIdea("Thử phát biểu 1 ý ngắn trong cuộc họp tiếp theo.");
        journalService.saveJournal(dto, patientId);

        log.info("Admin demo control seeded thought record adminId={}, patientId={}", adminId, patientId);
        return snapshot(
                patient,
                "SEED_THOUGHT_RECORD",
                "Đã tạo một Thought Record mẫu để demo lịch sử nhật ký và therapist review.");
    }

    @Transactional
    public AdminDemoControlResultDto setTaperingStage(UUID patientId, String stage, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        TaperingStage taperingStage = TaperingStage.valueOf(stage.trim().toUpperCase());
        patient.setTaperingStage(taperingStage);
        if (taperingStage != TaperingStage.NONE) {
            patient.setGraduatedAt(null);
        }
        patientProfileRepository.save(patient);

        log.info("Admin demo control set tapering stage adminId={}, patientId={}, stage={}",
                adminId, patientId, taperingStage);
        return snapshot(patient, "SET_TAPERING_STAGE", "Đã chuyển bệnh nhân sang trạng thái tapering: " + taperingStage + ".");
    }

    @Transactional
    public AdminDemoControlResultDto markGraduated(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setGraduatedAt(LocalDateTime.now());
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);

        log.info("Admin demo control mark graduated adminId={}, patientId={}", adminId, patientId);
        return snapshot(patient, "MARK_GRADUATED", "Đã chuyển bệnh nhân sang giai đoạn duy trì / booster.");
    }

    @Transactional
    public AdminDemoControlResultDto resetGraduation(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setGraduatedAt(null);
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);

        log.info("Admin demo control reset graduation adminId={}, patientId={}", adminId, patientId);
        return snapshot(
                patient,
                "RESET_GRADUATION",
                "Đã reset trạng thái tốt nghiệp. Bệnh nhân quay lại luồng đang điều trị.");
    }

    @Transactional
    public AdminDemoControlResultDto triggerBooster(UUID patientId, String purpose, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        if (patient.getTherapist() == null) {
            throw new IllegalStateException("Bệnh nhân chưa có chuyên gia phụ trách để tạo booster demo.");
        }

        AppointmentPurpose appointmentPurpose = AppointmentPurpose.valueOf(purpose.trim().toUpperCase());
        patient.setGraduatedAt(patient.getGraduatedAt() != null ? patient.getGraduatedAt() : LocalDateTime.now());
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);

        LocalDateTime startAt = LocalDateTime.now()
                .plusDays(switch (appointmentPurpose) {
                    case BOOSTER_6M -> 2;
                    case BOOSTER_12M -> 3;
                    default -> 1;
                })
                .withHour(10)
                .withMinute(0)
                .withSecond(0)
                .withNano(0);

        if (!appointmentRepository.existsByPatientProfile_IdAndPurposeAndStartAt(patientId, appointmentPurpose, startAt)) {
            Appointment appointment = new Appointment();
            appointment.setPatientProfile(patient);
            appointment.setTherapistProfile(patient.getTherapist());
            appointment.setStartAt(startAt);
            appointment.setEndAt(startAt.plusMinutes(50));
            appointment.setStatus(AppointmentStatus.BOOKED);
            appointment.setPurpose(appointmentPurpose);
            appointment.setClinicalPurposeCode(appointmentPurpose.name());
            appointment.setCarePhaseCode("MAINTENANCE");
            appointment.setIsAnonymous(Boolean.TRUE.equals(patient.getAnonymousModeEnabled()));
            appointment.setMeetingLink(patient.getTherapist().getMeetingLink());
            appointment.setTherapistNotes("Demo booster session created by admin.");
            appointmentRepository.save(appointment);
        }

        log.info("Admin demo control trigger booster adminId={}, patientId={}, purpose={}",
                adminId, patientId, appointmentPurpose);
        return snapshot(patient, "TRIGGER_BOOSTER", "Đã tạo booster demo: " + appointmentPurpose + ".");
    }

    private PatientProfile getPatient(UUID patientId) {
        return patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ bệnh nhân: " + patientId));
    }

    private void upsertRiskLog(PatientProfile patient) {
        DailyRiskLog riskLog = dailyRiskLogRepository.findByPatientProfile_IdAndRiskDate(patient.getId(), LocalDate.now())
                .orElseGet(DailyRiskLog::new);
        riskLog.setPatientProfile(patient);
        riskLog.setRiskDate(LocalDate.now());
        riskLog.setRiskScore(patient.getCurrentRiskScore() != null ? patient.getCurrentRiskScore() : 0);
        riskLog.setScoreSafety(patient.getCurrentRiskScore() != null ? patient.getCurrentRiskScore() : 0);
        riskLog.setScoreAi(0);
        riskLog.setScoreMood(0);
        riskLog.setOverrideTriggered(Boolean.TRUE.equals(patient.getIsRedFlagActive())
                || (patient.getCurrentRiskScore() != null && patient.getCurrentRiskScore() >= 70));
        riskLog.setRedFlagActive(Boolean.TRUE.equals(patient.getIsRedFlagActive()));
        riskLog.setCalculatedAt(LocalDateTime.now());
        dailyRiskLogRepository.save(riskLog);
    }

    private AdminDemoControlResultDto snapshot(PatientProfile patient, String action, String message) {
        AdminDemoControlResultDto result = new AdminDemoControlResultDto(patient.getId(), action, message);
        result.setCurrentRiskScore(patient.getCurrentRiskScore());
        result.setCurrentLsasScore(patient.getCurrentLsasScore());
        result.setRedFlagActive(patient.getIsRedFlagActive());
        result.setClinicalRoute(resolveClinicalRoute(patient.getCurrentLsasScore()));
        result.setClinicalAttention((patient.getCurrentLsasScore() != null ? patient.getCurrentLsasScore() : 0) >= 95);
        result.setTaperingStage(patient.getTaperingStage() != null ? patient.getTaperingStage().name() : null);
        result.setGraduatedAt(patient.getGraduatedAt() != null ? patient.getGraduatedAt().toString() : null);

        int programWeek = roadmapProgramStateService.resolveProgramWeek(patient);
        RoadmapProgramStateService.ProgramPhase phase = roadmapProgramStateService.resolvePhase(programWeek);
        List<FearLadderItem> ladderItems = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patient.getId());
        int masteredCount = (int) ladderItems.stream()
                .filter(item -> item.getStatus() == FearLadderStatus.MASTERED)
                .count();

        result.setProgramWeek(programWeek);
        result.setProgramPhaseCode(phase.code());
        result.setProgramPhaseLabel(phase.label());
        result.setFearLadderUnlockedCount(resolveUnlockedCount(ladderItems));
        result.setFearLadderMasteredCount(masteredCount);
        result.setGraduationReady(!ladderItems.isEmpty() && masteredCount == ladderItems.size());
        return result;
    }

    private int resolveUnlockedCount(List<FearLadderItem> items) {
        if (items.isEmpty()) {
            return 0;
        }
        for (int index = 0; index < items.size(); index++) {
            if (items.get(index).getStatus() != FearLadderStatus.MASTERED) {
                return Math.min(items.size(), index + 1);
            }
        }
        return items.size();
    }

    private void clearBehavioralExperiments(UUID patientId) {
        behavioralExperimentRepository.deleteByPatientProfile_Id(patientId);
    }

    private String resolveClinicalRoute(Integer totalScore) {
        int safeScore = totalScore == null ? 0 : totalScore;
        if (safeScore >= 90) {
            return "URGENT_RED_FLAG";
        }
        if (safeScore >= 60) {
            return "THERAPIST_TRACK_14_WEEKS";
        }
        if (safeScore >= 30) {
            return "SELF_HELP";
        }
        return "REASSURANCE";
    }
}
