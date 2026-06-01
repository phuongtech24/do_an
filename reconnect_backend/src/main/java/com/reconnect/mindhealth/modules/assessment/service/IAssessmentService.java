package com.reconnect.mindhealth.modules.assessment.service;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.reconnect.mindhealth.modules.assessment.dto.Phq9QuestionDto;
import com.reconnect.mindhealth.modules.assessment.dto.Phq9SubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;

public interface IAssessmentService {
    // Nộp bài test PHQ-9 (submitPhq9).
    Phq9SubmissionDto submitPhq9(Phq9SubmissionDto dto);

    // Kiểm tra xem bệnh nhân có đang trong thời gian khóa 14 ngày không (checkPhq9Cooldown).
    boolean isPhq9OnCoolDown(UUID patientId);

    List<Phq9SubmissionDto> getPhq9History(UUID patientId);

    // Ghi nhận tâm trạng hàng ngày (saveUserMood).
    UserMoodDto saveUserMood(UserMoodDto dto);

    // Lấy bộ câu hỏi và đáp án PHQ-9 cố định từ file CSV
    Map<String, Object> getPhq9Questionnaire();

    // Lưu (Thêm mới hoặc Cập nhật) câu hỏi PHQ-9
    Phq9QuestionDto savePhq9Question(Phq9QuestionDto dto);
}
