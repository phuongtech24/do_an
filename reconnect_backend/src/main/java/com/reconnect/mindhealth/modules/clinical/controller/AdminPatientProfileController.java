package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.Locale;

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.util.PagingUtils;
import com.reconnect.mindhealth.modules.clinical.dto.AdminPatientProfileListItemDto;
import com.reconnect.mindhealth.modules.clinical.dto.AdminPatientProfileSearchRequestDto;
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
            @RequestParam(name = "triageOnly", defaultValue = "false") boolean triageOnly,
            @RequestParam(name = "q", required = false) String q) {
        try {
            List<PatientProfile> list = adminPatientProfileService.listPatients(redFlagOnly, triageOnly, q);
            List<AdminPatientProfileListItemDto> dtos = list.stream()
                    .map(AdminPatientProfileListItemDto::new)
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", dtos));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/paging")
    public ResponseEntity<ApiResponse<Page<AdminPatientProfileListItemDto>>> searchByPage(
            @RequestBody(required = false) AdminPatientProfileSearchRequestDto request) {
        try {
            AdminPatientProfileSearchRequestDto safeRequest = request != null ? request : new AdminPatientProfileSearchRequestDto();
            List<PatientProfile> list = adminPatientProfileService.listPatients(
                    Boolean.TRUE.equals(safeRequest.getRedFlagOnly()),
                    Boolean.TRUE.equals(safeRequest.getTriageOnly()),
                    safeRequest.normalizedKeyword());
            String keyword = safeRequest.normalizedKeyword();
            List<AdminPatientProfileListItemDto> dtos = list.stream()
                    .map(AdminPatientProfileListItemDto::new)
                    .filter(item -> matchesKeyword(item, keyword))
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", PagingUtils.paginate(dtos, safeRequest)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private boolean matchesKeyword(AdminPatientProfileListItemDto item, String keyword) {
        if (keyword == null) {
            return true;
        }
        String normalized = keyword.toLowerCase(Locale.ROOT);
        return containsIgnoreCase(item.getNickname(), normalized)
                || containsIgnoreCase(item.getEmail(), normalized)
                || containsIgnoreCase(item.getTherapistName(), normalized);
    }

    private boolean containsIgnoreCase(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }
}
