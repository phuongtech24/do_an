package com.reconnect.mindhealth.modules.ai.dto;

import java.util.ArrayList;
import java.util.List;

public class JournalAiRiskResultDto {
    private Integer aiRiskScore;
    private String severityLevel;
    private List<String> distortions = new ArrayList<>();
    private String reason;

    public JournalAiRiskResultDto() {
    }

    public JournalAiRiskResultDto(Integer aiRiskScore, String severityLevel) {
        this(aiRiskScore, severityLevel, new ArrayList<>(), null);
    }

    public JournalAiRiskResultDto(Integer aiRiskScore, String severityLevel, List<String> distortions, String reason) {
        this.aiRiskScore = aiRiskScore;
        this.severityLevel = severityLevel;
        this.distortions = distortions != null ? distortions : new ArrayList<>();
        this.reason = reason;
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

    public List<String> getDistortions() {
        return distortions;
    }

    public void setDistortions(List<String> distortions) {
        this.distortions = distortions != null ? distortions : new ArrayList<>();
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
