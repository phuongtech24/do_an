package com.reconnect.mindhealth.modules.ai.dto;

import java.util.List;

public class QuestProofVisionResultDto {
    private Boolean relevant;
    private Double confidence;
    private Integer score;
    private String reason;
    private List<String> detectedLabels;

    public QuestProofVisionResultDto() {
    }

    public QuestProofVisionResultDto(Boolean relevant, Double confidence, Integer score, String reason,
            List<String> detectedLabels) {
        this.relevant = relevant;
        this.confidence = confidence;
        this.score = score;
        this.reason = reason;
        this.detectedLabels = detectedLabels;
    }

    public Boolean getRelevant() {
        return relevant;
    }

    public void setRelevant(Boolean relevant) {
        this.relevant = relevant;
    }

    public Double getConfidence() {
        return confidence;
    }

    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public List<String> getDetectedLabels() {
        return detectedLabels;
    }

    public void setDetectedLabels(List<String> detectedLabels) {
        this.detectedLabels = detectedLabels;
    }
}

