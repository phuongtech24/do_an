package com.reconnect.mindhealth.modules.assessment.dto;

import java.util.UUID;

public class LsasAnswerRequestDto {
    private UUID situationId;
    private Integer fearScore;
    private Integer avoidanceScore;

    public UUID getSituationId() { return situationId; }
    public void setSituationId(UUID situationId) { this.situationId = situationId; }
    public Integer getFearScore() { return fearScore; }
    public void setFearScore(Integer fearScore) { this.fearScore = fearScore; }
    public Integer getAvoidanceScore() { return avoidanceScore; }
    public void setAvoidanceScore(Integer avoidanceScore) { this.avoidanceScore = avoidanceScore; }
}
