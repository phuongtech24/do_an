package com.reconnect.mindhealth.modules.clinical.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.Status;

public class AdminPatientProfileListItemDto {

    private String patientId;
    private String email;
    private String nickname;
    private Status status;
    private Integer currentLsasScore;
    private Boolean redFlagActive;
    private LocalDateTime graduatedAt;
    private Boolean active;
    private String taperingStage;
    private Boolean triageRequired;
    private String triageStatus;
    private Integer triagePriority;
    private LocalDateTime triageTriggeredAt;

    private String therapistId;
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

    public AdminPatientProfileListItemDto() {
    }

    public AdminPatientProfileListItemDto(PatientProfile p) {
        UUID id = p.getId();
        this.patientId = id != null ? id.toString() : null;
        this.email = p.getUser() != null ? p.getUser().getEmail() : null;
        this.nickname = p.getNickName();
        this.status = p.getStatus();
        this.currentLsasScore = p.getCurrentLsasScore();
        this.redFlagActive = p.getIsRedFlagActive();
        this.graduatedAt = p.getGraduatedAt();
        this.active = p.getUser() != null ? p.getUser().getIsActive() : null;
        this.taperingStage = p.getTaperingStage() != null ? p.getTaperingStage().name() : null;
        this.triageRequired = p.getTriageRequired();
        this.triageStatus = p.getTriageStatus() != null ? p.getTriageStatus().name() : null;
        this.triagePriority = p.getTriagePriority();
        this.triageTriggeredAt = p.getTriageTriggeredAt();
        this.avatarIcon = p.getAvatarIcon();
        this.anonymousModeEnabled = p.getAnonymousModeEnabled();
        this.realFullName = p.getRealFullName();
        this.phoneNumber = p.getPhoneNumber();
        this.emergencyContactPhone = p.getEmergencyContactPhone();
        this.dateOfBirth = p.getDateOfBirth();
        this.gender = p.getGender();
        this.educationLevel = p.getEducationLevel();
        this.occupation = p.getOccupation();
        this.relationshipStatus = p.getRelationshipStatus();
        this.medicalHistory = p.getMedicalHistory();

        if (p.getTherapist() != null) {
            this.therapistId = p.getTherapist().getId() != null ? p.getTherapist().getId().toString() : null;
            this.therapistName = p.getTherapist().getFullName();
        }
    }

    public String getPatientId() {
        return patientId;
    }

    public void setPatientId(String patientId) {
        this.patientId = patientId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Integer getCurrentLsasScore() {
        return currentLsasScore;
    }

    public void setCurrentLsasScore(Integer currentLsasScore) {
        this.currentLsasScore = currentLsasScore;
    }

    public Boolean getRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(Boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }

    public LocalDateTime getGraduatedAt() {
        return graduatedAt;
    }

    public void setGraduatedAt(LocalDateTime graduatedAt) {
        this.graduatedAt = graduatedAt;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public String getTaperingStage() {
        return taperingStage;
    }

    public void setTaperingStage(String taperingStage) {
        this.taperingStage = taperingStage;
    }

    public Boolean getTriageRequired() {
        return triageRequired;
    }

    public void setTriageRequired(Boolean triageRequired) {
        this.triageRequired = triageRequired;
    }

    public String getTriageStatus() {
        return triageStatus;
    }

    public void setTriageStatus(String triageStatus) {
        this.triageStatus = triageStatus;
    }

    public Integer getTriagePriority() {
        return triagePriority;
    }

    public void setTriagePriority(Integer triagePriority) {
        this.triagePriority = triagePriority;
    }

    public LocalDateTime getTriageTriggeredAt() {
        return triageTriggeredAt;
    }

    public void setTriageTriggeredAt(LocalDateTime triageTriggeredAt) {
        this.triageTriggeredAt = triageTriggeredAt;
    }

    public String getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(String therapistId) {
        this.therapistId = therapistId;
    }

    public String getTherapistName() {
        return therapistName;
    }

    public void setTherapistName(String therapistName) {
        this.therapistName = therapistName;
    }

    public String getAvatarIcon() {
        return avatarIcon;
    }

    public void setAvatarIcon(String avatarIcon) {
        this.avatarIcon = avatarIcon;
    }

    public Boolean getAnonymousModeEnabled() {
        return anonymousModeEnabled;
    }

    public void setAnonymousModeEnabled(Boolean anonymousModeEnabled) {
        this.anonymousModeEnabled = anonymousModeEnabled;
    }

    public String getRealFullName() {
        return realFullName;
    }

    public void setRealFullName(String realFullName) {
        this.realFullName = realFullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmergencyContactPhone() {
        return emergencyContactPhone;
    }

    public void setEmergencyContactPhone(String emergencyContactPhone) {
        this.emergencyContactPhone = emergencyContactPhone;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getEducationLevel() {
        return educationLevel;
    }

    public void setEducationLevel(String educationLevel) {
        this.educationLevel = educationLevel;
    }

    public String getOccupation() {
        return occupation;
    }

    public void setOccupation(String occupation) {
        this.occupation = occupation;
    }

    public String getRelationshipStatus() {
        return relationshipStatus;
    }

    public void setRelationshipStatus(String relationshipStatus) {
        this.relationshipStatus = relationshipStatus;
    }

    public String getMedicalHistory() {
        return medicalHistory;
    }

    public void setMedicalHistory(String medicalHistory) {
        this.medicalHistory = medicalHistory;
    }
}
