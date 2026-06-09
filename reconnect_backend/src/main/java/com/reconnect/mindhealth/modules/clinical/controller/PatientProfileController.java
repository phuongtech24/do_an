package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientSafetyGateRequestDto;
import com.reconnect.mindhealth.modules.clinical.service.PatientProfileSelfService;

@RestController
@RequestMapping("/api/patient/profile")
public class PatientProfileController {

    private final PatientProfileSelfService patientProfileSelfService;

    public PatientProfileController(PatientProfileSelfService patientProfileSelfService) {
        this.patientProfileSelfService = patientProfileSelfService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<PatientProfileDto>> getProfile(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", patientProfileSelfService.getProfile(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải hồ sơ bệnh nhân: " + e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<PatientProfileDto>> updateProfile(@RequestBody PatientProfileUpdateRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Cập nhật hồ sơ bệnh nhân thành công.", patientProfileSelfService.updateProfile(request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi cập nhật hồ sơ bệnh nhân: " + e.getMessage()));
        }
    }

    @PostMapping("/safety-gate")
    public ResponseEntity<ApiResponse<PatientProfileDto>> completeSafetyGate(@RequestBody PatientSafetyGateRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Đã ghi nhận cam kết an toàn y tế.", patientProfileSelfService.completeSafetyGate(request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi lưu thông tin an toàn y tế: " + e.getMessage()));
        }
    }
}
