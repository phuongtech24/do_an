package com.reconnect.mindhealth.modules.admin.controller;

import java.time.LocalDate;
import java.util.UUID;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.admin.dto.AdminDemoControlResultDto;
import com.reconnect.mindhealth.modules.admin.service.AdminDemoControlService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;

@RestController
@RequestMapping("/api/admin/demo")
public class AdminDemoControlController {

    private final AuthContextService authContextService;
    private final AdminDemoControlService adminDemoControlService;

    public AdminDemoControlController(
            AuthContextService authContextService,
            AdminDemoControlService adminDemoControlService) {
        this.authContextService = authContextService;
        this.adminDemoControlService = adminDemoControlService;
    }

    @PostMapping("/patients/{patientId}/unlock-phq9")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> unlockPhq9(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.unlockPhq9(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/trigger-phq9")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> triggerPhq9(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.triggerPhq9(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/run-daily-roadmap")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> runDailyRoadmap(
            @PathVariable UUID patientId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.runDailyRoadmap(patientId, date, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/set-risk")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> setRisk(
            @PathVariable UUID patientId,
            @RequestParam(defaultValue = "80") int score,
            @RequestParam(defaultValue = "true") boolean redFlag) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.setRisk(patientId, score, redFlag, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/clear-risk")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> clearRisk(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.clearRisk(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/reset-graduation")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> resetGraduation(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.resetGraduation(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private User requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chỉ ADMIN mới có quyền dùng Demo Controls.");
        }
        return current;
    }
}
