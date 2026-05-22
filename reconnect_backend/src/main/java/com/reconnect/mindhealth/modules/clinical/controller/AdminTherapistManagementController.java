package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.dto.AdminResetPasswordRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.AdminResetPasswordResponseDto;
import com.reconnect.mindhealth.modules.clinical.dto.AdminTherapistUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistApplicantDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistCredentialRepository;
import com.reconnect.mindhealth.modules.clinical.service.AdminTherapistManagementService;

@RestController
@RequestMapping("/api/admin/therapists")
public class AdminTherapistManagementController {

    private final AuthContextService authContextService;
    private final AdminTherapistManagementService adminTherapistManagementService;
    private final TherapistCredentialRepository therapistCredentialRepository;

    public AdminTherapistManagementController(
            AuthContextService authContextService,
            AdminTherapistManagementService adminTherapistManagementService,
            TherapistCredentialRepository therapistCredentialRepository) {
        this.authContextService = authContextService;
        this.adminTherapistManagementService = adminTherapistManagementService;
        this.therapistCredentialRepository = therapistCredentialRepository;
    }

    private void requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chỉ ADMIN mới có quyền truy cập.");
        }
    }

    @PutMapping("/{therapistId}")
    public ResponseEntity<ApiResponse<TherapistApplicantDto>> updateProfile(
            @PathVariable UUID therapistId,
            @RequestBody AdminTherapistUpdateRequestDto request) {
        try {
            requireAdmin();
            TherapistProfile saved = adminTherapistManagementService.updateTherapistProfile(therapistId, request);
            long credentialCount = therapistCredentialRepository.countByTherapistProfile_Id(therapistId);
            return ResponseEntity.ok(ApiResponse.success("OK", new TherapistApplicantDto(saved, credentialCount)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/{therapistId}/reset-password")
    public ResponseEntity<ApiResponse<AdminResetPasswordResponseDto>> resetPassword(
            @PathVariable UUID therapistId,
            @RequestBody(required = false) AdminResetPasswordRequestDto request) {
        try {
            requireAdmin();
            String newPassword = adminTherapistManagementService.resetTherapistPassword(
                    therapistId,
                    request != null ? request.getNewPassword() : null);
            return ResponseEntity.ok(ApiResponse.success("OK", new AdminResetPasswordResponseDto(therapistId, newPassword)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}

