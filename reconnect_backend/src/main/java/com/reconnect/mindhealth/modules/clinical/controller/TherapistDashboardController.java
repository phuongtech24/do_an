package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistPatientListItemDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.service.TherapistAssignmentService;

@RestController
@RequestMapping("/api/therapist")
public class TherapistDashboardController {

    private final TherapistAssignmentService therapistAssignmentService;

    public TherapistDashboardController(TherapistAssignmentService therapistAssignmentService) {
        this.therapistAssignmentService = therapistAssignmentService;
    }

    /**
     * GET /api/therapist/patients?redFlagOnly=true
     * Therapist: list own patients sorted by risk desc.
     * Admin: when redFlagOnly=true, returns all red-flag patients for Emergency Alert.
     */
    @GetMapping("/patients")
    public ResponseEntity<ApiResponse<List<TherapistPatientListItemDto>>> listPatients(
            @RequestParam(name = "redFlagOnly", defaultValue = "false") boolean redFlagOnly) {
        List<PatientProfile> list = therapistAssignmentService.listPatientsForCurrentTherapist(redFlagOnly);
        List<TherapistPatientListItemDto> dto = list.stream()
                .map(TherapistPatientListItemDto::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success("OK", dto));
    }
}

