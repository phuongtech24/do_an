package com.reconnect.mindhealth.modules.assessment.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.Calendar;
import java.util.Date;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.assessment.dto.Phq9QuestionDto;
import com.reconnect.mindhealth.modules.assessment.dto.Phq9SubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;
import com.reconnect.mindhealth.modules.assessment.entity.Phq9Submission;
import com.reconnect.mindhealth.modules.assessment.entity.Phq9Question;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.enums.Phq9Type;
import com.reconnect.mindhealth.modules.assessment.enums.SeverityLevel;
import com.reconnect.mindhealth.modules.assessment.repository.Phq9Repository;
import com.reconnect.mindhealth.modules.assessment.repository.Phq9QuestionRepository;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AssessmentServiceImpl implements IAssessmentService {

    private static final Logger log = LoggerFactory.getLogger(AssessmentServiceImpl.class);

    @Autowired
    private Phq9Repository phq9Repository;

    @Autowired
    private UserMoodRepository userMoodRepository;

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private Phq9QuestionRepository phq9QuestionRepository;

    @Autowired
    private RoadmapDailyAssignmentService roadmapDailyAssignmentService;

    @Override
    public Phq9SubmissionDto submitPhq9(Phq9SubmissionDto dto) {
        log.info("AssessmentService: Received PHQ-9 submission request for patient: {}", dto.getPatientId());

        PatientProfile patientProfile = this.patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> {
                    log.error("AssessmentService: Patient profile not found for ID: {}", dto.getPatientId());
                    return new EntityNotFoundException("B?nh nh?n kh?ng t?n t?i v?i ID: " + dto.getPatientId());
                });
        
        List<Integer> answers = dto.getAnswers();
        if (answers == null || answers.size() != 9) {
            log.error("AssessmentService: Invalid number of answers. Expected 9, got {}", answers == null ? "null" : answers.size());
            throw new IllegalArgumentException("B?i test PHQ-9 b?t bu?c ph?i c? ??ng 9 c?u tr? l?i.");
        }
        for (Integer score : answers) {
            if (score == null || score < 0 || score > 3) {
                log.error("AssessmentService: Answer score out of bounds: {}", score);
                throw new IllegalArgumentException("?i?m c?a t?ng c?u tr? l?i ph?i n?m trong kho?ng t? 0 ??n 3.");
            }
        }

        // 2. T?nh to?n ?i?m l?m s?ng
        Integer functionalDifficultyScore = dto.getFunctionalDifficultyScore();
        if (functionalDifficultyScore != null && (functionalDifficultyScore < 1 || functionalDifficultyScore > 4)) {
            log.error("AssessmentService: Functional difficulty score out of bounds: {}", functionalDifficultyScore);
            throw new IllegalArgumentException("?i?m m?c ?? ?nh h??ng ch?c n?ng ph?i n?m trong kho?ng t? 1 ??n 4.");
        }

        int totalScore = 0;
        for (Integer score : answers) {
            totalScore += score;
        }
        // BRD: q2_score is PHQ-9 question #2 only (0-3)
        int q2Score = answers.get(1);
        int q9Score = answers.get(8);

        // 3. Ph?n lo?i m?c ?? tr?m c?m
        SeverityLevel severityLevel;
        if (totalScore <= 4) {
            severityLevel = SeverityLevel.MINIMAL;
        } else if (totalScore <= 9) {
            severityLevel = SeverityLevel.MILD;
        } else if (totalScore <= 14) {
            severityLevel = SeverityLevel.MODERATE;
        } else if (totalScore <= 19) {
            severityLevel = SeverityLevel.MODERATELY_SEVERE;
        } else {
            severityLevel = SeverityLevel.SEVERE;
        }

        log.info("AssessmentService: Calculated PHQ-9 clinical metrics - Total Score: {}, Q2 Score: {}, Q9 Score: {}, Severity Level: {}",
                totalScore, q2Score, q9Score, severityLevel);

        // 3.5 Resolve submission type (Baseline first-time only)
        boolean hasBaseline = phq9Repository.existsByPatientProfile_IdAndSubmissionType(patientProfile.getId(),
                Phq9Type.BASELINE);
        Phq9Type effectiveSubmissionType = dto.getSubmissionType();
        if (!hasBaseline) {
            effectiveSubmissionType = Phq9Type.BASELINE;
        } else if (effectiveSubmissionType == null) {
            effectiveSubmissionType = Phq9Type.PERIODIC;
        } else if (effectiveSubmissionType == Phq9Type.BASELINE) {
            throw new IllegalArgumentException("B?i test Baseline PHQ-9 ch? ???c th?c hi?n duy nh?t 1 l?n (ng?y ??u).");
        }

        // 4. K?ch ho?t C?nh b?o ?? (Red Flag) n?u ph?t hi?n nguy c? t? h?i ? c?u s? 9
        if (q9Score > 0) {
            log.warn("AssessmentService: RED FLAG CRITICAL WARNING triggered for patient ID: {}. Suicidal ideation score (Q9) is positive: {}", 
                    patientProfile.getId(), q9Score);
            patientProfile.setIsRedFlagActive(true);
            patientProfile.setStatus(Status.WARNING);
        }
        patientProfile.setLastPhq9Date(LocalDateTime.now());
        patientProfileRepository.save(patientProfile);

        // 5. L?u b?i test PHQ-9 m?i
        Phq9Submission submission = new Phq9Submission();
        submission.setPatientProfile(patientProfile);
        submission.setTotalScore(totalScore);
        submission.setQ2Score(q2Score);
        submission.setQ9Score(q9Score);
        submission.setFunctionalDifficultyScore(functionalDifficultyScore);
        submission.setSubmissionType(effectiveSubmissionType);
        submission.setSeverityLevel(severityLevel);
        submission.setUnlockedAt(effectiveSubmissionType == Phq9Type.TRIGGERED ? LocalDateTime.now()
                : LocalDateTime.now().plusDays(14));

        // N?n danh s?ch c?u tr? l?i List<Integer> th?nh m?ng String JSON
        ObjectMapper mapper = new ObjectMapper();
        try {
            String jsonString = mapper.writeValueAsString(answers);
            submission.setAnswersJson(jsonString);
        } catch (Exception e) {
            log.error("AssessmentService: Failed to serialize answers list to JSON string", e);
            throw new IllegalArgumentException("Kh?ng th? n?n danh s?ch c?u tr? l?i th?nh JSON String", e);
        }

        Phq9Submission savedSubmission = phq9Repository.save(submission);
        log.info("AssessmentService: PHQ-9 submission successfully saved into database with ID: {}", savedSubmission.getId());

        try {
            LocalDate today = LocalDate.now(ZoneId.of("Asia/Bangkok"));
            int created = roadmapDailyAssignmentService.ensureDailySystemQuests(patientProfile, today).size();
            log.info("AssessmentService: Daily CBT roadmap ensured after PHQ-9 patientId={}, date={}, created={}",
                    patientProfile.getId(), today, created);
        } catch (Exception e) {
            log.warn("AssessmentService: Could not auto-create daily CBT quests after PHQ-9 patientId={}, reason={}",
                    patientProfile.getId(), e.getMessage());
        }

        // Graduation rule (BRD): 2 consecutive PERIODIC submissions with totalScore < 5
        boolean graduatedNow = false;
        if (effectiveSubmissionType == Phq9Type.PERIODIC && totalScore < 5) {
            try {
                List<Phq9Submission> lastTwo = phq9Repository
                        .findTop2ByPatientProfile_IdAndSubmissionTypeOrderByCreateDateDesc(patientProfile.getId(),
                                Phq9Type.PERIODIC);
                if (lastTwo != null && lastTwo.size() >= 2) {
                    Integer s1 = lastTwo.get(0).getTotalScore();
                    Integer s2 = lastTwo.get(1).getTotalScore();
                    boolean bothMinimal = (s1 != null && s1 < 5) && (s2 != null && s2 < 5);
                    if (bothMinimal && patientProfile.getTaperingStage() == TaperingStage.NONE) {
                        patientProfile.setTaperingStage(TaperingStage.WEEKLY);
                        if (patientProfile.getGraduatedAt() == null) {
                            patientProfile.setGraduatedAt(LocalDateTime.now());
                        }
                        patientProfileRepository.save(patientProfile);
                        graduatedNow = true;
                        log.info("AssessmentService: Patient {} graduated. Tapering stage set to WEEKLY.",
                                patientProfile.getId());
                    }
                }
            } catch (Exception e) {
                log.warn("AssessmentService: Graduation evaluation failed: {}", e.getMessage());
            }
        }

        Phq9SubmissionDto out = new Phq9SubmissionDto(savedSubmission);
        out.setGraduatedNow(graduatedNow);
        out.setTaperingStage(patientProfile.getTaperingStage());
        return out;
    }

    @Override
    public boolean isPhq9OnCoolDown(UUID patientId) {
        log.info("AssessmentService: Checking PHQ-9 14-day cooldown for patient: {}", patientId);

        PatientProfile patientProfile = this.patientProfileRepository.findById(patientId)
                .orElseThrow(() -> {
                    log.error("AssessmentService: Patient profile not found for ID: {}", patientId);
                    return new EntityNotFoundException("B?nh nh?n kh?ng t?n t?i v?i ID: " + patientId);
                });
        
        if (patientProfile.getLastPhq9Date() == null) {
            log.info("AssessmentService: Patient has never taken PHQ-9 before. Cooldown inactive.");
            return false;
        }
        
        // Tr? v? true n?u l?n l?m g?n nh?t trong v?ng 14 ng?y
        LocalDateTime cooldownLimit = LocalDateTime.now().minusDays(14);
        boolean isCooldownActive = patientProfile.getLastPhq9Date().isAfter(cooldownLimit);
        
        log.info("AssessmentService: Patient last PHQ-9 date: {}. Cooldown Active: {}", 
                patientProfile.getLastPhq9Date(), isCooldownActive);
        
        return isCooldownActive;
    }

    @Override
    public UserMoodDto saveUserMood(UserMoodDto dto) {
        log.info("AssessmentService: Receiving daily mood submission for patient: {}. Mood Score: {}", 
                dto.getPatientId(), dto.getMoodScore());

        PatientProfile patientProfile = this.patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> {
                    log.error("AssessmentService: Patient profile not found for ID: {}", dto.getPatientId());
                    return new EntityNotFoundException("B?nh nh?n kh?ng t?n t?i v?i ID: " + dto.getPatientId());
                });

        // 1. Find today's mood record if exists
        Optional<UserMood> todayMoodOpt = findTodayMoodForPatient(dto.getPatientId());

        UserMood userMood = new UserMood();
        userMood.setPatientProfile(patientProfile);
        userMood.setMoodScore(dto.getMoodScore());
        userMood.setDailyAgenda(dto.getDailyAgenda());

        if (todayMoodOpt.isPresent()) {
            // Found existing: assign ID and creation date to trigger UPDATE
            UserMood existingMood = todayMoodOpt.get();
            userMood.setId(existingMood.getId());
            userMood.setCreateDate(existingMood.getCreateDate());
            log.info("AssessmentService: Existing mood found for today (ID: {}). Performing update.", existingMood.getId());
        } else {
            log.info("AssessmentService: No existing mood found for today. Performing insert.");
        }

        UserMood savedMood = userMoodRepository.save(userMood);
        log.info("AssessmentService: Daily mood log successfully saved/updated with ID: {}", savedMood.getId());
        
        return new UserMoodDto(savedMood);
    }

    /**
     * Helper method to find a patient's mood record for the current day.
     * Extracts date range logic for better readability and unit testing.
     */
    private Optional<UserMood> findTodayMoodForPatient(UUID patientId) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date startOfDay = cal.getTime();

        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        cal.set(Calendar.MILLISECOND, 999);
        Date endOfDay = cal.getTime();

        List<UserMood> existingMoods = userMoodRepository.findMoodByPatientAndDateRange(
                patientId, startOfDay, endOfDay);

        return existingMoods.isEmpty() ? Optional.empty() : Optional.of(existingMoods.get(0));
    }

    @Override
    public Map<String, Object> getPhq9Questionnaire() {
        log.info("AssessmentService: Loading PHQ-9 questionnaire from database...");

        List<Map<String, Object>> questionsList = new java.util.ArrayList<>();

        try {
            List<Phq9Question> questions = phq9QuestionRepository.findAll();
            questions.sort(java.util.Comparator.comparing(Phq9Question::getQuestionNumber));

            for (Phq9Question q : questions) {
                Map<String, Object> question = new java.util.HashMap<>();
                question.put("id", q.getId());
                question.put("questionNumber", q.getQuestionNumber());
                question.put("text", q.getText());
                questionsList.add(question);
            }
        } catch (Exception e) {
            log.error("AssessmentService: Error fetching PHQ-9 questions from database", e);
        }

        if (questionsList.isEmpty()) {
            log.info("AssessmentService: Database is empty. Using static fallback PHQ-9 questions.");
            String[] fallbackTexts = {
                "Ít hứng thú hoặc không có niềm vui khi làm việc gì.",
                "Cảm thấy buồn bã, chán nản hoặc tuyệt vọng.",
                "Khó ngủ, ngủ không yên giấc hoặc ngủ quá nhiều.",
                "Cảm thấy mệt mỏi hoặc có ít năng lượng.",
                "Ăn kém ngon miệng hoặc ăn quá nhiều.",
                "Cảm thấy tệ về bản thân — hoặc nghĩ rằng mình là người thất bại, làm bản thân hoặc gia đình thất vọng.",
                "Khó tập trung vào việc gì đó, chẳng hạn như đọc báo hoặc xem tivi.",
                "Di chuyển hoặc nói chậm đến mức người khác có thể nhận thấy; hoặc ngược lại, bồn chồn, đứng ngồi không yên nhiều hơn bình thường.",
                "Có suy nghĩ rằng mình nên chết đi hoặc muốn tự làm tổn thương bản thân bằng cách nào đó."
            };
            for (int i = 0; i < fallbackTexts.length; i++) {
                Map<String, Object> question = new java.util.HashMap<>();
                question.put("id", UUID.randomUUID());
                question.put("questionNumber", i + 1);
                question.put("text", fallbackTexts[i]);
                questionsList.add(question);
            }
        }

        List<Map<String, Object>> optionsList = new java.util.ArrayList<>();
        String[] optionTexts = {
            "Không hề",
            "Vài ngày",
            "Hơn một nửa số ngày",
            "Gần như mỗi ngày"
        };
        for (int i = 0; i < optionTexts.length; i++) {
            Map<String, Object> option = new java.util.HashMap<>();
            option.put("score", i);
            option.put("text", optionTexts[i]);
            optionsList.add(option);
        }

        List<Map<String, Object>> functionalDifficultyOptions = new java.util.ArrayList<>();
        String[] functionalTexts = {
            "Không khó khăn chút nào",
            "Hơi khó khăn",
            "Rất khó khăn",
            "Cực kỳ khó khăn"
        };
        for (int i = 0; i < functionalTexts.length; i++) {
            Map<String, Object> option = new java.util.HashMap<>();
            option.put("score", i + 1);
            option.put("text", functionalTexts[i]);
            functionalDifficultyOptions.add(option);
        }

        Map<String, Object> questionnaire = new java.util.HashMap<>();
        questionnaire.put("instruction", "Trong 2 tuần qua, bạn bị làm phiền bởi các vấn đề sau thường xuyên như thế nào?");
        questionnaire.put("questions", questionsList);
        questionnaire.put("options", optionsList);
        questionnaire.put("functionalDifficultyQuestion",
                "Nếu bạn đánh dấu có bất kỳ vấn đề nào, các vấn đề này gây khó khăn thế nào cho công việc, việc nhà hoặc việc hòa hợp với người khác?");
        questionnaire.put("functionalDifficultyOptions", functionalDifficultyOptions);
        questionnaire.put("sourceCitation",
                "Kroenke K, Spitzer RL, Williams JB. The PHQ-9: validity of a brief depression severity measure. J Gen Intern Med. 2001 Sep;16(9):606-13. Developed by Drs. Robert L. Spitzer, Janet B.W. Williams, Kurt Kroenke and colleagues, with an educational grant from Pfizer Inc. No permission required to reproduce, translate, display or distribute.");

        log.info("AssessmentService: Loaded {} questions and {} options from database.", questionsList.size(), optionsList.size());
        return questionnaire;
    }
    @Override
    public Phq9QuestionDto savePhq9Question(Phq9QuestionDto dto) {
        log.info("AssessmentService: Received save PHQ-9 question request. ID: {}", dto.getId());

        // Validation ki?m tra h?p l? c?a d? li?u ??u v?o
        if (dto.getQuestionNumber() == null) {
            log.error("AssessmentService: Validation failed - questionNumber is empty.");
            throw new IllegalArgumentException("S? th? t? c?u h?i (questionNumber) kh?ng ???c ph?p r?ng.");
        }
        if (dto.getText() == null || dto.getText().trim().isEmpty()) {
            log.error("AssessmentService: Validation failed - question text is empty.");
            throw new IllegalArgumentException("N?i dung c?u h?i (text) kh?ng ???c ph?p r?ng.");
        }

        Phq9Question question;
        if (dto.getId() != null) {
            // S?a ??i (Update) c?u h?i ?ang t?n t?i
            question = phq9QuestionRepository.findById(dto.getId())
                    .orElseThrow(() -> {
                        log.error("AssessmentService: Question not found with ID: {}", dto.getId());
                        return new EntityNotFoundException("Kh?ng t?m th?y c?u h?i v?i ID: " + dto.getId());
                    });
            log.info("AssessmentService: Updating existing question. Old number: {}, New number: {}", 
                    question.getQuestionNumber(), dto.getQuestionNumber());
        } else {
            // Th?m m?i (Create) c?u h?i
            question = new Phq9Question();
            log.info("AssessmentService: Creating new PHQ-9 question with number: {}", dto.getQuestionNumber());
        }

        // ??ng b? d? li?u t? DTO sang Entity
        question.setQuestionNumber(dto.getQuestionNumber());
        question.setText(dto.getText().trim());

        Phq9Question savedQuestion = phq9QuestionRepository.save(question);
        log.info("AssessmentService: PHQ-9 question successfully saved into database. ID: {}, Number: {}", 
                savedQuestion.getId(), savedQuestion.getQuestionNumber());

        return new Phq9QuestionDto(savedQuestion);
    }
}
