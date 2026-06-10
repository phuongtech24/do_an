package com.reconnect.mindhealth.modules.admin.dto;

import java.util.UUID;

public class AdminDemoControlResultDto {
    private UUID patientId;
    private String action;
    private String message;
    private Integer currentRiskScore;
    private Integer currentLsasScore;
    private Boolean redFlagActive;
    private Integer createdQuests;
    private String clinicalRoute;
    private Boolean clinicalAttention;
    private String taperingStage;
    private String graduatedAt;
    private String guestState;

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

    public Integer getCreatedQuests() {
        return createdQuests;
    }

    public void setCreatedQuests(Integer createdQuests) {
        this.createdQuests = createdQuests;
    }

    public String getClinicalRoute() {
        return clinicalRoute;
    }

    public void setClinicalRoute(String clinicalRoute) {
        this.clinicalRoute = clinicalRoute;
    }

    public Boolean getClinicalAttention() {
        return clinicalAttention;
    }

    public void setClinicalAttention(Boolean clinicalAttention) {
        this.clinicalAttention = clinicalAttention;
    }

    public String getTaperingStage() {
        return taperingStage;
    }

    public void setTaperingStage(String taperingStage) {
        this.taperingStage = taperingStage;
    }

    public String getGraduatedAt() {
        return graduatedAt;
    }

    public void setGraduatedAt(String graduatedAt) {
        this.graduatedAt = graduatedAt;
    }

    public String getGuestState() {
        return guestState;
    }

    public void setGuestState(String guestState) {
        this.guestState = guestState;
    }
}
