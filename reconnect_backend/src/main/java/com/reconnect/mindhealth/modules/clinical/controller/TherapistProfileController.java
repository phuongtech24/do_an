package com.reconnect.mindhealth.modules.clinical.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.AdminTherapistUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistApplicantDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.service.TherapistProfileSelfService;

@RestController
@RequestMapping("/api/therapist/profile")
public class TherapistProfileController {

    private final TherapistProfileSelfService therapistProfileSelfService;

    public TherapistProfileController(TherapistProfileSelfService therapistProfileSelfService) {
        this.therapistProfileSelfService = therapistProfileSelfService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<TherapistApplicantDto>> getMyProfile() {
        try {
            TherapistProfile profile = therapistProfileSelfService.getMyProfile();
            return ResponseEntity.ok(ApiResponse.success("OK", new TherapistApplicantDto(profile)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PutMapping
    public ResponseEntity<ApiResponse<TherapistApplicantDto>> updateMyProfile(
            @RequestBody AdminTherapistUpdateRequestDto request) {
        try {
            TherapistProfile saved = therapistProfileSelfService.updateMyProfile(request);
            return ResponseEntity.ok(ApiResponse.success("Đã cập nhật hồ sơ.", new TherapistApplicantDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/avatar")
    public ResponseEntity<ApiResponse<TherapistApplicantDto>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        try {
            TherapistProfile saved = therapistProfileSelfService.uploadMyAvatar(file);
            return ResponseEntity.ok(ApiResponse.success("Đã cập nhật ảnh đại diện.", new TherapistApplicantDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}
