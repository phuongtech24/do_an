package com.reconnect.mindhealth.modules.roadmap.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.assessment.enums.LsasSituationGroup;
import com.reconnect.mindhealth.modules.roadmap.entity.FearLadderItem;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderBucket;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderStatus;

public class FearLadderItemDto {
    private UUID id;
    private UUID situationId;
    private Integer situationNumber;
    private String situationText;
    private LsasSituationGroup situationGroup;
    private Integer baselineTotalScore;
    private Integer currentFearScore;
    private Integer currentAvoidanceScore;
    private Integer currentTotalScore;
    private FearLadderBucket bucket;
    private Integer ladderOrder;
    private FearLadderStatus status;
    private Boolean goalMatch;
    private Boolean unlocked;
    private java.util.Date masteredAt;

    public FearLadderItemDto() {
    }

    public FearLadderItemDto(FearLadderItem entity) {
        this.id = entity.getId();
        this.situationId = entity.getSituation().getId();
        this.situationNumber = entity.getSituation().getSituationNumber();
        this.situationText = entity.getSituation().getText();
        this.situationGroup = entity.getSituation().getSituationGroup();
        this.baselineTotalScore = entity.getBaselineTotalScore();
        this.currentFearScore = entity.getCurrentFearScore();
        this.currentAvoidanceScore = entity.getCurrentAvoidanceScore();
        this.currentTotalScore = entity.getCurrentTotalScore();
        this.bucket = entity.getBucket();
        this.ladderOrder = entity.getLadderOrder();
        this.status = entity.getStatus();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getSituationId() { return situationId; }
    public void setSituationId(UUID situationId) { this.situationId = situationId; }
    public Integer getSituationNumber() { return situationNumber; }
    public void setSituationNumber(Integer situationNumber) { this.situationNumber = situationNumber; }
    public String getSituationText() { return situationText; }
    public void setSituationText(String situationText) { this.situationText = situationText; }
    public LsasSituationGroup getSituationGroup() { return situationGroup; }
    public void setSituationGroup(LsasSituationGroup situationGroup) { this.situationGroup = situationGroup; }
    public Integer getBaselineTotalScore() { return baselineTotalScore; }
    public void setBaselineTotalScore(Integer baselineTotalScore) { this.baselineTotalScore = baselineTotalScore; }
    public Integer getCurrentFearScore() { return currentFearScore; }
    public void setCurrentFearScore(Integer currentFearScore) { this.currentFearScore = currentFearScore; }
    public Integer getCurrentAvoidanceScore() { return currentAvoidanceScore; }
    public void setCurrentAvoidanceScore(Integer currentAvoidanceScore) { this.currentAvoidanceScore = currentAvoidanceScore; }
    public Integer getCurrentTotalScore() { return currentTotalScore; }
    public void setCurrentTotalScore(Integer currentTotalScore) { this.currentTotalScore = currentTotalScore; }
    public FearLadderBucket getBucket() { return bucket; }
    public void setBucket(FearLadderBucket bucket) { this.bucket = bucket; }
    public Integer getLadderOrder() { return ladderOrder; }
    public void setLadderOrder(Integer ladderOrder) { this.ladderOrder = ladderOrder; }
    public FearLadderStatus getStatus() { return status; }
    public void setStatus(FearLadderStatus status) { this.status = status; }
    public Boolean getGoalMatch() { return goalMatch; }
    public void setGoalMatch(Boolean goalMatch) { this.goalMatch = goalMatch; }
    public Boolean getUnlocked() { return unlocked; }
    public void setUnlocked(Boolean unlocked) { this.unlocked = unlocked; }
    public java.util.Date getMasteredAt() { return masteredAt; }
    public void setMasteredAt(java.util.Date masteredAt) { this.masteredAt = masteredAt; }
}
