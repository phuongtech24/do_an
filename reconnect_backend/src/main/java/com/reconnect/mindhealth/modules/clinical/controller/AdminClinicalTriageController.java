package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.Map;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.AdminPatientProfileListItemDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.service.ClinicalTriageService;

@RestController
@RequestMapping("/api/admin/triage")
public class AdminClinicalTriageController {

    private final ClinicalTriageService clinicalTriageService;

    public AdminClinicalTriageController(ClinicalTriageService clinicalTriageService) {
        this.clinicalTriageService = clinicalTriageService;
    }

    @PostMapping("/{patientId}/claim")
    public ResponseEntity<ApiResponse<AdminPatientProfileListItemDto>> claim(@PathVariable UUID patientId) {
        try {
            PatientProfile patient = clinicalTriageService.claim(patientId);
            return ResponseEntity.ok(ApiResponse.success("Đã nhận xử lý ca triage.", new AdminPatientProfileListItemDto(patient)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi claim triage: " + e.getMessage()));
        }
    }

    @PostMapping("/{patientId}/mark-called")
    public ResponseEntity<ApiResponse<AdminPatientProfileListItemDto>> markCalled(@PathVariable UUID patientId) {
        try {
            PatientProfile patient = clinicalTriageService.markCalled(patientId);
            return ResponseEntity.ok(ApiResponse.success("Đã đánh dấu đã gọi bệnh nhân.", new AdminPatientProfileListItemDto(patient)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi cập nhật triage: " + e.getMessage()));
        }
    }

    @PostMapping("/{patientId}/assign")
    public ResponseEntity<ApiResponse<AdminPatientProfileListItemDto>> assign(
            @PathVariable UUID patientId,
            @RequestBody Map<String, String> request) {
        try {
            String therapistId = request.get("therapistId");
            PatientProfile patient = clinicalTriageService.assign(patientId, UUID.fromString(therapistId));
            return ResponseEntity.ok(ApiResponse.success("Đã điều phối ca bệnh cho bác sĩ.", new AdminPatientProfileListItemDto(patient)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi assign triage: " + e.getMessage()));
        }
    }

    @PostMapping("/{patientId}/close")
    public ResponseEntity<ApiResponse<AdminPatientProfileListItemDto>> close(@PathVariable UUID patientId) {
        try {
            PatientProfile patient = clinicalTriageService.close(patientId);
            return ResponseEntity.ok(ApiResponse.success("Đã đóng ca triage.", new AdminPatientProfileListItemDto(patient)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi đóng triage: " + e.getMessage()));
        }
    }
}
