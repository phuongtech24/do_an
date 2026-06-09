package com.reconnect.mindhealth.modules.assessment.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSituationDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;

@RestController
@RequestMapping("/api/assessment")
public class AssessmentController {

    private final IAssessmentService assessmentService;

    public AssessmentController(IAssessmentService assessmentService) {
        this.assessmentService = assessmentService;
    }

    @GetMapping("/lsas/situations")
    public ResponseEntity<ApiResponse<List<LsasSituationDto>>> getLsasSituations() {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", assessmentService.getLsasSituations()));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/lsas/submissions")
    public ResponseEntity<ApiResponse<LsasSubmissionDto>> submitLsas(@RequestBody LsasSubmissionDto dto) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Nộp LSAS thành công.", assessmentService.submitLsas(dto)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/lsas/cooldown")
    public ResponseEntity<ApiResponse<Boolean>> isLsasOnCoolDown(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", assessmentService.isLsasOnCoolDown(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/lsas/history")
    public ResponseEntity<ApiResponse<List<LsasSubmissionDto>>> getLsasHistory(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", assessmentService.getLsasHistory(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/mood")
    public ResponseEntity<ApiResponse<UserMoodDto>> submitUserMood(@RequestBody UserMoodDto dto) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Ghi nhận tâm trạng thành công.", assessmentService.saveUserMood(dto)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }
}
