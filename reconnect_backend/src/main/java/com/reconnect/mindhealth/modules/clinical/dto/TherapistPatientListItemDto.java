package com.reconnect.mindhealth.modules.clinical.dto;

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
}
