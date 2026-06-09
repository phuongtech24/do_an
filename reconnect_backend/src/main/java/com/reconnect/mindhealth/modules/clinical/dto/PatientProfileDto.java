package com.reconnect.mindhealth.modules.clinical.dto;

import java.time.LocalDate;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

public class PatientProfileDto {
    private UUID patientId;
    private String nickname;
    private String avatarIcon;
    private Boolean anonymousModeEnabled;
    private String realFullName;
    private LocalDate dateOfBirth;
    private String gender;
    private String phoneNumber;
    private String emergencyContactPhone;
    private String educationLevel;
    private String occupation;
    private String relationshipStatus;
    private String medicalHistory;
    private Boolean lsasDemoCompleted;
    private Boolean safetyGateCompleted;
    private Boolean medicalProfileCompleted;

    public PatientProfileDto() {
    }

    public PatientProfileDto(PatientProfile profile) {
        if (profile == null) {
            return;
        }
        this.patientId = profile.getId();
        this.nickname = profile.getNickName();
        this.avatarIcon = profile.getAvatarIcon();
        this.anonymousModeEnabled = profile.getAnonymousModeEnabled();
        this.realFullName = profile.getRealFullName();
        this.dateOfBirth = profile.getDateOfBirth();
        this.gender = profile.getGender();
        this.phoneNumber = profile.getPhoneNumber();
        this.emergencyContactPhone = profile.getEmergencyContactPhone();
        this.educationLevel = profile.getEducationLevel();
        this.occupation = profile.getOccupation();
        this.relationshipStatus = profile.getRelationshipStatus();
        this.medicalHistory = profile.getMedicalHistory();
        this.lsasDemoCompleted = profile.getLsasDemoCompleted();
        this.safetyGateCompleted = profile.getSafetyGateCompleted();
        this.medicalProfileCompleted = profile.getMedicalProfileCompleted();
    }

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getAvatarIcon() { return avatarIcon; }
    public void setAvatarIcon(String avatarIcon) { this.avatarIcon = avatarIcon; }
    public Boolean getAnonymousModeEnabled() { return anonymousModeEnabled; }
    public void setAnonymousModeEnabled(Boolean anonymousModeEnabled) { this.anonymousModeEnabled = anonymousModeEnabled; }
    public String getRealFullName() { return realFullName; }
    public void setRealFullName(String realFullName) { this.realFullName = realFullName; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getEmergencyContactPhone() { return emergencyContactPhone; }
    public void setEmergencyContactPhone(String emergencyContactPhone) { this.emergencyContactPhone = emergencyContactPhone; }
    public String getEducationLevel() { return educationLevel; }
    public void setEducationLevel(String educationLevel) { this.educationLevel = educationLevel; }
    public String getOccupation() { return occupation; }
    public void setOccupation(String occupation) { this.occupation = occupation; }
    public String getRelationshipStatus() { return relationshipStatus; }
    public void setRelationshipStatus(String relationshipStatus) { this.relationshipStatus = relationshipStatus; }
    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }
    public Boolean getLsasDemoCompleted() { return lsasDemoCompleted; }
    public void setLsasDemoCompleted(Boolean lsasDemoCompleted) { this.lsasDemoCompleted = lsasDemoCompleted; }
    public Boolean getSafetyGateCompleted() { return safetyGateCompleted; }
    public void setSafetyGateCompleted(Boolean safetyGateCompleted) { this.safetyGateCompleted = safetyGateCompleted; }
    public Boolean getMedicalProfileCompleted() { return medicalProfileCompleted; }
    public void setMedicalProfileCompleted(Boolean medicalProfileCompleted) { this.medicalProfileCompleted = medicalProfileCompleted; }
}
