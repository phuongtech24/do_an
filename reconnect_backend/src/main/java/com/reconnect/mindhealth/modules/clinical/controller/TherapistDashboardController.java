package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSubmissionRepository;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistPatientListItemDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.service.TherapistAssignmentService;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientGoal;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientGoalRepository;

@RestController
@RequestMapping("/api/therapist")
public class TherapistDashboardController {

    private final TherapistAssignmentService therapistAssignmentService;
    private final LsasSubmissionRepository lsasSubmissionRepository;
    private final PatientGoalRepository patientGoalRepository;

    public TherapistDashboardController(
            TherapistAssignmentService therapistAssignmentService,
            LsasSubmissionRepository lsasSubmissionRepository,
            PatientGoalRepository patientGoalRepository) {
        this.therapistAssignmentService = therapistAssignmentService;
        this.lsasSubmissionRepository = lsasSubmissionRepository;
        this.patientGoalRepository = patientGoalRepository;
    }

    @GetMapping("/patients")
    public ResponseEntity<ApiResponse<List<TherapistPatientListItemDto>>> listPatients(
            @RequestParam(name = "redFlagOnly", defaultValue = "false") boolean redFlagOnly) {
        List<PatientProfile> list = therapistAssignmentService.listPatientsForCurrentTherapist(redFlagOnly);
        List<TherapistPatientListItemDto> dto = list.stream()
                .map(patient -> new TherapistPatientListItemDto(
                        patient,
                        resolveBaselineLsas(patient),
                        resolvePrimaryGoal(patient)))
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success("OK", dto));
    }

    private Integer resolveBaselineLsas(PatientProfile patient) {
        return Optional.ofNullable(lsasSubmissionRepository.findTopByPatientProfile_IdAndSubmissionTypeOrderByCreateDateAsc(
                        patient.getId(),
                        LsasSubmissionType.BASELINE))
                .map(LsasSubmission::getTotalScore)
                .orElse(patient.getCurrentLsasScore());
    }

    private String resolvePrimaryGoal(PatientProfile patient) {
        return patientGoalRepository
                .findByPatientProfile_IdAndStatusOrderByCreateDateDesc(patient.getId(), PatientGoalStatus.ACTIVE)
                .stream()
                .findFirst()
                .map(PatientGoal::getDescription)
                .orElse(null);
    }
}
