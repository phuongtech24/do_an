package com.reconnect.mindhealth.modules.roadmap.dto;

import java.util.UUID;

public class FearLadderRerateItemDto {
    private UUID ladderItemId;
    private Integer fearScore;
    private Integer avoidanceScore;

    public UUID getLadderItemId() { return ladderItemId; }
    public void setLadderItemId(UUID ladderItemId) { this.ladderItemId = ladderItemId; }
    public Integer getFearScore() { return fearScore; }
    public void setFearScore(Integer fearScore) { this.fearScore = fearScore; }
    public Integer getAvoidanceScore() { return avoidanceScore; }
    public void setAvoidanceScore(Integer avoidanceScore) { this.avoidanceScore = avoidanceScore; }
}
