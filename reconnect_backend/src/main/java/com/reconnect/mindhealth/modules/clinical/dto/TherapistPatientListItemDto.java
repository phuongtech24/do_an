package com.reconnect.mindhealth.modules.clinical.dto;

import java.time.LocalDate;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

public class TherapistPatientListItemDto {
    private UUID patientId;
    private String nickname;
    private Integer currentRiskScore;
    private Boolean isRedFlagActive;
    private Integer currentLsasScore;
    private Integer baselineLsasScore;
    private String primaryGoal;
    private String therapistName;
    private String avatarIcon;
    private Boolean anonymousModeEnabled;
    private String realFullName;
    private String phoneNumber;
    private String emergencyContactPhone;
    private LocalDate dateOfBirth;
    private String gender;
    private String educationLevel;
    private String occupation;
    private String relationshipStatus;
    private String medicalHistory;

    public TherapistPatientListItemDto() {
    }

    public TherapistPatientListItemDto(PatientProfile patient, Integer baselineLsasScore, String primaryGoal) {
        this.patientId = patient.getId();
        this.nickname = patient.getNickName();
        this.currentRiskScore = patient.getCurrentRiskScore();
        this.isRedFlagActive = patient.getIsRedFlagActive();
        this.currentLsasScore = patient.getCurrentLsasScore();
        this.baselineLsasScore = baselineLsasScore;
        this.primaryGoal = primaryGoal;
        this.therapistName = patient.getTherapist() != null ? patient.getTherapist().getFullName() : null;
        this.avatarIcon = patient.getAvatarIcon();
        this.anonymousModeEnabled = patient.getAnonymousModeEnabled();
        this.realFullName = patient.getRealFullName();
        this.phoneNumber = patient.getPhoneNumber();
        this.emergencyContactPhone = patient.getEmergencyContactPhone();
        this.dateOfBirth = patient.getDateOfBirth();
        this.gender = patient.getGender();
        this.educationLevel = patient.getEducationLevel();
        this.occupation = patient.getOccupation();
        this.relationshipStatus = patient.getRelationshipStatus();
        this.medicalHistory = patient.getMedicalHistory();
    }

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public Integer getCurrentRiskScore() { return currentRiskScore; }
    public void setCurrentRiskScore(Integer currentRiskScore) { this.currentRiskScore = currentRiskScore; }
    public Boolean getIsRedFlagActive() { return isRedFlagActive; }
    public void setIsRedFlagActive(Boolean isRedFlagActive) { this.isRedFlagActive = isRedFlagActive; }
    public Integer getCurrentLsasScore() { return currentLsasScore; }
    public void setCurrentLsasScore(Integer currentLsasScore) { this.currentLsasScore = currentLsasScore; }
    public Integer getBaselineLsasScore() { return baselineLsasScore; }
    public void setBaselineLsasScore(Integer baselineLsasScore) { this.baselineLsasScore = baselineLsasScore; }
    public String getPrimaryGoal() { return primaryGoal; }
    public void setPrimaryGoal(String primaryGoal) { this.primaryGoal = primaryGoal; }
    public String getTherapistName() { return therapistName; }
    public void setTherapistName(String therapistName) { this.therapistName = therapistName; }
    public String getAvatarIcon() { return avatarIcon; }
    public void setAvatarIcon(String avatarIcon) { this.avatarIcon = avatarIcon; }
    public Boolean getAnonymousModeEnabled() { return anonymousModeEnabled; }
    public void setAnonymousModeEnabled(Boolean anonymousModeEnabled) { this.anonymousModeEnabled = anonymousModeEnabled; }
    public String getRealFullName() { return realFullName; }
    public void setRealFullName(String realFullName) { this.realFullName = realFullName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getEmergencyContactPhone() { return emergencyContactPhone; }
    public void setEmergencyContactPhone(String emergencyContactPhone) { this.emergencyContactPhone = emergencyContactPhone; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getEducationLevel() { return educationLevel; }
    public void setEducationLevel(String educationLevel) { this.educationLevel = educationLevel; }
    public String getOccupation() { return occupation; }
    public void setOccupation(String occupation) { this.occupation = occupation; }
    public String getRelationshipStatus() { return relationshipStatus; }
    public void setRelationshipStatus(String relationshipStatus) { this.relationshipStatus = relationshipStatus; }
    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }
}
