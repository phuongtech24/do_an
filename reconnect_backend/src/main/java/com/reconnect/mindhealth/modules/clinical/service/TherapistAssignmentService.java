package com.reconnect.mindhealth.modules.clinical.service;

import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class TherapistAssignmentService {

    public static final int CASELOAD_LIMIT = 20;
    private static final Logger log = LoggerFactory.getLogger(TherapistAssignmentService.class);

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

        log.info("Admin assign therapist: adminId={}, patientId={}, therapistId={}", current.getId(), patientId, therapistId);

        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Patient not found: " + patientId));

        TherapistProfile therapist = therapistProfileRepository.findByIdForUpdate(therapistId);
        if (therapist == null) {
            throw new EntityNotFoundException("Therapist not found: " + therapistId);
        }
        if (therapist.getApprovalStatus() != ApprovalStatus.ACTIVE) {
            throw new IllegalStateException("Bác sĩ chưa được duyệt ACTIVE.");
        }

        long caseload = patientProfileRepository.countByTherapist_IdAndIsActiveTrueAndGraduatedAtIsNull(therapistId);

        if (patient.getTherapist() == null || !therapistId.equals(patient.getTherapist().getId())) {
            if (caseload >= CASELOAD_LIMIT) {
                log.warn("Caseload full: therapistId={}, caseload={}, limit={}", therapistId, caseload, CASELOAD_LIMIT);
                throw new IllegalStateException("Bác sĩ đã đủ 20 bệnh nhân đang theo dõi.");
            }
        }

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

