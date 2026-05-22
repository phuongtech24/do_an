package com.reconnect.mindhealth.modules.assessment.service.impl;

import java.time.LocalDateTime;
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

    @Override
    public Phq9SubmissionDto submitPhq9(Phq9SubmissionDto dto) {
        log.info("AssessmentService: Received PHQ-9 submission request for patient: {}", dto.getPatientId());

        PatientProfile patientProfile = this.patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> {
                    log.error("AssessmentService: Patient profile not found for ID: {}", dto.getPatientId());
                    return new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + dto.getPatientId());
                });
        
        List<Integer> answers = dto.getAnswers();
        if (answers == null || answers.size() != 9) {
            log.error("AssessmentService: Invalid number of answers. Expected 9, got {}", answers == null ? "null" : answers.size());
            throw new IllegalArgumentException("Bài test PHQ-9 bắt buộc phải có đúng 9 câu trả lời.");
        }
        for (Integer score : answers) {
            if (score == null || score < 0 || score > 3) {
                log.error("AssessmentService: Answer score out of bounds: {}", score);
                throw new IllegalArgumentException("Điểm của từng câu trả lời phải nằm trong khoảng từ 0 đến 3.");
            }
        }

        // 2. Tính toán điểm lâm sàng
        int totalScore = 0;
        for (Integer score : answers) {
            totalScore += score;
        }
        // BRD: q2_score is PHQ-9 question #2 only (0-3)
        int q2Score = answers.get(1);
        int q9Score = answers.get(8);

        // 3. Phân loại mức độ trầm cảm
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
            throw new IllegalArgumentException("Bài test Baseline PHQ-9 chỉ được thực hiện duy nhất 1 lần (ngày đầu).");
        }

        // 4. Kích hoạt Cảnh báo đỏ (Red Flag) nếu phát hiện nguy cơ tự hại ở câu số 9
        if (q9Score > 0) {
            log.warn("AssessmentService: RED FLAG CRITICAL WARNING triggered for patient ID: {}. Suicidal ideation score (Q9) is positive: {}", 
                    patientProfile.getId(), q9Score);
            patientProfile.setIsRedFlagActive(true);
            patientProfile.setStatus(Status.WARNING);
        }
        patientProfile.setLastPhq9Date(LocalDateTime.now());
        patientProfileRepository.save(patientProfile);

        // 5. Lưu bài test PHQ-9 mới
        Phq9Submission submission = new Phq9Submission();
        submission.setPatientProfile(patientProfile);
        submission.setTotalScore(totalScore);
        submission.setQ2Score(q2Score);
        submission.setQ9Score(q9Score);
        submission.setSubmissionType(effectiveSubmissionType);
        submission.setSeverityLevel(severityLevel);
        submission.setUnlockedAt(effectiveSubmissionType == Phq9Type.TRIGGERED ? LocalDateTime.now()
                : LocalDateTime.now().plusDays(14));

        // Nén danh sách câu trả lời List<Integer> thành mảng String JSON
        ObjectMapper mapper = new ObjectMapper();
        try {
            String jsonString = mapper.writeValueAsString(answers);
            submission.setAnswersJson(jsonString);
        } catch (Exception e) {
            log.error("AssessmentService: Failed to serialize answers list to JSON string", e);
            throw new IllegalArgumentException("Không thể nén danh sách câu trả lời thành JSON String", e);
        }

        Phq9Submission savedSubmission = phq9Repository.save(submission);
        log.info("AssessmentService: PHQ-9 submission successfully saved into database with ID: {}", savedSubmission.getId());

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
                    return new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId);
                });
        
        if (patientProfile.getLastPhq9Date() == null) {
            log.info("AssessmentService: Patient has never taken PHQ-9 before. Cooldown inactive.");
            return false;
        }
        
        // Trả về true nếu lần làm gần nhất trong vòng 14 ngày
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
                    return new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + dto.getPatientId());
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
            
            // Sắp xếp tăng dần theo question_number để thứ tự luôn chuẩn từ 1 đến 9
            questions.sort(java.util.Comparator.comparing(Phq9Question::getQuestionNumber));
            
            for (Phq9Question q : questions) {
                Map<String, Object> question = new java.util.HashMap<>();
                question.put("id", q.getId()); // UUID chính chủ
                question.put("questionNumber", q.getQuestionNumber()); // Số thứ tự câu hỏi (1-9)
                question.put("text", q.getText());
                questionsList.add(question);
            }
        } catch (Exception e) {
            log.error("AssessmentService: Error fetching PHQ-9 questions from database", e);
        }

        // Dự phòng (Fallback) nếu Database chưa được seed hoặc có lỗi kết nối
        if (questionsList.isEmpty()) {
            log.info("AssessmentService: Database is empty. Using static fallback PHQ-9 questions.");
            String[] fallbackTexts = {
                "Ít hứng thú hoặc không có niềm vui khi thực hiện các hoạt động hàng ngày.",
                "Cảm thấy tinh thần đi xuống, trầm cảm, hoặc tuyệt vọng.",
                "Khó ngủ, ngủ chập chờn, hoặc ngủ quá nhiều.",
                "Cảm thấy mệt mỏi hoặc không có năng lượng.",
                "Ăn không ngon miệng hoặc ăn quá nhiều.",
                "Cảm thấy thất vọng về bản thân - hoặc thấy mình là người thất bại, làm gia đình thất vọng.",
                "Gặp khó khăn khi tập trung vào việc gì đó, chẳng hạn như đọc báo hoặc xem tivi.",
                "Di chuyển hoặc nói quá chậm khiến người khác chú ý. Hoặc ngược lại - bồn chồn, đứng ngồi không yên nhiều hơn bình thường.",
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

        // Danh sách các tùy chọn chấm điểm tĩnh của PHQ-9
        List<Map<String, Object>> optionsList = new java.util.ArrayList<>();
        String[] optionTexts = {
            "Không ngày nào",
            "Vài ngày",
            "Hơn nửa số ngày",
            "Gần như hằng ngày"
        };
        for (int i = 0; i < optionTexts.length; i++) {
            Map<String, Object> option = new java.util.HashMap<>();
            option.put("score", i);
            option.put("text", optionTexts[i]);
            optionsList.add(option);
        }

        Map<String, Object> questionnaire = new java.util.HashMap<>();
        questionnaire.put("questions", questionsList);
        questionnaire.put("options", optionsList);

        log.info("AssessmentService: Loaded {} questions and {} options from database.", questionsList.size(), optionsList.size());
        return questionnaire;
    }

    @Override
    public Phq9QuestionDto savePhq9Question(Phq9QuestionDto dto) {
        log.info("AssessmentService: Received save PHQ-9 question request. ID: {}", dto.getId());

        // Validation kiểm tra hợp lệ của dữ liệu đầu vào
        if (dto.getQuestionNumber() == null) {
            log.error("AssessmentService: Validation failed - questionNumber is empty.");
            throw new IllegalArgumentException("Số thứ tự câu hỏi (questionNumber) không được phép rỗng.");
        }
        if (dto.getText() == null || dto.getText().trim().isEmpty()) {
            log.error("AssessmentService: Validation failed - question text is empty.");
            throw new IllegalArgumentException("Nội dung câu hỏi (text) không được phép rỗng.");
        }

        Phq9Question question;
        if (dto.getId() != null) {
            // Sửa đổi (Update) câu hỏi đang tồn tại
            question = phq9QuestionRepository.findById(dto.getId())
                    .orElseThrow(() -> {
                        log.error("AssessmentService: Question not found with ID: {}", dto.getId());
                        return new EntityNotFoundException("Không tìm thấy câu hỏi với ID: " + dto.getId());
                    });
            log.info("AssessmentService: Updating existing question. Old number: {}, New number: {}", 
                    question.getQuestionNumber(), dto.getQuestionNumber());
        } else {
            // Thêm mới (Create) câu hỏi
            question = new Phq9Question();
            log.info("AssessmentService: Creating new PHQ-9 question with number: {}", dto.getQuestionNumber());
        }

        // Đồng bộ dữ liệu từ DTO sang Entity
        question.setQuestionNumber(dto.getQuestionNumber());
        question.setText(dto.getText().trim());

        Phq9Question savedQuestion = phq9QuestionRepository.save(question);
        log.info("AssessmentService: PHQ-9 question successfully saved into database. ID: {}, Number: {}", 
                savedQuestion.getId(), savedQuestion.getQuestionNumber());

        return new Phq9QuestionDto(savedQuestion);
    }
}
