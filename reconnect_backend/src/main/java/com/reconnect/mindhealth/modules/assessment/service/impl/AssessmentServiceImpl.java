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
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
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
    private final FearLadderService fearLadderService;
    private final IRiskScoringService riskScoringService;

    public AssessmentServiceImpl(
            LsasSituationRepository lsasSituationRepository,
            LsasSubmissionRepository lsasSubmissionRepository,
            UserMoodRepository userMoodRepository,
            PatientProfileRepository patientProfileRepository,
            FearLadderService fearLadderService,
            IRiskScoringService riskScoringService) {
        this.lsasSituationRepository = lsasSituationRepository;
        this.lsasSubmissionRepository = lsasSubmissionRepository;
        this.userMoodRepository = userMoodRepository;
        this.patientProfileRepository = patientProfileRepository;
        this.fearLadderService = fearLadderService;
        this.riskScoringService = riskScoringService;
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
        PatientProfile patient = patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> new EntityNotFoundException("KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y bÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡nh nhÃƒÆ’Ã‚Â¢n: " + dto.getPatientId()));

        if (dto.getAnswers() == null || dto.getAnswers().size() != 24) {
            throw new IllegalArgumentException("LSAS cÃƒÂ¡Ã‚ÂºÃ‚Â§n Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã‚Â§ 24 cÃƒÆ’Ã‚Â¢u trÃƒÂ¡Ã‚ÂºÃ‚Â£ lÃƒÂ¡Ã‚Â»Ã‚Âi.");
        }
        validateUniqueSituations(dto.getAnswers());

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
                    .orElseThrow(() -> new EntityNotFoundException("KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y tÃƒÆ’Ã‚Â¬nh huÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœng LSAS."));
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
        if (patient.getCurrentCycleStartDate() == null || type == LsasSubmissionType.BASELINE) {
            patient.setCurrentCycleStartDate(LocalDateTime.now());
        }
        boolean redFlagTriggered = isUrgentRedFlag(saved.getTotalScore());
        boolean clinicalAttention = isClinicalAttention(saved.getTotalScore());
        if (redFlagTriggered) {
            patient.setStatus(com.reconnect.mindhealth.modules.clinical.enums.Status.WARNING);
            patient.setIsRedFlagActive(true);
            patient.setCurrentRiskScore(Math.max(patient.getCurrentRiskScore() != null ? patient.getCurrentRiskScore() : 0, 100));
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
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y bÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡nh nhÃƒÆ’Ã‚Â¢n: " + patientId));
        if (patient.getLastLsasDate() == null) {
            return false;
        }
        return patient.getLastLsasDate().isAfter(LocalDateTime.now().minusDays(14));
    }

    @Override
    @Transactional(readOnly = true)
    public List<LsasSubmissionDto> getLsasHistory(UUID patientId) {
        patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y bÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡nh nhÃƒÆ’Ã‚Â¢n: " + patientId));
        return lsasSubmissionRepository.findByPatientProfile_IdOrderByCreateDateDesc(patientId)
                .stream()
                .map(this::toSubmissionDto)
                .toList();
    }

    @Override
    @Transactional
    public UserMoodDto saveUserMood(UserMoodDto dto) {
        PatientProfile patient = patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> new EntityNotFoundException("KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y bÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡nh nhÃƒÆ’Ã‚Â¢n: " + dto.getPatientId()));
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
                throw new IllegalArgumentException("ThiÃƒÂ¡Ã‚ÂºÃ‚Â¿u situationId trong cÃƒÆ’Ã‚Â¢u trÃƒÂ¡Ã‚ÂºÃ‚Â£ lÃƒÂ¡Ã‚Â»Ã‚Âi LSAS.");
            }
            if (!seen.add(answer.getSituationId())) {
                throw new IllegalArgumentException("LSAS khÃƒÆ’Ã‚Â´ng Ãƒâ€žÃ¢â‚¬ËœÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Â£c chÃƒÂ¡Ã‚Â»Ã‚Â©a situation trÃƒÆ’Ã‚Â¹ng lÃƒÂ¡Ã‚ÂºÃ‚Â·p.");
            }
        }
    }

    private int normalizeLsasScore(Integer score) {
        if (score == null) {
            throw new IllegalArgumentException("Fear/Avoidance score khÃƒÆ’Ã‚Â´ng Ãƒâ€žÃ¢â‚¬ËœÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Â£c Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã†â€™ trÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœng.");
        }
        if (score < 0 || score > 3) {
            throw new IllegalArgumentException("Fear/Avoidance score phÃƒÂ¡Ã‚ÂºÃ‚Â£i nÃƒÂ¡Ã‚ÂºÃ‚Â±m trong khoÃƒÂ¡Ã‚ÂºÃ‚Â£ng 0-3.");
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
            return "RÃ¡ÂºÂ¥t nÃ¡ÂºÂ·ng vÃƒÂ  suy giÃ¡ÂºÂ£m chÃ¡Â»Â©c nÃ„Æ’ng";
        }
        if (safeScore >= 60) {
            return "Lo ÃƒÂ¢u xÃƒÂ£ hÃ¡Â»â„¢i rÃƒÂµ rÃ¡Â»â€¡t";
        }
        if (safeScore >= 30) {
            return "Lo ÃƒÂ¢u nhÃ¡ÂºÂ¹ Ã„â€˜Ã¡ÂºÂ¿n vÃ¡Â»Â«a";
        }
        return "RÃ¡ÂºÂ¥t ÃƒÂ­t khÃ¡ÂºÂ£ nÃ„Æ’ng mÃ¡ÂºÂ¯c";
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
        return "%d/144: BÃ¡ÂºÂ¡n Ã„â€˜ang Ã¡Â»Å¸ mÃ¡Â»Â©c %s. %s".formatted(
                safeScore,
                resolveSeverityLabel(safeScore).toLowerCase(),
                switch (resolveClinicalRoute(safeScore)) {
                    case "SELF_HELP" -> "Ã„ÂÃƒÂ¢y lÃƒÂ  nhÃƒÂ³m phÃƒÂ¹ hÃ¡Â»Â£p vÃ¡Â»â€ºi luÃ¡Â»â€œng tÃ¡Â»Â± trÃ¡Â»â€¹ liÃ¡Â»â€¡u trÃƒÂªn app.";
                    case "THERAPIST_TRACK_14_WEEKS" -> "NhÃƒÂ³m nÃƒÂ y cÃ¡ÂºÂ§n Ã„â€˜i theo lÃ¡Â»â„¢ trÃƒÂ¬nh 14 tuÃ¡ÂºÂ§n chuyÃƒÂªn sÃƒÂ¢u cÃƒÂ¹ng bÃƒÂ¡c sÃ„Â©.";
                    case "URGENT_RED_FLAG" -> "HÃ¡Â»â€¡ thÃ¡Â»â€˜ng Ã†Â°u tiÃƒÂªn Ã„â€˜ÃƒÂ¡nh giÃƒÂ¡ an toÃƒÂ n vÃƒÂ  theo dÃƒÂµi lÃƒÂ¢m sÃƒÂ ng khÃ¡ÂºÂ©n cÃ¡ÂºÂ¥p.";
                    default -> "HÃ¡Â»â€¡ thÃ¡Â»â€˜ng sÃ¡ÂºÂ½ cung cÃ¡ÂºÂ¥p thÃƒÂ´ng Ã„â€˜iÃ¡Â»â€¡p an tÃƒÂ¢m vÃƒÂ  mÃ¡ÂºÂ¹o chÃ„Æ’m sÃƒÂ³c tinh thÃ¡ÂºÂ§n cÃ†Â¡ bÃ¡ÂºÂ£n.";
                });
    }

    private String buildRecommendedNextStep(Integer totalScore) {
        return switch (resolveClinicalRoute(totalScore)) {
            case "SELF_HELP" ->
                "App sÃ¡ÂºÂ½ mÃ¡Â»Å¸ luÃ¡Â»â€œng tÃ¡Â»Â± trÃ¡Â»â€¹ liÃ¡Â»â€¡u vÃ¡Â»â€ºi psychoeducation, Thought Record, Fear Ladder, Coping Cards, Daily Check-in vÃƒÂ  cÃƒÂ¡c cÃƒÂ´ng cÃ¡Â»Â¥ thÃ†Â° giÃƒÂ£n/chÃƒÂ¡nh niÃ¡Â»â€¡m.";
            case "THERAPIST_TRACK_14_WEEKS" ->
                "HÃ¡Â»â€¡ thÃ¡Â»â€˜ng sÃ¡ÂºÂ½ Ã†Â°u tiÃƒÂªn lÃ¡Â»â„¢ trÃƒÂ¬nh CBT 14 tuÃ¡ÂºÂ§n chuyÃƒÂªn sÃƒÂ¢u, gÃ¡Â»Â£i ÃƒÂ½ ghÃƒÂ©p cÃ¡ÂºÂ·p vÃ¡Â»â€ºi bÃƒÂ¡c sÃ„Â© vÃƒÂ  tiÃ¡ÂºÂ¿p tÃ¡Â»Â¥c Fear Ladder theo trÃ¡Â»â€¹ liÃ¡Â»â€¡u cÃƒÂ³ hÃ†Â°Ã¡Â»â€ºng dÃ¡ÂºÂ«n.";
            case "URGENT_RED_FLAG" ->
                "HÃ¡Â»â€¡ thÃ¡Â»â€˜ng sÃ¡ÂºÂ½ bÃ¡ÂºÂ­t cÃ¡Â»Â Ã„â€˜Ã¡Â»Â khÃ¡ÂºÂ©n cÃ¡ÂºÂ¥p, Ã†Â°u tiÃƒÂªn theo dÃƒÂµi lÃƒÂ¢m sÃƒÂ ng vÃƒÂ  Ã„â€˜Ã¡ÂºÂ©y cÃ¡ÂºÂ£nh bÃƒÂ¡o lÃƒÂªn dashboard bÃƒÂ¡c sÃ„Â©.";
            default ->
                "App sÃ¡ÂºÂ½ hiÃ¡Â»Æ’n thÃ¡Â»â€¹ thÃƒÂ´ng Ã„â€˜iÃ¡Â»â€¡p an tÃƒÂ¢m, cÃƒÂ¹ng cÃƒÂ¡c mÃ¡ÂºÂ¹o chÃ„Æ’m sÃƒÂ³c tinh thÃ¡ÂºÂ§n cÃ†Â¡ bÃ¡ÂºÂ£n Ã„â€˜Ã¡Â»Æ’ bÃ¡ÂºÂ¡n tÃ¡Â»Â± theo dÃƒÂµi thÃƒÂªm.";
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
