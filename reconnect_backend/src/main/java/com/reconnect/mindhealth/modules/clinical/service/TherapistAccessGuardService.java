package com.reconnect.mindhealth.modules.clinical.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

/**
 * SRP: guard access for therapist-only business endpoints.
 */
@Service
public class TherapistAccessGuardService {

    private final AuthContextService authContextService;
    private final TherapistProfileRepository therapistProfileRepository;

    public TherapistAccessGuardService(
            AuthContextService authContextService,
            TherapistProfileRepository therapistProfileRepository) {
        this.authContextService = authContextService;
        this.therapistProfileRepository = therapistProfileRepository;
    }

    /**
     * Require current user is THERAPIST and approval status ACTIVE.
     * PENDING therapists can only access credential upload APIs.
     */
    @Transactional(readOnly = true)
    public TherapistProfile requireActiveTherapist() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.THERAPIST) {
            throw new SecurityException("Forbidden: THERAPIST role required.");
        }

        TherapistProfile profile = therapistProfileRepository.findById(current.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist profile"));

        if (profile.getApprovalStatus() != ApprovalStatus.ACTIVE) {
            throw new SecurityException("Vui lòng upload chứng chỉ và chờ Admin duyệt để sử dụng chức năng chuyên môn.");
        }

        return profile;
    }
}

