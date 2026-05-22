package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.AssignTherapistRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.service.TherapistAssignmentService;

@RestController
@RequestMapping("/api/admin")
public class AdminTherapistAssignmentController {

    private final TherapistAssignmentService therapistAssignmentService;

    public AdminTherapistAssignmentController(TherapistAssignmentService therapistAssignmentService) {
        this.therapistAssignmentService = therapistAssignmentService;
    }

    /**
     * POST /api/admin/patients/{patientId}/assign-therapist
     * ADMIN assigns or reassigns a fixed therapist for a patient (therapeutic alliance).
     */
    @PostMapping("/patients/{patientId}/assign-therapist")
    public ResponseEntity<ApiResponse<Object>> assignTherapist(
            @PathVariable UUID patientId,
            @Validated @RequestBody AssignTherapistRequestDto request) {
        PatientProfile updated = therapistAssignmentService.assignTherapist(patientId, request.getTherapistId());
        return ResponseEntity.ok(ApiResponse.success("Assigned therapist successfully.", updated.getId()));
    }
}

