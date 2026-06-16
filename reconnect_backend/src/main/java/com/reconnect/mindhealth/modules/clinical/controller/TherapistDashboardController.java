package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.util.PagingUtils;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSubmissionRepository;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentStatus;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistPatientListItemDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistPatientSearchRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistPreSessionReviewDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.service.TherapistAssignmentService;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import com.reconnect.mindhealth.modules.journal.repository.JournalRepository;
import com.reconnect.mindhealth.modules.roadmap.entity.BehavioralExperiment;
import com.reconnect.mindhealth.modules.roadmap.entity.FearLadderItem;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientGoal;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.BehavioralExperimentRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.FearLadderItemRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientGoalRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapProgramStateService;

@RestController
@RequestMapping("/api/therapist")
public class TherapistDashboardController {

    private final TherapistAssignmentService therapistAssignmentService;
    private final LsasSubmissionRepository lsasSubmissionRepository;
    private final PatientGoalRepository patientGoalRepository;
    private final RoadmapProgramStateService roadmapProgramStateService;
    private final AppointmentRepository appointmentRepository;
    private final JournalRepository journalRepository;
    private final UserMoodRepository userMoodRepository;
    private final FearLadderItemRepository fearLadderItemRepository;
    private final BehavioralExperimentRepository behavioralExperimentRepository;
    private final PatientQuestRepository patientQuestRepository;

    public TherapistDashboardController(
            TherapistAssignmentService therapistAssignmentService,
            LsasSubmissionRepository lsasSubmissionRepository,
            PatientGoalRepository patientGoalRepository,
            RoadmapProgramStateService roadmapProgramStateService,
            AppointmentRepository appointmentRepository,
            JournalRepository journalRepository,
            UserMoodRepository userMoodRepository,
            FearLadderItemRepository fearLadderItemRepository,
            BehavioralExperimentRepository behavioralExperimentRepository,
            PatientQuestRepository patientQuestRepository) {
        this.therapistAssignmentService = therapistAssignmentService;
        this.lsasSubmissionRepository = lsasSubmissionRepository;
        this.patientGoalRepository = patientGoalRepository;
        this.roadmapProgramStateService = roadmapProgramStateService;
        this.appointmentRepository = appointmentRepository;
        this.journalRepository = journalRepository;
        this.userMoodRepository = userMoodRepository;
        this.fearLadderItemRepository = fearLadderItemRepository;
        this.behavioralExperimentRepository = behavioralExperimentRepository;
        this.patientQuestRepository = patientQuestRepository;
    }

    @GetMapping("/patients")
    public ResponseEntity<ApiResponse<List<TherapistPatientListItemDto>>> listPatients(
            @RequestParam(name = "redFlagOnly", defaultValue = "false") boolean redFlagOnly) {
        List<TherapistPatientListItemDto> dto = buildPatientListItems(redFlagOnly, null);
        return ResponseEntity.ok(ApiResponse.success("OK", dto));
    }

    @PostMapping("/patients/paging")
    public ResponseEntity<ApiResponse<Page<TherapistPatientListItemDto>>> searchPatientsByPage(
            @RequestBody(required = false) TherapistPatientSearchRequestDto request) {
        try {
            TherapistPatientSearchRequestDto safeRequest = request != null ? request : new TherapistPatientSearchRequestDto();
            List<TherapistPatientListItemDto> dto = buildPatientListItems(
                    Boolean.TRUE.equals(safeRequest.getRedFlagOnly()),
                    safeRequest.normalizedKeyword());
            return ResponseEntity.ok(ApiResponse.success("OK", PagingUtils.paginate(dto, safeRequest)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải danh sách bệnh nhân: " + e.getMessage()));
        }
    }

    @GetMapping("/patients/{patientId}/pre-session-review")
    public ResponseEntity<ApiResponse<TherapistPreSessionReviewDto>> getPreSessionReview(@PathVariable String patientId) {
        try {
            PatientProfile patient = therapistAssignmentService.getPatientForCurrentTherapist(java.util.UUID.fromString(patientId));
            TherapistPreSessionReviewDto dto = buildPreSessionReview(patient);
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải pre-session review: " + e.getMessage()));
        }
    }

    private List<TherapistPatientListItemDto> buildPatientListItems(boolean redFlagOnly, String keyword) {
        List<PatientProfile> list = therapistAssignmentService.listPatientsForCurrentTherapist(redFlagOnly);
        return list.stream()
                .map(this::buildPatientListItem)
                .filter(item -> matchesKeyword(item, keyword))
                .sorted(Comparator
                        .comparing((TherapistPatientListItemDto item) -> !Boolean.TRUE.equals(item.getIsRedFlagActive()))
                        .thenComparing((TherapistPatientListItemDto item) -> safe(item.getCurrentLsasScore()) < 95)
                        .thenComparing((TherapistPatientListItemDto item) -> item.getUpcomingAppointmentAt() == null)
                        .thenComparing((TherapistPatientListItemDto item) -> !Boolean.TRUE.equals(item.getStalledProgress()))
                        .thenComparing(item -> safe(item.getCurrentRiskScore()), Comparator.reverseOrder()))
                .collect(Collectors.toList());
    }

    private TherapistPatientListItemDto buildPatientListItem(PatientProfile patient) {
        TherapistPatientListItemDto dto = new TherapistPatientListItemDto(
                patient,
                resolveBaselineLsas(patient),
                resolvePrimaryGoal(patient));
        int programWeek = roadmapProgramStateService.resolveProgramWeek(patient);
        dto.setProgramWeek(programWeek > 0 ? programWeek : null);
        dto.setProgramPhaseLabel(programWeek > 0 ? roadmapProgramStateService.resolvePhase(programWeek).label() : null);
        dto.setStalledProgress(resolveStalledProgress(patient));
        dto.setUpcomingAppointmentAt(resolveUpcomingAppointment(patient));
        dto.setLatestThoughtRecordAt(resolveLatestThoughtRecordAt(patient));
        dto.setLatestCheckinAt(resolveLatestCheckinAt(patient));
        return dto;
    }

    private Integer resolveBaselineLsas(PatientProfile patient) {
        return Optional.ofNullable(lsasSubmissionRepository.findTopByPatientProfile_IdAndSubmissionTypeOrderByCreateDateAsc(
                patient.getId(),
                LsasSubmissionType.BASELINE))
                .map(LsasSubmission::getTotalScore)
                .orElse(patient.getCurrentLsasScore());
    }

    private String resolvePrimaryGoal(PatientProfile patient) {
        return patientGoalRepository
                .findByPatientProfile_IdAndStatusOrderByCreateDateDesc(patient.getId(), PatientGoalStatus.ACTIVE)
                .stream()
                .findFirst()
                .map(PatientGoal::getDescription)
                .orElse(null);
    }

    private boolean resolveStalledProgress(PatientProfile patient) {
        List<PatientQuest> recent = patientQuestRepository.findRecentByPatientId(patient.getId()).stream().limit(3).toList();
        return !recent.isEmpty() && recent.stream().noneMatch(quest -> quest.getCompletedAt() != null);
    }

    private java.time.LocalDateTime resolveUpcomingAppointment(PatientProfile patient) {
        Appointment appointment = appointmentRepository.findTopByPatientProfile_IdAndStatusAndStartAtAfterOrderByStartAtAsc(
                patient.getId(),
                AppointmentStatus.BOOKED,
                java.time.LocalDateTime.now());
        return appointment != null ? appointment.getStartAt() : null;
    }

    private java.util.Date resolveLatestThoughtRecordAt(PatientProfile patient) {
        return journalRepository.findTop5ByPatientProfile_IdOrderByCreateDateDesc(patient.getId()).stream()
                .findFirst()
                .map(Journal::getCreateDate)
                .orElse(null);
    }

    private java.util.Date resolveLatestCheckinAt(PatientProfile patient) {
        return userMoodRepository.findTop5ByPatientProfile_IdOrderByCreateDateDesc(patient.getId()).stream()
                .findFirst()
                .map(UserMood::getCreateDate)
                .orElse(null);
    }

    private TherapistPreSessionReviewDto buildPreSessionReview(PatientProfile patient) {
        TherapistPreSessionReviewDto dto = new TherapistPreSessionReviewDto();
        dto.setBaselineLsasScore(resolveBaselineLsas(patient));
        dto.setCurrentLsasScore(patient.getCurrentLsasScore());
        dto.setLatestLsasScore(Optional.ofNullable(lsasSubmissionRepository.findTopByPatientProfile_IdOrderByCreateDateDesc(patient.getId()))
                .map(LsasSubmission::getTotalScore)
                .orElse(patient.getCurrentLsasScore()));
        dto.setGoalSummary(resolvePrimaryGoal(patient));

        List<FearLadderItem> ladder = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patient.getId());
        dto.setFearLadderTotalItems(ladder.size());
        dto.setFearLadderUnlockedItems((int) ladder.stream().filter(item -> item.getStatus() != null).count());

        List<BehavioralExperiment> experiments = behavioralExperimentRepository.findByPatientProfile_IdOrderByAssignedAtDesc(patient.getId())
                .stream()
                .limit(5)
                .toList();
        dto.setBehavioralExperimentsLastWeek(experiments.size());
        dto.setRecentBehavioralExperimentSummaries(experiments.stream()
                .map(item -> item.getFearLadderItem().getSituation().getText() + " - " + item.getStatus())
                .toList());

        List<Journal> journals = journalRepository.findTop5ByPatientProfile_IdOrderByCreateDateDesc(patient.getId());
        dto.setThoughtRecordsLastWeek(journals.size());
        dto.setRecentThoughtRecordSummaries(journals.stream()
                .map(item -> item.getJournalType() + " - risk " + item.getAiRiskScore())
                .toList());

        List<UserMood> moods = userMoodRepository.findTop5ByPatientProfile_IdOrderByCreateDateDesc(patient.getId());
        dto.setDailyCheckinsLastWeek(moods.size());
        dto.setRecentDailyCheckinSummaries(moods.stream()
                .map(item -> "Lo âu " + safe(item.getAnxietyScore()) + "/100, né tránh " + safe(item.getAvoidanceUrgeScore()) + "/100")
                .toList());

        List<PatientQuest> recentQuests = patientQuestRepository.findRecentByPatientId(patient.getId()).stream().limit(5).toList();
        dto.setRecentHomeworkCompleted((int) recentQuests.stream().filter(item -> item.getCompletedAt() != null).count());

        int programWeek = roadmapProgramStateService.resolveProgramWeek(patient);
        dto.setProgramWeek(programWeek > 0 ? programWeek : null);
        dto.setProgramPhaseLabel(programWeek > 0 ? roadmapProgramStateService.resolvePhase(programWeek).label() : null);
        dto.setCurrentRiskScore(patient.getCurrentRiskScore());
        dto.setRedFlagActive(patient.getIsRedFlagActive());
        dto.setUpcomingAppointmentAt(resolveUpcomingAppointment(patient));
        return dto;
    }

    private boolean matchesKeyword(TherapistPatientListItemDto item, String keyword) {
        if (keyword == null) {
            return true;
        }
        String normalized = keyword.toLowerCase(Locale.ROOT);
        return containsIgnoreCase(item.getNickname(), normalized)
                || containsIgnoreCase(item.getRealFullName(), normalized)
                || containsIgnoreCase(item.getPrimaryGoal(), normalized);
    }

    private boolean containsIgnoreCase(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }

    private int safe(Integer value) {
        return value != null ? value : 0;
    }
}
