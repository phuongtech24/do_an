package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.dto.CreateTherapistAccountRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistApplicantDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.service.AdminTherapistAccountService;
import com.reconnect.mindhealth.modules.clinical.service.TherapistDirectoryQueryService;

@RestController
@RequestMapping("/api/admin/therapists")
public class AdminTherapistApprovalController {

    private final AuthContextService authContextService;
    private final AdminTherapistAccountService adminTherapistAccountService;
    private final TherapistDirectoryQueryService therapistDirectoryQueryService;

    public AdminTherapistApprovalController(
            AuthContextService authContextService,
            AdminTherapistAccountService adminTherapistAccountService,
            TherapistDirectoryQueryService therapistDirectoryQueryService) {
        this.authContextService = authContextService;
        this.adminTherapistAccountService = adminTherapistAccountService;
        this.therapistDirectoryQueryService = therapistDirectoryQueryService;
    }

    private void requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chỉ ADMIN mới có quyền truy cập.");
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<TherapistApplicantDto>>> list(
            @RequestParam(required = false) ApprovalStatus status) {
        try {
            requireAdmin();
            List<TherapistApplicantDto> dtos = therapistDirectoryQueryService.listAdminTherapists(status);
            return ResponseEntity.ok(ApiResponse.success("OK", dtos));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<TherapistApplicantDto>> create(@RequestBody CreateTherapistAccountRequestDto request) {
        try {
            requireAdmin();
            if (request == null) {
                throw new IllegalArgumentException("Thiếu payload.");
            }
            if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
                throw new IllegalArgumentException("Thiếu email.");
            }
            if (request.getPassword() == null || request.getPassword().isEmpty()) {
                throw new IllegalArgumentException("Thiếu password.");
            }
            if (request.getFullName() == null || request.getFullName().trim().isEmpty()) {
                throw new IllegalArgumentException("Thiếu fullName.");
            }

            TherapistProfile savedProfile = adminTherapistAccountService.createTherapistAccount(request);
            TherapistApplicantDto dto = therapistDirectoryQueryService.listAdminTherapists(null).stream()
                    .filter(item -> savedProfile.getId().equals(item.getTherapistId()))
                    .findFirst()
                    .orElse(new TherapistApplicantDto(savedProfile, 0, 0));
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PatchMapping("/{therapistId}/approval")
    public ResponseEntity<ApiResponse<TherapistApplicantDto>> setApproval(
            @PathVariable UUID therapistId,
            @RequestParam ApprovalStatus status) {
        try {
            requireAdmin();
            TherapistProfile saved = adminTherapistAccountService.setApproval(therapistId, status);
            TherapistApplicantDto dto = therapistDirectoryQueryService.listAdminTherapists(null).stream()
                    .filter(item -> saved.getId().equals(item.getTherapistId()))
                    .findFirst()
                    .orElse(new TherapistApplicantDto(saved, 0, 0));
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}
