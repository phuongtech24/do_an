package com.reconnect.mindhealth.modules.roadmap.entity;

import java.time.LocalDateTime;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "patient_quests")
public class PatientQuest extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quest_template_id")
    private QuestTemplate questTemplate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_by_therapist_id")
    private TherapistProfile assignedByTherapist;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false)
    private QuestSourceType sourceType = QuestSourceType.SYSTEM;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private QuestStatus status = QuestStatus.LOCKED;

    @Column(name = "unlock_order")
    private Integer unlockOrder = 1;

    @Column(name = "proof_image_url")
    private String proofImageUrl;

    @Column(name = "proof_ai_relevant")
    private Boolean proofAiRelevant;

    @Column(name = "proof_ai_confidence")
    private Double proofAiConfidence;

    @Column(name = "proof_ai_score")
    private Integer proofAiScore;

    @Column(name = "proof_ai_reason", columnDefinition = "text")
    private String proofAiReason;

    @Column(name = "proof_verified_at")
    private LocalDateTime proofVerifiedAt;

    @Column(name = "mastery_score")
    private Integer masteryScore;

    @Column(name = "pleasure_score")
    private Integer pleasureScore;

    @Column(name = "assigned_at", nullable = false)
    private LocalDateTime assignedAt;

    @Column(name = "due_date", nullable = false)
    private LocalDateTime dueDate;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
    }

    public QuestTemplate getQuestTemplate() {
        return questTemplate;
    }

    public void setQuestTemplate(QuestTemplate questTemplate) {
        this.questTemplate = questTemplate;
    }

    public TherapistProfile getAssignedByTherapist() {
        return assignedByTherapist;
    }

    public void setAssignedByTherapist(TherapistProfile assignedByTherapist) {
        this.assignedByTherapist = assignedByTherapist;
    }

    public QuestSourceType getSourceType() {
        return sourceType;
    }

    public void setSourceType(QuestSourceType sourceType) {
        this.sourceType = sourceType;
    }

    public QuestStatus getStatus() {
        return status;
    }

    public void setStatus(QuestStatus status) {
        this.status = status;
    }

    public Integer getUnlockOrder() {
        return unlockOrder;
    }

    public void setUnlockOrder(Integer unlockOrder) {
        this.unlockOrder = unlockOrder;
    }

    public String getProofImageUrl() {
        return proofImageUrl;
    }

    public void setProofImageUrl(String proofImageUrl) {
        this.proofImageUrl = proofImageUrl;
    }

    public Boolean getProofAiRelevant() {
        return proofAiRelevant;
    }

    public void setProofAiRelevant(Boolean proofAiRelevant) {
        this.proofAiRelevant = proofAiRelevant;
    }

    public Double getProofAiConfidence() {
        return proofAiConfidence;
    }

    public void setProofAiConfidence(Double proofAiConfidence) {
        this.proofAiConfidence = proofAiConfidence;
    }

    public Integer getProofAiScore() {
        return proofAiScore;
    }

    public void setProofAiScore(Integer proofAiScore) {
        this.proofAiScore = proofAiScore;
    }

    public String getProofAiReason() {
        return proofAiReason;
    }

    public void setProofAiReason(String proofAiReason) {
        this.proofAiReason = proofAiReason;
    }

    public LocalDateTime getProofVerifiedAt() {
        return proofVerifiedAt;
    }

    public void setProofVerifiedAt(LocalDateTime proofVerifiedAt) {
        this.proofVerifiedAt = proofVerifiedAt;
    }

    public Integer getMasteryScore() {
        return masteryScore;
    }

    public void setMasteryScore(Integer masteryScore) {
        this.masteryScore = masteryScore;
    }

    public Integer getPleasureScore() {
        return pleasureScore;
    }

    public void setPleasureScore(Integer pleasureScore) {
        this.pleasureScore = pleasureScore;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    public LocalDateTime getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDateTime dueDate) {
        this.dueDate = dueDate;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
}
