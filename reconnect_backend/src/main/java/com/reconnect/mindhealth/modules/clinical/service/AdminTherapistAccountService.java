package com.reconnect.mindhealth.modules.clinical.service;

import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.dto.CreateTherapistAccountRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AdminTherapistAccountService {

    private final UserRepository userRepository;
    private final TherapistProfileRepository therapistProfileRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminTherapistAccountService(
            UserRepository userRepository,
            TherapistProfileRepository therapistProfileRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.therapistProfileRepository = therapistProfileRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public TherapistProfile createTherapistAccount(CreateTherapistAccountRequestDto request) {
        String email = request.getEmail().trim();
        if (userRepository.existsByEmail(email)) {
            throw new IllegalStateException("Email đã được sử dụng.");
        }

        User u = new User();
        u.setEmail(email);
        u.setUsername(request.getFullName().trim());
        u.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        u.setRole(Role.THERAPIST);
        u.setIsAnonymous(false);
        u.setIsActive(true);
        User savedUser = userRepository.save(u);

        UUID savedUserId = savedUser.getId();
        User managedRef = userRepository.getReferenceById(savedUserId);

        TherapistProfile profile = new TherapistProfile();
        profile.setUser(managedRef);
        profile.setFullName(request.getFullName().trim());
        profile.setSpecialization(request.getSpecialization());
        profile.setApprovalStatus(ApprovalStatus.PENDING);
        return therapistProfileRepository.save(profile);
    }

    @Transactional
    public TherapistProfile setApproval(UUID therapistId, ApprovalStatus status) {
        TherapistProfile profile = therapistProfileRepository.findById(therapistId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist: " + therapistId));
        profile.setApprovalStatus(status);
        return therapistProfileRepository.save(profile);
    }
}

