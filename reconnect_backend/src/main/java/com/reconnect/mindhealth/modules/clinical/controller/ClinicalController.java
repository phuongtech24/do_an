package com.reconnect.mindhealth.modules.clinical.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.GoalSettingDto;
import com.reconnect.mindhealth.modules.clinical.dto.OnboardingStatusDto;
import com.reconnect.mindhealth.modules.clinical.service.IClinicalService;

import java.util.UUID;

@RestController
@RequestMapping("/api/clinical")
public class ClinicalController {

    @Autowired
    private IClinicalService clinicalService;

    @PostMapping("/goals")
    public ResponseEntity<ApiResponse<GoalSettingDto>> saveGoals(@RequestBody GoalSettingDto dto) {
        try {
            GoalSettingDto result = clinicalService.saveGoals(dto);
            return ResponseEntity.ok(ApiResponse.success("Lưu mục tiêu trị liệu thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi lưu mục tiêu: " + e.getMessage()));
        }
    }

    @GetMapping("/goals")
    public ResponseEntity<ApiResponse<GoalSettingDto>> getGoals(@RequestParam UUID patientId) {
        try {
            GoalSettingDto result = clinicalService.getGoals(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy mục tiêu trị liệu thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải mục tiêu: " + e.getMessage()));
        }
    }

    @PostMapping("/psychoeducation/complete")
    public ResponseEntity<ApiResponse<Object>> completePsychoeducation(@RequestParam UUID patientId) {
        try {
            clinicalService.completePsychoeducation(patientId);
            return ResponseEntity.ok(ApiResponse.success("Đã ghi nhận hoàn thành Psychoeducation!", null));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi cập nhật psychoeducation: " + e.getMessage()));
        }
    }

    @GetMapping("/onboarding-status")
    public ResponseEntity<ApiResponse<OnboardingStatusDto>> getOnboardingStatus(@RequestParam UUID patientId) {
        try {
            OnboardingStatusDto result = clinicalService.getOnboardingStatus(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy trạng thái onboarding thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải onboarding status: " + e.getMessage()));
        }
    }
}
