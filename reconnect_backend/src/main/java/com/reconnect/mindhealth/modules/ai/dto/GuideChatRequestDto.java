package com.reconnect.mindhealth.modules.ai.dto;

import jakarta.validation.constraints.NotBlank;

public class GuideChatRequestDto {

    @NotBlank
    private String userMessage;

    @NotBlank
    private String screenContext;

    private String patientRoute;

    private Integer programWeek;

    private String programPhaseCode;

    private boolean redFlagActive;

    private Integer currentRiskScore;

    public String getUserMessage() {
        return userMessage;
    }

    public void setUserMessage(String userMessage) {
        this.userMessage = userMessage;
    }

    public String getScreenContext() {
        return screenContext;
    }

    public void setScreenContext(String screenContext) {
        this.screenContext = screenContext;
    }

    public String getPatientRoute() {
        return patientRoute;
    }

    public void setPatientRoute(String patientRoute) {
        this.patientRoute = patientRoute;
    }

    public Integer getProgramWeek() {
        return programWeek;
    }

    public void setProgramWeek(Integer programWeek) {
        this.programWeek = programWeek;
    }

    public String getProgramPhaseCode() {
        return programPhaseCode;
    }

    public void setProgramPhaseCode(String programPhaseCode) {
        this.programPhaseCode = programPhaseCode;
    }

    public boolean isRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }
}
