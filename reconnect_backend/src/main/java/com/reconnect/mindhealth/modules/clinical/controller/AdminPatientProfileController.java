package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.AdminPatientProfileListItemDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.service.AdminPatientProfileService;

@RestController
@RequestMapping("/api/admin/patients")
public class AdminPatientProfileController {

    private final AdminPatientProfileService adminPatientProfileService;

    public AdminPatientProfileController(AdminPatientProfileService adminPatientProfileService) {
        this.adminPatientProfileService = adminPatientProfileService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<AdminPatientProfileListItemDto>>> listPatients(
            @RequestParam(name = "redFlagOnly", defaultValue = "false") boolean redFlagOnly,
            @RequestParam(name = "q", required = false) String q) {
        try {
            List<PatientProfile> list = adminPatientProfileService.listPatients(redFlagOnly, q);
            List<AdminPatientProfileListItemDto> dtos = list.stream()
                    .map(AdminPatientProfileListItemDto::new)
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", dtos));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}

