package com.reconnect.mindhealth.modules.roadmap.entity;

import java.time.LocalDateTime;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.roadmap.enums.BehavioralExperimentStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "behavioral_experiments")
public class BehavioralExperiment extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "fear_ladder_item_id", nullable = false)
    private FearLadderItem fearLadderItem;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false)
    private QuestSourceType sourceType = QuestSourceType.SYSTEM;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private BehavioralExperimentStatus status = BehavioralExperimentStatus.PLANNED;

    @Column(name = "prediction", columnDefinition = "text")
    private String prediction;

    @Column(name = "prediction_belief")
    private Integer predictionBelief;

    @Column(name = "prediction_belief_before")
    private Integer predictionBeliefBefore;

    @Column(name = "prediction_belief_after")
    private Integer predictionBeliefAfter;

    @Column(name = "safety_behaviors_json", columnDefinition = "json")
    private String safetyBehaviorsJson;

    @Column(name = "outcome", columnDefinition = "text")
    private String outcome;

    @Column(name = "learning", columnDefinition = "text")
    private String learning;

    @Column(name = "execution_notes", columnDefinition = "text")
    private String executionNotes;

    @Column(name = "proof_image_url")
    private String proofImageUrl;

    @Column(name = "debrief", columnDefinition = "text")
    private String debrief;

    @Column(name = "post_fear_score")
    private Integer postFearScore;

    @Column(name = "post_avoidance_score")
    private Integer postAvoidanceScore;

    @Column(name = "assigned_at", nullable = false)
    private LocalDateTime assignedAt = LocalDateTime.now();

    @Column(name = "due_date")
    private LocalDateTime dueDate;

    @Column(name = "setup_completed_at")
    private LocalDateTime setupCompletedAt;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "focus_reminder_shown")
    private Boolean focusReminderShown = false;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    public PatientProfile getPatientProfile() { return patientProfile; }
    public void setPatientProfile(PatientProfile patientProfile) { this.patientProfile = patientProfile; }
    public FearLadderItem getFearLadderItem() { return fearLadderItem; }
    public void setFearLadderItem(FearLadderItem fearLadderItem) { this.fearLadderItem = fearLadderItem; }
    public QuestSourceType getSourceType() { return sourceType; }
    public void setSourceType(QuestSourceType sourceType) { this.sourceType = sourceType; }
    public BehavioralExperimentStatus getStatus() { return status; }
    public void setStatus(BehavioralExperimentStatus status) { this.status = status; }
    public String getPrediction() { return prediction; }
    public void setPrediction(String prediction) { this.prediction = prediction; }
    public Integer getPredictionBelief() { return predictionBelief; }
    public void setPredictionBelief(Integer predictionBelief) { this.predictionBelief = predictionBelief; }
    public Integer getPredictionBeliefBefore() { return predictionBeliefBefore; }
    public void setPredictionBeliefBefore(Integer predictionBeliefBefore) { this.predictionBeliefBefore = predictionBeliefBefore; }
    public Integer getPredictionBeliefAfter() { return predictionBeliefAfter; }
    public void setPredictionBeliefAfter(Integer predictionBeliefAfter) { this.predictionBeliefAfter = predictionBeliefAfter; }
    public String getSafetyBehaviorsJson() { return safetyBehaviorsJson; }
    public void setSafetyBehaviorsJson(String safetyBehaviorsJson) { this.safetyBehaviorsJson = safetyBehaviorsJson; }
    public String getOutcome() { return outcome; }
    public void setOutcome(String outcome) { this.outcome = outcome; }
    public String getLearning() { return learning; }
    public void setLearning(String learning) { this.learning = learning; }
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
    public LocalDateTime getSetupCompletedAt() { return setupCompletedAt; }
    public void setSetupCompletedAt(LocalDateTime setupCompletedAt) { this.setupCompletedAt = setupCompletedAt; }
    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
    public Boolean getFocusReminderShown() { return focusReminderShown; }
    public void setFocusReminderShown(Boolean focusReminderShown) { this.focusReminderShown = focusReminderShown; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
}
