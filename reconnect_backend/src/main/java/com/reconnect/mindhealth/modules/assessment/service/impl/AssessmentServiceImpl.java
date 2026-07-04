package com.reconnect.mindhealth.modules.assessment.service.impl;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.assessment.dto.LsasAnswerRequestDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSituationDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;
import com.reconnect.mindhealth.modules.assessment.entity.LsasAnswer;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSituation;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSituationRepository;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSubmissionRepository;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.service.ClinicalTriageService;
import com.reconnect.mindhealth.modules.guest.entity.GuestProfile;
import com.reconnect.mindhealth.modules.guest.repository.GuestProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.service.FearLadderService;
import com.reconnect.mindhealth.modules.risk.service.IRiskScoringService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AssessmentServiceImpl implements IAssessmentService {

    private static final Logger log = LoggerFactory.getLogger(AssessmentServiceImpl.class);

    private final LsasSituationRepository lsasSituationRepository;
    private final LsasSubmissionRepository lsasSubmissionRepository;
    private final UserMoodRepository userMoodRepository;
    private final PatientProfileRepository patientProfileRepository;
    private final UserRepository userRepository;
    private final GuestProfileRepository guestProfileRepository;
    private final FearLadderService fearLadderService;
    private final IRiskScoringService riskScoringService;
    private final ClinicalTriageService clinicalTriageService;
    private final ObjectMapper objectMapper;

    public AssessmentServiceImpl(
            LsasSituationRepository lsasSituationRepository,
            LsasSubmissionRepository lsasSubmissionRepository,
            UserMoodRepository userMoodRepository,
            PatientProfileRepository patientProfileRepository,
            UserRepository userRepository,
            GuestProfileRepository guestProfileRepository,
            FearLadderService fearLadderService,
            IRiskScoringService riskScoringService,
            ClinicalTriageService clinicalTriageService,
            ObjectMapper objectMapper) {
        this.lsasSituationRepository = lsasSituationRepository;
        this.lsasSubmissionRepository = lsasSubmissionRepository;
        this.userMoodRepository = userMoodRepository;
        this.patientProfileRepository = patientProfileRepository;
        this.userRepository = userRepository;
        this.guestProfileRepository = guestProfileRepository;
        this.fearLadderService = fearLadderService;
        this.riskScoringService = riskScoringService;
        this.clinicalTriageService = clinicalTriageService;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional(readOnly = true)
    public List<LsasSituationDto> getLsasSituations() {
        return lsasSituationRepository.findAllByOrderBySituationNumberAsc()
                .stream()
                .map(LsasSituationDto::new)
                .toList();
    }

    @Override
    @Transactional
    public LsasSubmissionDto submitLsas(LsasSubmissionDto dto) {
        if (dto.getAnswers() == null || dto.getAnswers().size() != 24) {
            throw new IllegalArgumentException("LSAS cần đủ 24 câu trả lời.");
        }
        validateUniqueSituations(dto.getAnswers());

        PatientProfile patient = patientProfileRepository.findById(dto.getPatientId()).orElse(null);
        if (patient == null) {
            User guestUser = userRepository.findById(dto.getPatientId())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user: " + dto.getPatientId()));
            if (guestUser.getRole() != Role.GUEST) {
                throw new EntityNotFoundException("Không tìm thấy bệnh nhân: " + dto.getPatientId());
            }
            return saveGuestLsas(guestUser, dto);
        }

        boolean hasBaseline = lsasSubmissionRepository.existsByPatientProfile_IdAndSubmissionType(
                patient.getId(), LsasSubmissionType.BASELINE);
        LsasSubmissionType type = dto.getSubmissionType();
        if (!hasBaseline) {
            type = LsasSubmissionType.BASELINE;
        } else if (type == null || type == LsasSubmissionType.BASELINE) {
            type = LsasSubmissionType.PERIODIC;
        }

        LsasSubmission submission = new LsasSubmission();
        submission.setPatientProfile(patient);
        submission.setSubmissionType(type);
        submission.setUnlockedAt(LocalDateTime.now().plusDays(14));

        int fearTotal = 0;
        int avoidanceTotal = 0;
        List<LsasAnswer> answers = new ArrayList<>();
        for (LsasAnswerRequestDto answerDto : dto.getAnswers()) {
            LsasSituation situation = lsasSituationRepository.findById(answerDto.getSituationId())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy tình huống LSAS."));
            int fear = normalizeLsasScore(answerDto.getFearScore());
            int avoidance = normalizeLsasScore(answerDto.getAvoidanceScore());
            LsasAnswer answer = new LsasAnswer();
            answer.setSubmission(submission);
            answer.setSituation(situation);
            answer.setFearScore(fear);
            answer.setAvoidanceScore(avoidance);
            answer.setTotalScore(fear + avoidance);
            answers.add(answer);
            fearTotal += fear;
            avoidanceTotal += avoidance;
        }
        submission.setFearTotal(fearTotal);
        submission.setAvoidanceTotal(avoidanceTotal);
        submission.setTotalScore(fearTotal + avoidanceTotal);
        submission.setAnswers(answers);

        LsasSubmission saved = lsasSubmissionRepository.save(submission);
        patient.setLastLsasDate(LocalDateTime.now());
        patient.setCurrentLsasScore(saved.getTotalScore());
        patient.setLsasDemoCompleted(true);
        if (patient.getCurrentCycleStartDate() == null || type == LsasSubmissionType.BASELINE) {
            patient.setCurrentCycleStartDate(LocalDateTime.now());
        }
        boolean redFlagTriggered = isUrgentRedFlag(saved.getTotalScore());
        boolean clinicalAttention = isClinicalAttention(saved.getTotalScore());
        if (redFlagTriggered) {
            patient.setStatus(com.reconnect.mindhealth.modules.clinical.enums.Status.WARNING);
            patient.setIsRedFlagActive(true);
            patient.setCurrentRiskScore(Math.max(patient.getCurrentRiskScore() != null ? patient.getCurrentRiskScore() : 0, 100));
            clinicalTriageService.openUrgentTriage(patient);
            log.warn("LSAS urgent red flag triggered patientId={}, totalScore={}, route={}, clinicalAttention={}",
                    patient.getId(), saved.getTotalScore(), resolveClinicalRoute(saved.getTotalScore()), clinicalAttention);
        }
        patientProfileRepository.save(patient);

        if (type == LsasSubmissionType.BASELINE) {
            List<?> ladder = fearLadderService.rebuildFromBaseline(patient, answers);
            log.info("LSAS baseline triggered fear ladder rebuild patientId={}, ladderItems={}",
                    patient.getId(),
                    ladder != null ? ladder.size() : 0);
        }

        boolean tipsOnly = "REASSURANCE".equals(resolveClinicalRoute(saved.getTotalScore()));
        boolean exerciseFlowEnabled = !tipsOnly;
        log.info("LSAS submitted patientId={}, type={}, fearTotal={}, avoidanceTotal={}, totalScore={}, severityBand={}, severityLabel={}, clinicalRoute={}, clinicalAttention={}, redFlagTriggered={}, tipsOnly={}, exerciseFlowEnabled={}",
                patient.getId(),
                type,
                fearTotal,
                avoidanceTotal,
                saved.getTotalScore(),
                resolveSeverityBand(saved.getTotalScore()),
                resolveSeverityLabel(saved.getTotalScore()),
                resolveClinicalRoute(saved.getTotalScore()),
                clinicalAttention,
                redFlagTriggered,
                tipsOnly,
                exerciseFlowEnabled);
        return toSubmissionDto(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isLsasOnCoolDown(UUID patientId) {
        PatientProfile patient = patientProfileRepository.findById(patientId).orElse(null);
        if (patient == null) {
            User user = userRepository.findById(patientId)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user: " + patientId));
            if (user.getRole() == Role.GUEST) {
                return false;
            }
            throw new EntityNotFoundException("Kh?ng t?m th?y b?nh nh?n: " + patientId);
        }
        if (patient.getLastLsasDate() == null) {
            return false;
        }
        return patient.getLastLsasDate().isAfter(LocalDateTime.now().minusDays(14));
    }

    @Override
    @Transactional(readOnly = true)
    public List<LsasSubmissionDto> getLsasHistory(UUID patientId) {
        PatientProfile patient = patientProfileRepository.findById(patientId).orElse(null);
        if (patient == null) {
            User user = userRepository.findById(patientId)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user: " + patientId));
            if (user.getRole() == Role.GUEST) {
                return List.of();
            }
            throw new EntityNotFoundException("Kh?ng t?m th?y b?nh nh?n: " + patientId);
        }
        return lsasSubmissionRepository.findByPatientProfile_IdOrderByCreateDateDesc(patientId)
                .stream()
                .map(this::toSubmissionDto)
                .toList();
    }

    private LsasSubmissionDto saveGuestLsas(User guestUser, LsasSubmissionDto dto) {
        GuestProfile guestProfile = guestProfileRepository.findById(guestUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ guest: " + guestUser.getId()));

        int fearTotal = 0;
        int avoidanceTotal = 0;
        for (LsasAnswerRequestDto answerDto : dto.getAnswers()) {
            normalizeLsasScore(answerDto.getFearScore());
            normalizeLsasScore(answerDto.getAvoidanceScore());
            fearTotal += answerDto.getFearScore();
            avoidanceTotal += answerDto.getAvoidanceScore();
        }
        int totalScore = fearTotal + avoidanceTotal;

        guestProfile.setLsasDemoCompleted(true);
        guestProfile.setPendingLsasTotalScore(totalScore);
        guestProfile.setPendingLsasSubmissionType(LsasSubmissionType.BASELINE.name());
        guestProfile.setPendingLsasCompletedAt(LocalDateTime.now());
        guestProfile.setPendingLsasAnswersJson(writeGuestLsasAnswers(dto.getAnswers()));
        guestProfileRepository.save(guestProfile);

        LsasSubmissionDto result = new LsasSubmissionDto();
        result.setPatientId(guestUser.getId());
        result.setSubmissionType(LsasSubmissionType.BASELINE);
        result.setFearTotal(fearTotal);
        result.setAvoidanceTotal(avoidanceTotal);
        result.setTotalScore(totalScore);
        result.setAnswers(dto.getAnswers());
        result.setSeverityBand(resolveSeverityBand(totalScore));
        result.setSeverityLabel(resolveSeverityLabel(totalScore));
        result.setClinicalRoute(resolveClinicalRoute(totalScore));
        result.setSummaryMessage(buildSummaryMessage(totalScore));
        result.setRecommendedNextStep(buildRecommendedNextStep(totalScore));
        result.setClinicalAttention(isClinicalAttention(totalScore));
        result.setRedFlagTriggered(false);
        result.setNextEligibleAt(null);

        log.info("Guest LSAS submitted guestId={}, totalScore={}, severityBand={}, clinicalRoute={}",
                guestUser.getId(),
                totalScore,
                result.getSeverityBand(),
                result.getClinicalRoute());
        return result;
    }

    private String writeGuestLsasAnswers(List<LsasAnswerRequestDto> answers) {
        try {
            return objectMapper.writeValueAsString(answers);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Không thể lưu tạm câu trả lời LSAS của guest.", exception);
        }
    }

    @Override
    @Transactional
    public UserMoodDto saveUserMood(UserMoodDto dto) {
        PatientProfile patient = patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> new EntityNotFoundException("Kh?ng t?m th?y b?nh nh?n: " + dto.getPatientId()));
        UserMood userMood = new UserMood();
        userMood.setPatientProfile(patient);
        Integer anxietyScore = normalizePercentageScore(dto.getAnxietyScore(), "anxietyScore");
        Integer avoidanceUrgeScore = normalizePercentageScore(dto.getAvoidanceUrgeScore(), "avoidanceUrgeScore");
        Integer sadnessScore = normalizePercentageScore(dto.getSadnessScore(), "sadnessScore");
        Integer anticipatoryAnxietyScore = normalizeEightPointScore(dto.getAnticipatoryAnxietyScore(),
                "anticipatoryAnxietyScore");
        Integer postEventRuminationScore = normalizeEightPointScore(dto.getPostEventRuminationScore(),
                "postEventRuminationScore");
        Boolean safetyCheckRequired = Boolean.TRUE.equals(dto.getSafetyCheckRequired());
        String safetyResponse = normalizeSafetyResponse(dto.getSafetyResponse(), safetyCheckRequired);
        userMood.setAnxietyScore(anxietyScore);
        userMood.setAvoidanceUrgeScore(avoidanceUrgeScore);
        userMood.setSadnessScore(sadnessScore);
        userMood.setAnticipatoryAnxietyScore(anticipatoryAnxietyScore);
        userMood.setPostEventRuminationScore(postEventRuminationScore);
        userMood.setSafetyCheckRequired(safetyCheckRequired);
        userMood.setSafetyResponse(safetyResponse);
        userMood.setSafetyRespondedAt(safetyCheckRequired ? LocalDateTime.now() : null);
        userMood.setMoodScore(resolveLegacyMoodScore(dto, anxietyScore));
        userMood.setDailyAgenda(dto.getDailyAgenda());
        UserMood saved = userMoodRepository.save(userMood);
        riskScoringService.calculateAndPersist(patient.getId());
        return new UserMoodDto(saved);
    }

    private Integer resolveLegacyMoodScore(UserMoodDto dto, Integer anxietyScore) {
        if (dto.getMoodScore() != null) {
            return normalizePercentageScore(dto.getMoodScore(), "moodScore");
        }
        if (anxietyScore == null) {
            return null;
        }
        return 100 - anxietyScore;
    }

    private Integer normalizePercentageScore(Integer score, String fieldName) {
        if (score == null) {
            return null;
        }
        if (score < 0 || score > 100) {
            throw new IllegalArgumentException(fieldName + " phai nam trong khoang 0-100.");
        }
        return score;
    }

    private Integer normalizeEightPointScore(Integer score, String fieldName) {
        if (score == null) {
            return null;
        }
        if (score < 0 || score > 8) {
            throw new IllegalArgumentException(fieldName + " phai nam trong khoang 0-8.");
        }
        return score;
    }

    private String normalizeSafetyResponse(String safetyResponse, boolean safetyCheckRequired) {
        if (!safetyCheckRequired) {
            return null;
        }
        if (safetyResponse == null || safetyResponse.isBlank()) {
            throw new IllegalArgumentException("safetyResponse khong duoc de trong khi safetyCheckRequired = true.");
        }
        String normalized = safetyResponse.trim().toUpperCase();
        if (!"SAFE".equals(normalized) && !"UNSAFE".equals(normalized)) {
            throw new IllegalArgumentException("safetyResponse chi duoc la SAFE hoac UNSAFE.");
        }
        return normalized;
    }

    private void validateUniqueSituations(List<LsasAnswerRequestDto> answers) {
        Set<UUID> seen = new HashSet<>();
        for (LsasAnswerRequestDto answer : answers) {
            if (answer.getSituationId() == null) {
                throw new IllegalArgumentException("Thi?u situationId trong c?u tr? l?i LSAS.");
            }
            if (!seen.add(answer.getSituationId())) {
                throw new IllegalArgumentException("LSAS kh?ng ???c ch?a situation tr?ng l?p.");
            }
        }
    }

    private int normalizeLsasScore(Integer score) {
        if (score == null) {
            throw new IllegalArgumentException("Fear/Avoidance score kh?ng ???c ?? tr?ng.");
        }
        if (score < 0 || score > 3) {
            throw new IllegalArgumentException("Fear/Avoidance score ph?i n?m trong kho?ng 0-3.");
        }
        return score;
    }

    private LsasSubmissionDto toSubmissionDto(LsasSubmission submission) {
        LsasSubmissionDto dto = new LsasSubmissionDto(submission);
        Integer totalScore = submission.getTotalScore();
        dto.setSeverityBand(resolveSeverityBand(totalScore));
        dto.setSeverityLabel(resolveSeverityLabel(totalScore));
        dto.setClinicalRoute(resolveClinicalRoute(totalScore));
        dto.setSummaryMessage(buildSummaryMessage(totalScore));
        dto.setRecommendedNextStep(buildRecommendedNextStep(totalScore));
        dto.setClinicalAttention(isClinicalAttention(totalScore));
        dto.setRedFlagTriggered(isUrgentRedFlag(totalScore));
        dto.setNextEligibleAt(submission.getUnlockedAt());
        return dto;
    }

    private String resolveSeverityBand(Integer totalScore) {
        int safeScore = totalScore == null ? 0 : totalScore;
        if (safeScore >= 90) {
            return "VERY_SEVERE_IMPAIRMENT";
        }
        if (safeScore >= 60) {
            return "MARKED_SOCIAL_ANXIETY";
        }
        if (safeScore >= 30) {
            return "MILD_TO_MODERATE";
        }
        return "UNLIKELY_SAD";
    }

    private String resolveSeverityLabel(Integer totalScore) {
        int safeScore = totalScore == null ? 0 : totalScore;
        if (safeScore >= 90) {
            return "Rất nặng và suy giảm chức năng";
        }
        if (safeScore >= 60) {
            return "Lo âu xã hội rõ rệt";
        }
        if (safeScore >= 30) {
            return "Lo âu nhẹ đến vừa";
        }
        return "Rất ít khả năng mắc";
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

    private String buildSummaryMessage(Integer totalScore) {
        int safeScore = totalScore == null ? 0 : totalScore;
        return "%d/144: Bạn đang ở mức %s. %s".formatted(
                safeScore,
                resolveSeverityLabel(safeScore).toLowerCase(),
                switch (resolveClinicalRoute(safeScore)) {
                    case "SELF_HELP" -> "Đây là nhóm phù hợp với luồng tự trị liệu trên app.";
                    case "THERAPIST_TRACK_14_WEEKS" -> "Nhóm này cần đi theo lộ trình 14 tuần chuyên sâu cùng bác sĩ.";
                    case "URGENT_RED_FLAG" -> "Hệ thống sẽ ưu tiên đánh giá an toàn và theo dõi lâm sàng khẩn cấp.";
                    default -> "Hệ thống sẽ cung cấp thông điệp an tâm và mẹo chăm sóc tinh thần cơ bản.";
                });
    }

    private String buildRecommendedNextStep(Integer totalScore) {
        return switch (resolveClinicalRoute(totalScore)) {
            case "SELF_HELP" ->
                "App sẽ mở luồng tự trị liệu với psychoeducation, Thought Record, Fear Ladder, Coping Cards, Daily Check-in và các công cụ thư giãn/chánh niệm.";
            case "THERAPIST_TRACK_14_WEEKS" ->
                "Hệ thống sẽ ưu tiên lộ trình CBT 14 tuần chuyên sâu, gợi ý ghép cặp với bác sĩ và tiếp tục Fear Ladder theo trị liệu có hướng dẫn.";
            case "URGENT_RED_FLAG" ->
                "Hệ thống sẽ bật cờ đỏ khẩn cấp, ưu tiên theo dõi lâm sàng và đẩy cảnh báo lên dashboard bác sĩ.";
            default ->
                "App sẽ hiển thị thông điệp an tâm, cùng các mẹo chăm sóc tinh thần cơ bản để bạn tự theo dõi thêm.";
        };
    }

    private boolean isUrgentRedFlag(Integer totalScore) {
        int safeScore = totalScore == null ? 0 : totalScore;
        return safeScore >= 90;
    }

    private boolean isClinicalAttention(Integer totalScore) {
        int safeScore = totalScore == null ? 0 : totalScore;
        return safeScore >= 95;
    }
}
