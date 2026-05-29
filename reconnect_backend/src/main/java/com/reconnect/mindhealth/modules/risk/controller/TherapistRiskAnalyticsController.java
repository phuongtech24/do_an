package com.reconnect.mindhealth.modules.risk.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.risk.dto.TherapistPatientRiskAnalyticsDto;
import com.reconnect.mindhealth.modules.risk.service.TherapistRiskAnalyticsService;

@RestController
@RequestMapping("/api/therapist")
public class TherapistRiskAnalyticsController {

    private final AuthContextService authContextService;
    private final TherapistRiskAnalyticsService therapistRiskAnalyticsService;

    public TherapistRiskAnalyticsController(
            AuthContextService authContextService,
            TherapistRiskAnalyticsService therapistRiskAnalyticsService) {
        this.authContextService = authContextService;
        this.therapistRiskAnalyticsService = therapistRiskAnalyticsService;
    }

    @GetMapping("/patients/{patientId}/risk-analytics")
    public ResponseEntity<ApiResponse<TherapistPatientRiskAnalyticsDto>> getPatientRiskAnalytics(
            @PathVariable UUID patientId,
            @RequestParam(defaultValue = "14") int days) {
        try {
            User therapistUser = requireTherapist();
            TherapistPatientRiskAnalyticsDto analytics = therapistRiskAnalyticsService
                    .getPatientRiskAnalytics(therapistUser, patientId, days);
            return ResponseEntity.ok(ApiResponse.success("OK", analytics));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private User requireTherapist() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.THERAPIST) {
            throw new SecurityException("Chỉ THERAPIST mới có quyền truy cập.");
        }
        return current;
    }
}
