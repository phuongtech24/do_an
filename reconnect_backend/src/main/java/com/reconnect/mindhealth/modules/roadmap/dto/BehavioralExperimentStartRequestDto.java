package com.reconnect.mindhealth.modules.roadmap.dto;

public class BehavioralExperimentStartRequestDto {
    private String prediction;
    private Integer predictionBelief;
    private String safetyBehaviorsJson;

    public String getPrediction() { return prediction; }
    public void setPrediction(String prediction) { this.prediction = prediction; }
    public Integer getPredictionBelief() { return predictionBelief; }
    public void setPredictionBelief(Integer predictionBelief) { this.predictionBelief = predictionBelief; }
    public String getSafetyBehaviorsJson() { return safetyBehaviorsJson; }
    public void setSafetyBehaviorsJson(String safetyBehaviorsJson) { this.safetyBehaviorsJson = safetyBehaviorsJson; }
}
