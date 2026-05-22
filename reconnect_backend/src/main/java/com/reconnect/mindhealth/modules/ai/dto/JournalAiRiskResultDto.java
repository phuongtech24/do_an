package com.reconnect.mindhealth.modules.ai.dto;

public class JournalAiRiskResultDto {
    private Integer aiRiskScore;
    private String severityLevel;

    public JournalAiRiskResultDto() {
    }

    public JournalAiRiskResultDto(Integer aiRiskScore, String severityLevel) {
        this.aiRiskScore = aiRiskScore;
        this.severityLevel = severityLevel;
    }

    public Integer getAiRiskScore() {
        return aiRiskScore;
    }

    public void setAiRiskScore(Integer aiRiskScore) {
        this.aiRiskScore = aiRiskScore;
    }

    public String getSeverityLevel() {
        return severityLevel;
    }

    public void setSeverityLevel(String severityLevel) {
        this.severityLevel = severityLevel;
    }
}

