package com.reconnect.mindhealth.modules.roadmap.dto;

public class BehavioralExperimentDebriefRequestDto {
    private String executionNotes;
    private String proofImageUrl;
    private String debrief;
    private String outcome;
    private String learning;
    private Integer predictionBeliefAfter;
    private Integer postFearScore;
    private Integer postAvoidanceScore;

    public String getExecutionNotes() { return executionNotes; }
    public void setExecutionNotes(String executionNotes) { this.executionNotes = executionNotes; }
    public String getProofImageUrl() { return proofImageUrl; }
    public void setProofImageUrl(String proofImageUrl) { this.proofImageUrl = proofImageUrl; }
    public String getDebrief() { return debrief; }
    public void setDebrief(String debrief) { this.debrief = debrief; }
    public String getOutcome() { return outcome; }
    public void setOutcome(String outcome) { this.outcome = outcome; }
    public String getLearning() { return learning; }
    public void setLearning(String learning) { this.learning = learning; }
    public Integer getPredictionBeliefAfter() { return predictionBeliefAfter; }
    public void setPredictionBeliefAfter(Integer predictionBeliefAfter) { this.predictionBeliefAfter = predictionBeliefAfter; }
    public Integer getPostFearScore() { return postFearScore; }
    public void setPostFearScore(Integer postFearScore) { this.postFearScore = postFearScore; }
    public Integer getPostAvoidanceScore() { return postAvoidanceScore; }
    public void setPostAvoidanceScore(Integer postAvoidanceScore) { this.postAvoidanceScore = postAvoidanceScore; }
}
