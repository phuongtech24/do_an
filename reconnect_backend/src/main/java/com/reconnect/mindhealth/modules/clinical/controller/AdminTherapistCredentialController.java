package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistCredentialDto;
import com.reconnect.mindhealth.modules.clinical.service.TherapistCredentialService;

@RestController
@RequestMapping("/api/admin/therapists/{therapistId}/credentials")
public class AdminTherapistCredentialController {

    private final TherapistCredentialService therapistCredentialService;

    public AdminTherapistCredentialController(TherapistCredentialService therapistCredentialService) {
        this.therapistCredentialService = therapistCredentialService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<TherapistCredentialDto>>> list(@PathVariable UUID therapistId) {
        try {
            List<TherapistCredentialDto> dtos = therapistCredentialService.listCredentialsForAdmin(therapistId).stream()
                    .map(TherapistCredentialDto::new)
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", dtos));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @GetMapping("/{credentialId}/download")
    public ResponseEntity<Resource> download(
            @PathVariable UUID therapistId,
            @PathVariable UUID credentialId) {
        Resource resource = therapistCredentialService.downloadCredentialForAdmin(therapistId, credentialId);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"credential-" + credentialId + "\"")
                .body(resource);
    }
}

