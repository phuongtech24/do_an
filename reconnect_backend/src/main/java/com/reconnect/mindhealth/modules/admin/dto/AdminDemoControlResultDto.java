package com.reconnect.mindhealth.modules.admin.dto;

import java.util.UUID;

public class AdminDemoControlResultDto {
    private UUID patientId;
    private String action;
    private String message;
    private Integer currentRiskScore;
    private Boolean redFlagActive;
    private Integer createdQuests;

    public AdminDemoControlResultDto() {
    }

    public AdminDemoControlResultDto(UUID patientId, String action, String message) {
        this.patientId = patientId;
        this.action = action;
        this.message = message;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }

    public Boolean getRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(Boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }

    public Integer getCreatedQuests() {
        return createdQuests;
    }

    public void setCreatedQuests(Integer createdQuests) {
        this.createdQuests = createdQuests;
    }
}
