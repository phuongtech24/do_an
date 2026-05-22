package com.reconnect.mindhealth.modules.clinical.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class TherapistAssignmentService {

    private final AuthContextService authContextService;
    private final PatientProfileRepository patientProfileRepository;
    private final TherapistProfileRepository therapistProfileRepository;
    private final TherapistAccessGuardService therapistAccessGuardService;

    public TherapistAssignmentService(
            AuthContextService authContextService,
            PatientProfileRepository patientProfileRepository,
            TherapistProfileRepository therapistProfileRepository,
            TherapistAccessGuardService therapistAccessGuardService) {
        this.authContextService = authContextService;
        this.patientProfileRepository = patientProfileRepository;
        this.therapistProfileRepository = therapistProfileRepository;
        this.therapistAccessGuardService = therapistAccessGuardService;
    }

    public PatientProfile assignTherapist(UUID patientId, UUID therapistId) {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Forbidden: ADMIN role required.");
        }

        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Patient not found: " + patientId));

        TherapistProfile therapist = therapistProfileRepository.findById(therapistId)
                .orElseThrow(() -> new EntityNotFoundException("Therapist not found: " + therapistId));

        patient.setTherapist(therapist);
        return patientProfileRepository.save(patient);
    }

    @Transactional(readOnly = true)
    public List<PatientProfile> listPatientsForCurrentTherapist(boolean redFlagOnly) {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.THERAPIST && current.getRole() != Role.ADMIN) {
            throw new SecurityException("Forbidden: THERAPIST/ADMIN required.");
        }

        UUID therapistUserId = current.getId();
        if (current.getRole() == Role.ADMIN) {
            // Admin can see all red-flag patients for Emergency Alert.
            if (redFlagOnly) {
                return patientProfileRepository.findByIsRedFlagActiveTrueOrderByCurrentRiskScoreDesc();
            }
            return patientProfileRepository.findByIsActiveTrue();
        }

        therapistAccessGuardService.requireActiveTherapist();

        if (redFlagOnly) {
            return patientProfileRepository.findByTherapist_User_IdAndIsRedFlagActiveTrueOrderByCurrentRiskScoreDesc(therapistUserId);
        }
        return patientProfileRepository.findByTherapist_User_IdOrderByCurrentRiskScoreDesc(therapistUserId);
    }
}
