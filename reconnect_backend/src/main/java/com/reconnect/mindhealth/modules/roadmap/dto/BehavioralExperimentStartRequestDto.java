package com.reconnect.mindhealth.modules.roadmap.dto;

public class BehavioralExperimentStartRequestDto {
    private String prediction;
    private Integer predictionBelief;
    private Integer predictionBeliefBefore;
    private String safetyBehaviorsJson;
    private Boolean dropWithoutSafetyBehaviors;

    public String getPrediction() { return prediction; }
    public void setPrediction(String prediction) { this.prediction = prediction; }
    public Integer getPredictionBelief() { return predictionBelief; }
    public void setPredictionBelief(Integer predictionBelief) { this.predictionBelief = predictionBelief; }
    public Integer getPredictionBeliefBefore() { return predictionBeliefBefore; }
    public void setPredictionBeliefBefore(Integer predictionBeliefBefore) { this.predictionBeliefBefore = predictionBeliefBefore; }
    public String getSafetyBehaviorsJson() { return safetyBehaviorsJson; }
    public void setSafetyBehaviorsJson(String safetyBehaviorsJson) { this.safetyBehaviorsJson = safetyBehaviorsJson; }
    public Boolean getDropWithoutSafetyBehaviors() { return dropWithoutSafetyBehaviors; }
    public void setDropWithoutSafetyBehaviors(Boolean dropWithoutSafetyBehaviors) { this.dropWithoutSafetyBehaviors = dropWithoutSafetyBehaviors; }
}
