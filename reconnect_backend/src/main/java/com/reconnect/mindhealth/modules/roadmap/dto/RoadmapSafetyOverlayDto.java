package com.reconnect.mindhealth.modules.roadmap.dto;

public class RoadmapSafetyOverlayDto {

    private boolean active;
    private Integer riskScore;
    private Boolean redFlagActive;
    private String message;
    private String recommendedAction;

    public RoadmapSafetyOverlayDto() {
    }

    public RoadmapSafetyOverlayDto(boolean active, Integer riskScore, Boolean redFlagActive, String message,
            String recommendedAction) {
        this.active = active;
        this.riskScore = riskScore;
        this.redFlagActive = redFlagActive;
        this.message = message;
        this.recommendedAction = recommendedAction;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Integer getRiskScore() {
        return riskScore;
    }

    public void setRiskScore(Integer riskScore) {
        this.riskScore = riskScore;
    }

    public Boolean getRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(Boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getRecommendedAction() {
        return recommendedAction;
    }

    public void setRecommendedAction(String recommendedAction) {
        this.recommendedAction = recommendedAction;
    }
}
