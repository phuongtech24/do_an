package com.reconnect.mindhealth.modules.assessment.controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.assessment.dto.Phq9QuestionDto;
import com.reconnect.mindhealth.modules.assessment.dto.Phq9SubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;

@RestController
@RequestMapping("/api/assessment")
public class AssessmentController {

    @Autowired
    private IAssessmentService assessmentService;

    @PostMapping("/phq9")
    public ResponseEntity<ApiResponse<Phq9SubmissionDto>> submitPhq9(@RequestBody Phq9SubmissionDto dto) {
        try {
            Phq9SubmissionDto result = assessmentService.submitPhq9(dto);
            return ResponseEntity.ok(ApiResponse.success("Nộp bài PHQ-9 thành công!", result));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @GetMapping("/cooldown")
    public ResponseEntity<ApiResponse<Boolean>> isPhq9OnCoolDown(@RequestParam UUID patientId) {
        try {
            boolean isCooldown = assessmentService.isPhq9OnCoolDown(patientId);
            return ResponseEntity.ok(ApiResponse.success("Kiểm tra cooldown thành công!", isCooldown));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @GetMapping("/phq9/history")
    public ResponseEntity<ApiResponse<List<Phq9SubmissionDto>>> getPhq9History(@RequestParam UUID patientId) {
        try {
            List<Phq9SubmissionDto> result = assessmentService.getPhq9History(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy lịch sử PHQ-9 thành công!", result));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch sử PHQ-9: " + e.getMessage()));
        }
    }

    @PostMapping("/mood")
    public ResponseEntity<ApiResponse<UserMoodDto>> submitUserMood(@RequestBody UserMoodDto dto) {
        try {
            UserMoodDto result = assessmentService.saveUserMood(dto);
            return ResponseEntity.ok(ApiResponse.success("Ghi nhận tâm trạng thành công!", result));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @GetMapping("/phq9/questions")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPhq9Questionnaire() {
        try {
            Map<String, Object> result = assessmentService.getPhq9Questionnaire();
            return ResponseEntity.ok(ApiResponse.success("Lấy bộ câu hỏi PHQ-9 thành công!", result));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải bộ câu hỏi: " + e.getMessage()));
        }
    }

    @PostMapping("/phq9/questions/save")
    public ResponseEntity<ApiResponse<Phq9QuestionDto>> savePhq9Question(@RequestBody Phq9QuestionDto dto) {
        try {
            Phq9QuestionDto result = assessmentService.savePhq9Question(dto);
            return ResponseEntity.ok(ApiResponse.success("Lưu câu hỏi PHQ-9 thành công!", result));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi lưu câu hỏi: " + e.getMessage()));
        }
    }
}
