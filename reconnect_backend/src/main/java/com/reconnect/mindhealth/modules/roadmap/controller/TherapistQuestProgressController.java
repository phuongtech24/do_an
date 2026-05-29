package com.reconnect.mindhealth.modules.roadmap.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.roadmap.dto.TherapistPatientQuestProgressDto;
import com.reconnect.mindhealth.modules.roadmap.service.TherapistQuestProgressService;

@RestController
@RequestMapping("/api/therapist")
public class TherapistQuestProgressController {

    private final AuthContextService authContextService;
    private final TherapistQuestProgressService therapistQuestProgressService;

    public TherapistQuestProgressController(
            AuthContextService authContextService,
            TherapistQuestProgressService therapistQuestProgressService) {
        this.authContextService = authContextService;
        this.therapistQuestProgressService = therapistQuestProgressService;
    }

    @GetMapping("/patients/{patientId}/quest-progress")
    public ResponseEntity<ApiResponse<TherapistPatientQuestProgressDto>> getQuestProgress(@PathVariable UUID patientId) {
        try {
            User therapistUser = requireTherapist();
            TherapistPatientQuestProgressDto progress = therapistQuestProgressService.getProgress(therapistUser, patientId);
            return ResponseEntity.ok(ApiResponse.success("OK", progress));
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
