package com.reconnect.mindhealth.modules.roadmap.dto;

public class BehavioralExperimentDebriefRequestDto {
    private String executionNotes;
    private String proofImageUrl;
    private String debrief;
    private Integer postFearScore;
    private Integer postAvoidanceScore;

    public String getExecutionNotes() { return executionNotes; }
    public void setExecutionNotes(String executionNotes) { this.executionNotes = executionNotes; }
    public String getProofImageUrl() { return proofImageUrl; }
    public void setProofImageUrl(String proofImageUrl) { this.proofImageUrl = proofImageUrl; }
    public String getDebrief() { return debrief; }
    public void setDebrief(String debrief) { this.debrief = debrief; }
    public Integer getPostFearScore() { return postFearScore; }
    public void setPostFearScore(Integer postFearScore) { this.postFearScore = postFearScore; }
    public Integer getPostAvoidanceScore() { return postAvoidanceScore; }
    public void setPostAvoidanceScore(Integer postAvoidanceScore) { this.postAvoidanceScore = postAvoidanceScore; }
}
