package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistCredentialDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistProfileStatusDto;
import com.reconnect.mindhealth.modules.clinical.service.TherapistCredentialService;

@RestController
@RequestMapping("/api/therapist/credentials")
public class TherapistCredentialController {

    private static final Logger log = LoggerFactory.getLogger(TherapistCredentialController.class);

    private final TherapistCredentialService therapistCredentialService;

    public TherapistCredentialController(TherapistCredentialService therapistCredentialService) {
        this.therapistCredentialService = therapistCredentialService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<TherapistCredentialDto>>> listMine() {
        try {
            List<TherapistCredentialDto> dtos = therapistCredentialService.listMyCredentials().stream()
                    .map(TherapistCredentialDto::new)
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", dtos));
        } catch (Exception e) {
            log.warn("List therapist credentials failed: err={}", e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @GetMapping("/status")
    public ResponseEntity<ApiResponse<TherapistProfileStatusDto>> myStatus() {
        try {
            TherapistProfileStatusDto dto = therapistCredentialService.getMyStatus();
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            log.warn("Get therapist credentials status failed: err={}", e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TherapistCredentialDto>> upload(@RequestParam("file") MultipartFile file) {
        try {
            log.info("Upload therapist credential: name={}, size={}", file != null ? file.getOriginalFilename() : null,
                    file != null ? file.getSize() : null);
            TherapistCredentialDto dto = new TherapistCredentialDto(therapistCredentialService.uploadMyCredential(file));
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            log.warn("Upload therapist credential failed: err={}", e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @GetMapping("/{credentialId}/download")
    public ResponseEntity<Resource> downloadMine(@PathVariable UUID credentialId) {
        Resource resource = therapistCredentialService.downloadMyCredential(credentialId);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"credential-" + credentialId + "\"")
                .body(resource);
    }
}

