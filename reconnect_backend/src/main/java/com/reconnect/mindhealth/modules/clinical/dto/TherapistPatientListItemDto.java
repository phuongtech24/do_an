package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

public class TherapistPatientListItemDto {
    private UUID patientId;
    private String nickname;
    private Integer currentRiskScore;
    private Boolean isRedFlagActive;

    public TherapistPatientListItemDto() {
    }

    public TherapistPatientListItemDto(PatientProfile p) {
        this.patientId = p.getId();
        this.nickname = p.getNickName();
        this.currentRiskScore = p.getCurrentRiskScore();
        this.isRedFlagActive = p.getIsRedFlagActive();
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }

    public Boolean getIsRedFlagActive() {
        return isRedFlagActive;
    }

    public void setIsRedFlagActive(Boolean isRedFlagActive) {
        this.isRedFlagActive = isRedFlagActive;
    }
}

