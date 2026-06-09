package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.roadmap.entity.BehavioralExperiment;
import com.reconnect.mindhealth.modules.roadmap.enums.BehavioralExperimentStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;

public class BehavioralExperimentDto {
    private UUID id;
    private UUID patientId;
    private FearLadderItemDto ladderItem;
    private QuestSourceType sourceType;
    private BehavioralExperimentStatus status;
    private String prediction;
    private Integer predictionBelief;
    private String safetyBehaviorsJson;
    private String executionNotes;
    private String proofImageUrl;
    private String debrief;
    private Integer postFearScore;
    private Integer postAvoidanceScore;
    private LocalDateTime assignedAt;
    private LocalDateTime dueDate;
    private LocalDateTime completedAt;

    public BehavioralExperimentDto() {
    }

    public BehavioralExperimentDto(BehavioralExperiment entity) {
        this.id = entity.getId();
        this.patientId = entity.getPatientProfile().getId();
        this.ladderItem = new FearLadderItemDto(entity.getFearLadderItem());
        this.sourceType = entity.getSourceType();
        this.status = entity.getStatus();
        this.prediction = entity.getPrediction();
        this.predictionBelief = entity.getPredictionBelief();
        this.safetyBehaviorsJson = entity.getSafetyBehaviorsJson();
        this.executionNotes = entity.getExecutionNotes();
        this.proofImageUrl = entity.getProofImageUrl();
        this.debrief = entity.getDebrief();
        this.postFearScore = entity.getPostFearScore();
        this.postAvoidanceScore = entity.getPostAvoidanceScore();
        this.assignedAt = entity.getAssignedAt();
        this.dueDate = entity.getDueDate();
        this.completedAt = entity.getCompletedAt();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public FearLadderItemDto getLadderItem() { return ladderItem; }
    public void setLadderItem(FearLadderItemDto ladderItem) { this.ladderItem = ladderItem; }
    public QuestSourceType getSourceType() { return sourceType; }
    public void setSourceType(QuestSourceType sourceType) { this.sourceType = sourceType; }
    public BehavioralExperimentStatus getStatus() { return status; }
    public void setStatus(BehavioralExperimentStatus status) { this.status = status; }
    public String getPrediction() { return prediction; }
    public void setPrediction(String prediction) { this.prediction = prediction; }
    public Integer getPredictionBelief() { return predictionBelief; }
    public void setPredictionBelief(Integer predictionBelief) { this.predictionBelief = predictionBelief; }
    public String getSafetyBehaviorsJson() { return safetyBehaviorsJson; }
    public void setSafetyBehaviorsJson(String safetyBehaviorsJson) { this.safetyBehaviorsJson = safetyBehaviorsJson; }
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
    public LocalDateTime getAssignedAt() { return assignedAt; }
    public void setAssignedAt(LocalDateTime assignedAt) { this.assignedAt = assignedAt; }
    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
}
