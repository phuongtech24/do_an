package com.reconnect.mindhealth.modules.clinical.service;

import java.security.SecureRandom;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.dto.AdminTherapistUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

/**
 * SRP: Manage therapist account/profile data (edit profile, reset password, lock/unlock handled in AdminUserController).
 */
@Service
public class AdminTherapistManagementService {

    private static final String PW_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
    private static final SecureRandom RNG = new SecureRandom();

    private final UserRepository userRepository;
    private final TherapistProfileRepository therapistProfileRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminTherapistManagementService(
            UserRepository userRepository,
            TherapistProfileRepository therapistProfileRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.therapistProfileRepository = therapistProfileRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public TherapistProfile updateTherapistProfile(UUID therapistId, AdminTherapistUpdateRequestDto request) {
        TherapistProfile profile = therapistProfileRepository.findById(therapistId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist: " + therapistId));

        if (request != null) {
            if (request.getFullName() != null && !request.getFullName().trim().isEmpty()) {
                profile.setFullName(request.getFullName().trim());
                // keep username somewhat aligned for display (email login still used)
                User u = profile.getUser();
                if (u != null) {
                    u.setUsername(profile.getFullName());
                    userRepository.save(u);
                }
            }
            if (request.getSpecialization() != null) {
                profile.setSpecialization(request.getSpecialization().trim().isEmpty() ? null : request.getSpecialization().trim());
            }
            if (request.getBio() != null) {
                profile.setBio(request.getBio().trim().isEmpty() ? null : request.getBio().trim());
            }
            if (request.getMeetingLink() != null) {
                profile.setMeetingLink(request.getMeetingLink().trim().isEmpty() ? null : request.getMeetingLink().trim());
            }
        }

        return therapistProfileRepository.save(profile);
    }

    @Transactional
    public String resetTherapistPassword(UUID therapistId, String newPasswordMaybeNull) {
        User u = userRepository.findById(therapistId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user: " + therapistId));

        String newPassword = newPasswordMaybeNull != null ? newPasswordMaybeNull.trim() : "";
        if (newPassword.isEmpty()) {
            newPassword = generatePassword(10);
        }

        u.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(u);
        return newPassword;
    }

    private String generatePassword(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(PW_ALPHABET.charAt(RNG.nextInt(PW_ALPHABET.length())));
        }
        return sb.toString();
    }
}

