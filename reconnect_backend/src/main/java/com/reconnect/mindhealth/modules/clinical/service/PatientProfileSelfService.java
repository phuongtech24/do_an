package com.reconnect.mindhealth.modules.clinical.service;

import java.time.LocalDate;
import java.time.Period;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientSafetyGateRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class PatientProfileSelfService {

    private final PatientProfileRepository patientProfileRepository;

    public PatientProfileSelfService(PatientProfileRepository patientProfileRepository) {
        this.patientProfileRepository = patientProfileRepository;
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
            profile.setPhoneNumber(trimToNull(request.getPhoneNumber()));
        }
        if (request.getEmergencyContactPhone() != null) {
            profile.setEmergencyContactPhone(trimToNull(request.getEmergencyContactPhone()));
        }
        if (request.getEducationLevel() != null) {
            profile.setEducationLevel(trimToNull(request.getEducationLevel()));
        }
        if (request.getOccupation() != null) {
            profile.setOccupation(trimToNull(request.getOccupation()));
        }
        if (request.getRelationshipStatus() != null) {
            profile.setRelationshipStatus(trimToNull(request.getRelationshipStatus()));
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
        if (isBlank(request.getPhoneNumber())) {
            throw new IllegalArgumentException("Số điện thoại cá nhân là bắt buộc.");
        }
        profile.setRealFullName(request.getRealFullName().trim());
        profile.setPhoneNumber(request.getPhoneNumber().trim());
        profile.setSafetyGateCompleted(true);
        return new PatientProfileDto(patientProfileRepository.save(profile));
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
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
