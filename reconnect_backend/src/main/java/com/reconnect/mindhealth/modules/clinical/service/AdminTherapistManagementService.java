package com.reconnect.mindhealth.modules.clinical.service;

import java.security.SecureRandom;
import java.time.Year;
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
                User user = profile.getUser();
                if (user != null) {
                    user.setUsername(profile.getFullName());
                    userRepository.save(user);
                }
            }
            if (request.getHometown() != null) {
                profile.setHometown(blankToNull(request.getHometown()));
            }
            if (request.getBirthYear() != null) {
                validateBirthYear(request.getBirthYear());
                profile.setBirthYear(request.getBirthYear());
            }
            if (request.getVoiceDescription() != null) {
                profile.setVoiceDescription(blankToNull(request.getVoiceDescription()));
            }
            if (request.getSpecialization() != null) {
                profile.setSpecialization(blankToNull(request.getSpecialization()));
            }
            if (request.getTherapyStyle() != null) {
                profile.setTherapyStyle(blankToNull(request.getTherapyStyle()));
            }
            if (request.getBio() != null) {
                profile.setBio(blankToNull(request.getBio()));
            }
            if (request.getMeetingLink() != null) {
                profile.setMeetingLink(blankToNull(request.getMeetingLink()));
            }
        }

        return therapistProfileRepository.save(profile);
    }

    @Transactional
    public String resetTherapistPassword(UUID therapistId, String newPasswordMaybeNull) {
        User user = userRepository.findById(therapistId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user: " + therapistId));

        String newPassword = newPasswordMaybeNull != null ? newPasswordMaybeNull.trim() : "";
        if (newPassword.isEmpty()) {
            newPassword = generatePassword(10);
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        return newPassword;
    }

    private void validateBirthYear(Integer birthYear) {
        if (birthYear == null) {
            return;
        }
        int currentYear = Year.now().getValue();
        if (birthYear < 1950 || birthYear > currentYear) {
            throw new IllegalArgumentException("Năm sinh không hợp lệ.");
        }
    }

    private String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String generatePassword(int length) {
        StringBuilder builder = new StringBuilder(length);
        for (int index = 0; index < length; index++) {
            builder.append(PW_ALPHABET.charAt(RNG.nextInt(PW_ALPHABET.length())));
        }
        return builder.toString();
    }
}
