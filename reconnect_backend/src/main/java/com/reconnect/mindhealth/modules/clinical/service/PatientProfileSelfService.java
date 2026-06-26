package com.reconnect.mindhealth.modules.clinical.service;

import java.time.LocalDate;
import java.time.Period;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.util.PatientProfileFieldValidator;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.dto.AccountDeletionRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientSafetyGateRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class PatientProfileSelfService {

    private final PatientProfileRepository patientProfileRepository;
    private final UserRepository userRepository;

    public PatientProfileSelfService(PatientProfileRepository patientProfileRepository, UserRepository userRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public PatientProfileDto getProfile(UUID patientId) {
        return new PatientProfileDto(load(patientId));
    }

    @Transactional
    public PatientProfileDto updateProfile(PatientProfileUpdateRequestDto request) {
        PatientProfile profile = load(request.getPatientId());
        if (request.getNickname() != null) {
            profile.setNickName(request.getNickname().trim());
        }
        if (request.getAvatarIcon() != null) {
            profile.setAvatarIcon(request.getAvatarIcon().trim());
        }
        if (request.getAnonymousModeEnabled() != null) {
            profile.setAnonymousModeEnabled(request.getAnonymousModeEnabled());
        }
        if (request.getRealFullName() != null) {
            profile.setRealFullName(trimToNull(request.getRealFullName()));
        }
        if (request.getDateOfBirth() != null) {
            validateDateOfBirth(request.getDateOfBirth());
            profile.setDateOfBirth(request.getDateOfBirth());
        }
        if (request.getGender() != null) {
            profile.setGender(trimToNull(request.getGender()));
        }
        if (request.getPhoneNumber() != null) {
            profile.setPhoneNumber(PatientProfileFieldValidator.normalizePhone(
                    request.getPhoneNumber(),
                    "Số điện thoại cá nhân",
                    false));
        }
        if (request.getEmergencyContactPhone() != null) {
            profile.setEmergencyContactPhone(PatientProfileFieldValidator.normalizePhone(
                    request.getEmergencyContactPhone(),
                    "Số điện thoại người liên hệ khẩn cấp",
                    false));
        }
        if (request.getEducationLevel() != null) {
            profile.setEducationLevel(PatientProfileFieldValidator.normalizeEducationLevel(request.getEducationLevel()));
        }
        if (request.getOccupation() != null) {
            profile.setOccupation(trimToNull(request.getOccupation()));
        }
        if (request.getRelationshipStatus() != null) {
            profile.setRelationshipStatus(PatientProfileFieldValidator.normalizeRelationshipStatus(request.getRelationshipStatus()));
        }
        if (request.getMedicalHistory() != null) {
            profile.setMedicalHistory(trimToNull(request.getMedicalHistory()));
        }
        if (request.getLsasDemoCompleted() != null) {
            profile.setLsasDemoCompleted(request.getLsasDemoCompleted());
        }
        if (request.getSafetyGateCompleted() != null) {
            profile.setSafetyGateCompleted(request.getSafetyGateCompleted());
        }
        if (request.getMedicalProfileCompleted() != null) {
            profile.setMedicalProfileCompleted(request.getMedicalProfileCompleted());
        }

        profile.setMedicalProfileCompleted(isMedicalProfileComplete(profile));
        if (Boolean.TRUE.equals(profile.getMedicalProfileCompleted())) {
            profile.setSafetyGateCompleted(true);
        }

        return new PatientProfileDto(patientProfileRepository.save(profile));
    }

    @Transactional
    public PatientProfileDto completeSafetyGate(PatientSafetyGateRequestDto request) {
        PatientProfile profile = load(request.getPatientId());
        if (isBlank(request.getRealFullName())) {
            throw new IllegalArgumentException("Họ tên thật là bắt buộc.");
        }
        profile.setRealFullName(request.getRealFullName().trim());
        profile.setPhoneNumber(PatientProfileFieldValidator.normalizePhone(
                request.getPhoneNumber(),
                "Số điện thoại cá nhân",
                true));
        profile.setSafetyGateCompleted(true);
        return new PatientProfileDto(patientProfileRepository.save(profile));
    }

    @Transactional
    public void softDeleteAccount(AccountDeletionRequestDto request) {
        if (request == null || request.getPatientId() == null) {
            throw new IllegalArgumentException("Thieu patientId.");
        }
        if (!Boolean.TRUE.equals(request.getConfirmDelete())) {
            throw new IllegalArgumentException("Ban chua xac nhan xoa tai khoan.");
        }

        PatientProfile profile = load(request.getPatientId());
        User user = profile.getUser();
        if (user == null) {
            throw new EntityNotFoundException("Khong tim thay tai khoan nguoi dung.");
        }

        String deletedSuffix = user.getId().toString().substring(0, 8);
        user.setEmail("deleted+" + deletedSuffix + "@reconnect.local");
        user.setUsername("deleted_" + deletedSuffix);
        user.setIsActive(false);
        user.setVoided(true);
        user.setResetPasswordToken(null);
        user.setResetPasswordExpiresAt(null);
        user.setEmailVerificationOtp(null);
        user.setEmailVerificationExpiresAt(null);
        user.setEmailVerificationSentAt(null);
        userRepository.save(user);

        profile.setAnonymousModeEnabled(true);
        profile.setRealFullName(null);
        profile.setPhoneNumber(null);
        profile.setEmergencyContactPhone(null);
        profile.setDateOfBirth(null);
        profile.setGender(null);
        profile.setEducationLevel(null);
        profile.setOccupation(null);
        profile.setRelationshipStatus(null);
        profile.setMedicalHistory(null);
        profile.setNickName("tai_khoan_da_xoa_" + deletedSuffix);
        profile.setAvatarIcon("avatar_deleted");
        profile.setMedicalProfileCompleted(false);
        profile.setSafetyGateCompleted(false);
        profile.setCurrentRiskScore(0);
        profile.setCurrentLsasScore(0);
        profile.setIsRedFlagActive(false);
        profile.setTriageRequired(false);
        profile.setTriageStatus(null);
        profile.setTriagePriority(null);
        profile.setTriageTriggeredAt(null);
        profile.setIsActive(false);
        profile.setVoided(true);
        patientProfileRepository.save(profile);
    }

    private PatientProfile load(UUID patientId) {
        return patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ bệnh nhân: " + patientId));
    }

    private boolean isMedicalProfileComplete(PatientProfile profile) {
        return !isBlank(profile.getRealFullName())
                && profile.getDateOfBirth() != null
                && !isBlank(profile.getGender())
                && !isBlank(profile.getPhoneNumber())
                && !isBlank(profile.getEmergencyContactPhone())
                && !isBlank(profile.getEducationLevel())
                && !isBlank(profile.getOccupation())
                && !isBlank(profile.getRelationshipStatus())
                && !isBlank(profile.getMedicalHistory());
    }

    private void validateDateOfBirth(LocalDate dateOfBirth) {
        if (dateOfBirth == null) {
            return;
        }
        LocalDate today = LocalDate.now();
        if (dateOfBirth.isAfter(today.minusYears(10)) || dateOfBirth.isBefore(today.minusYears(100))) {
            throw new IllegalArgumentException("Ngày sinh không hợp lệ.");
        }
        int age = Period.between(dateOfBirth, today).getYears();
        if (age < 10 || age > 100) {
            throw new IllegalArgumentException("Tuổi phải nằm trong khoảng 10 đến 100.");
        }
    }

    private String trimToNull(String value) {
        return PatientProfileFieldValidator.trimToNull(value);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
