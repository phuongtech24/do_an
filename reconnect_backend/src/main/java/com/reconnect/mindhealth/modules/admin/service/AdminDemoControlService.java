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
                "ÄÃ£ má»Ÿ khÃ³a LSAS/re-rating. Bá»‡nh nhÃ¢n cÃ³ thá»ƒ vÃ o app Ä‘á»ƒ lÃ m láº¡i Ä‘Ã¡nh giÃ¡.");
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
                "ÄÃ£ kÃ­ch hoáº¡t LSAS/re-rating Ä‘á»™t xuáº¥t cho demo. Bá»‡nh nhÃ¢n cÃ³ thá»ƒ lÃ m ngay trÃªn app.");
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
                        ? "Bá»‡nh nhÃ¢n Ä‘Ã£ cÃ³ bÃ i há»‡ thá»‘ng trong ngÃ y, khÃ´ng táº¡o trÃ¹ng."
                        : "ÄÃ£ táº¡o bÃ i há»‡ thá»‘ng cho hÃ´m nay.");
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
        return snapshot(patient, "SET_RISK", "ÄÃ£ cáº­p nháº­t risk/red flag demo cho bá»‡nh nhÃ¢n.");
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
        return snapshot(patient, "CLEAR_RISK", "ÄÃ£ táº¯t cáº£nh bÃ¡o risk/red flag demo.");
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
            default -> throw new IllegalArgumentException("Band demo khÃ´ng há»£p lá»‡: " + band);
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
        return snapshot(patient, "SET_LSAS_BAND", "ÄÃ£ chuyá»ƒn bá»‡nh nhÃ¢n sang nhÃ¡nh demo LSAS: " + normalizedBand + ".");
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
        return snapshot(patient, "SET_PROGRAM_WEEK", "ÄÃ£ Ä‘áº·t tuáº§n trá»‹ liá»‡u demo thÃ nh tuáº§n " + programWeek + ".");
    }

    @Transactional
    public AdminDemoControlResultDto setFearLadderMastery(UUID patientId, Integer requestedMasteredCount, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        List<FearLadderItem> items = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId);
        if (items.isEmpty()) {
            throw new IllegalStateException("Bá»‡nh nhÃ¢n chÆ°a cÃ³ Fear Ladder Ä‘á»ƒ Ã©p tiáº¿n Ä‘á»™ demo.");
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
                "ÄÃ£ cáº­p nháº­t tiáº¿n Ä‘á»™ Fear Ladder demo: " + masteredCount + "/" + items.size() + " báº­c Ä‘Ã£ lÃ m chá»§.");
    }
    @Transactional
    public AdminDemoControlResultDto unlockAllRoadmapContent(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        List<FearLadderItem> items = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId);
        if (items.isEmpty()) {
            throw new IllegalStateException("Bệnh nhân chưa có Fear Ladder để mở khóa toàn bộ.");
        }

        patient.setCurrentProgramWeek(14);
        patient.setTherapyProgramStartedAt(LocalDateTime.now().minusDays((14 - 1) * 7L));
        patient.setGraduatedAt(null);
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);

        for (FearLadderItem item : items) {
            item.setStatus(FearLadderStatus.MASTERED);
            item.setCurrentFearScore(0);
            item.setCurrentAvoidanceScore(0);
        }
        fearLadderItemRepository.saveAll(items);
        clearBehavioralExperiments(patientId);

        List<PatientQuest> created = roadmapDailyAssignmentService.ensureDailySystemQuests(patient, LocalDate.now());
        AdminDemoControlResultDto result = snapshot(
                patient,
                "UNLOCK_ALL_ROADMAP_CONTENT",
                "Đã mở khóa toàn bộ roadmap demo: tuần 14, toàn bộ Fear Ladder đã làm chủ và bài hệ thống hôm nay đã sẵn sàng.");
        result.setCreatedQuests(created.size());

        log.info("Admin demo control unlock all roadmap content adminId={}, patientId={}, ladderCount={}, createdQuests={}",
                adminId, patientId, items.size(), created.size());
        return result;
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
        return snapshot(patient, "RESET_FEAR_LADDER_PROGRESS", "ÄÃ£ reset tiáº¿n Ä‘á»™ Fear Ladder Ä‘á»ƒ demo láº¡i tá»« Ä‘áº§u.");
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
            default -> throw new IllegalArgumentException("Mode daily check-in khÃ´ng há»£p lá»‡: " + mode);
        }

        userMood.setMoodScore(Math.max(0, 100 - userMood.getAnxietyScore()));
        userMoodRepository.save(userMood);
        patientProfileRepository.save(patient);
        upsertRiskLog(patient);

        log.info("Admin demo control seed daily check-in adminId={}, patientId={}, mode={}",
                adminId, patientId, normalizedMode);
        return snapshot(patient, "SEED_DAILY_CHECKIN", "ÄÃ£ táº¡o daily check-in demo: " + normalizedMode + ".");
    }

    @Transactional
    public AdminDemoControlResultDto seedThoughtRecord(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        JournalDto dto = new JournalDto();
        dto.setPatientId(patientId);
        dto.setJournalType(JournalType.THOUGHT_RECORD);
        dto.setSituation("Äang há»p nhÃ³m thÃ¬ bá»‹ gá»i phÃ¡t biá»ƒu Ä‘á»™t ngá»™t.");
        dto.setWorstPrediction("Má»i ngÆ°á»i sáº½ nghÄ© mÃ¬nh kÃ©m cá»i vÃ  run ráº©y.");
        dto.setAutomaticThought("Náº¿u mÃ¬nh nÃ³i váº¥p, há» sáº½ Ä‘Ã¡nh giÃ¡ mÃ¬nh ráº¥t tá»‡.");
        dto.setEmotion("Lo Ã¢u");
        dto.setEmotionScore(82);
        dto.setBodySymptoms(List.of("Tim Ä‘áº­p nhanh", "Tay run nháº¹"));
        dto.setSafetyBehaviors(List.of("NhÃ¬n xuá»‘ng bÃ n", "NÃ³i tháº­t nhanh Ä‘á»ƒ káº¿t thÃºc sá»›m"));
        dto.setDistortions(List.of("MIND_READING", "CATASTROPHIZING"));
        dto.setAdaptiveResponse("MÃ¬nh cÃ³ thá»ƒ há»“i há»™p nhÆ°ng Ä‘iá»u Ä‘Ã³ khÃ´ng cÃ³ nghÄ©a lÃ  mÃ¬nh tháº¥t báº¡i.");
        dto.setSafetyBehaviorCommitment("Ngáº©ng Ä‘áº§u lÃªn vÃ  nÃ³i cháº­m láº¡i Ã­t nháº¥t 1 cÃ¢u.");
        dto.setReRatedScore(46);
        dto.setReRatedBeliefScore(40);
        dto.setBehavioralExperimentIdea("Thá»­ phÃ¡t biá»ƒu 1 Ã½ ngáº¯n trong cuá»™c há»p tiáº¿p theo.");
        journalService.saveJournal(dto, patientId);

        log.info("Admin demo control seeded thought record adminId={}, patientId={}", adminId, patientId);
        return snapshot(
                patient,
                "SEED_THOUGHT_RECORD",
                "ÄÃ£ táº¡o má»™t Thought Record máº«u Ä‘á»ƒ demo lá»‹ch sá»­ nháº­t kÃ½ vÃ  therapist review.");
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
        return snapshot(patient, "SET_TAPERING_STAGE", "ÄÃ£ chuyá»ƒn bá»‡nh nhÃ¢n sang tráº¡ng thÃ¡i tapering: " + taperingStage + ".");
    }

    @Transactional
    public AdminDemoControlResultDto markGraduated(UUID patientId, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        patient.setGraduatedAt(LocalDateTime.now());
        patient.setTaperingStage(TaperingStage.NONE);
        patientProfileRepository.save(patient);

        log.info("Admin demo control mark graduated adminId={}, patientId={}", adminId, patientId);
        return snapshot(patient, "MARK_GRADUATED", "ÄÃ£ chuyá»ƒn bá»‡nh nhÃ¢n sang giai Ä‘oáº¡n duy trÃ¬ / booster.");
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
                "ÄÃ£ reset tráº¡ng thÃ¡i tá»‘t nghiá»‡p. Bá»‡nh nhÃ¢n quay láº¡i luá»“ng Ä‘ang Ä‘iá»u trá»‹.");
    }

    @Transactional
    public AdminDemoControlResultDto triggerBooster(UUID patientId, String purpose, UUID adminId) {
        PatientProfile patient = getPatient(patientId);
        if (patient.getTherapist() == null) {
            throw new IllegalStateException("Bá»‡nh nhÃ¢n chÆ°a cÃ³ chuyÃªn gia phá»¥ trÃ¡ch Ä‘á»ƒ táº¡o booster demo.");
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
        return snapshot(patient, "TRIGGER_BOOSTER", "ÄÃ£ táº¡o booster demo: " + appointmentPurpose + ".");
    }

    private PatientProfile getPatient(UUID patientId) {
        return patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("KhÃ´ng tÃ¬m tháº¥y há»“ sÆ¡ bá»‡nh nhÃ¢n: " + patientId));
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
