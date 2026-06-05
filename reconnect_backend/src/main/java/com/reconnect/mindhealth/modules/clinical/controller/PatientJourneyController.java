package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistDirectoryItemDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistSelectionRequestDto;
import com.reconnect.mindhealth.modules.clinical.service.TherapistAssignmentService;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientGoalDto;
import com.reconnect.mindhealth.modules.roadmap.service.FearLadderService;

@RestController
@RequestMapping("/api/patient")
public class PatientJourneyController {

    private final FearLadderService fearLadderService;
    private final TherapistAssignmentService therapistAssignmentService;

    public PatientJourneyController(
            FearLadderService fearLadderService,
            TherapistAssignmentService therapistAssignmentService) {
        this.fearLadderService = fearLadderService;
        this.therapistAssignmentService = therapistAssignmentService;
    }

    @GetMapping("/goals")
    public ResponseEntity<ApiResponse<List<PatientGoalDto>>> goals(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.getActiveGoals(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/goals")
    public ResponseEntity<ApiResponse<PatientGoalDto>> saveGoal(@RequestBody PatientGoalDto dto) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.saveGoal(dto)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/therapists")
    public ResponseEntity<ApiResponse<List<TherapistDirectoryItemDto>>> therapists() {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", therapistAssignmentService.listSelectableTherapists()));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/therapist-selection")
    public ResponseEntity<ApiResponse<Object>> selectTherapist(@RequestBody TherapistSelectionRequestDto request) {
        try {
            therapistAssignmentService.selectTherapist(request.getPatientId(), request.getTherapistId());
            return ResponseEntity.ok(ApiResponse.success("ÄÃ£ chá»n chuyÃªn gia phÃ¹ há»£p.", null));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }
}
