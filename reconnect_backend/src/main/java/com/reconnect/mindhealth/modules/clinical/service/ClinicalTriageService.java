package com.reconnect.mindhealth.modules.clinical.service;

import java.time.LocalDateTime;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.enums.TriageStatus;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class ClinicalTriageService {

    private static final Logger log = LoggerFactory.getLogger(ClinicalTriageService.class);

    private final PatientProfileRepository patientProfileRepository;
    private final AuthContextService authContextService;
    private final TherapistAssignmentService therapistAssignmentService;

    public ClinicalTriageService(
            PatientProfileRepository patientProfileRepository,
            AuthContextService authContextService,
            TherapistAssignmentService therapistAssignmentService) {
        this.patientProfileRepository = patientProfileRepository;
        this.authContextService = authContextService;
        this.therapistAssignmentService = therapistAssignmentService;
    }

    public PatientProfile openUrgentTriage(PatientProfile patient) {
        patient.setTriageRequired(true);
        patient.setTriageStatus(TriageStatus.PENDING);
        patient.setTriagePriority(resolveTriagePriority(patient));
        if (patient.getTriageTriggeredAt() == null) {
            patient.setTriageTriggeredAt(LocalDateTime.now());
        }
        if (patient.getStatus() == null || patient.getStatus() != Status.WARNING) {
            patient.setStatus(Status.WARNING);
        }
        return patientProfileRepository.save(patient);
    }

    public PatientProfile claim(UUID patientId) {
        User admin = requireAdmin();
        PatientProfile patient = getPatient(patientId);
        patient.setTriageRequired(true);
        patient.setTriageStatus(TriageStatus.IN_REVIEW);
        if (patient.getTriageTriggeredAt() == null) {
            patient.setTriageTriggeredAt(LocalDateTime.now());
        }
        patient.setTriagePriority(resolveTriagePriority(patient));
        PatientProfile saved = patientProfileRepository.save(patient);
        log.info("Clinical triage claimed adminId={}, patientId={}", admin.getId(), patientId);
        return saved;
    }

    public PatientProfile markCalled(UUID patientId) {
        User admin = requireAdmin();
        PatientProfile patient = getPatient(patientId);
        patient.setTriageRequired(true);
        patient.setTriageStatus(TriageStatus.IN_REVIEW);
        if (patient.getTriageTriggeredAt() == null) {
            patient.setTriageTriggeredAt(LocalDateTime.now());
        }
        PatientProfile saved = patientProfileRepository.save(patient);
        log.info("Clinical triage marked called adminId={}, patientId={}", admin.getId(), patientId);
        return saved;
    }

    public PatientProfile assign(UUID patientId, UUID therapistId) {
        User admin = requireAdmin();
        PatientProfile saved = therapistAssignmentService.assignTherapist(patientId, therapistId);
        saved.setTriageRequired(true);
        saved.setTriageStatus(TriageStatus.ASSIGNED);
        saved.setTriagePriority(resolveTriagePriority(saved));
        PatientProfile persisted = patientProfileRepository.save(saved);
        log.info("Clinical triage assigned adminId={}, patientId={}, therapistId={}", admin.getId(), patientId, therapistId);
        return persisted;
    }

    public PatientProfile close(UUID patientId) {
        User admin = requireAdmin();
        PatientProfile patient = getPatient(patientId);
        patient.setTriageRequired(false);
        patient.setTriageStatus(TriageStatus.CLOSED);
        PatientProfile saved = patientProfileRepository.save(patient);
        log.info("Clinical triage closed adminId={}, patientId={}", admin.getId(), patientId);
        return saved;
    }

    private int resolveTriagePriority(PatientProfile patient) {
        int lsas = patient.getCurrentLsasScore() != null ? patient.getCurrentLsasScore() : 0;
        int risk = patient.getCurrentRiskScore() != null ? patient.getCurrentRiskScore() : 0;
        return Math.max(lsas, risk);
    }

    private User requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Forbidden: ADMIN role required.");
        }
        return current;
    }

    private PatientProfile getPatient(UUID patientId) {
        return patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Patient not found: " + patientId));
    }
}
