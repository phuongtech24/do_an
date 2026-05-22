package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;

public class PatientQuestDto extends BaseObjectDto {

    private UUID patientId;
    private UUID questTemplateId;
    private String title;
    private String description;
    private QuestCategory category;
    private QuestStatus status;
    private Integer masteryScore;
    private Integer pleasureScore;
    private String proofImageUrl;
    private Boolean proofAiRelevant;
    private Double proofAiConfidence;
    private Integer proofAiScore;
    private String proofAiReason;
    private LocalDateTime assignedAt;
    private LocalDateTime dueDate;
    private LocalDateTime completedAt;
    private LocalDateTime proofVerifiedAt;

    public PatientQuestDto() {
    }

    public PatientQuestDto(PatientQuest entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());
            this.setCreatedBy(entity.getCreatedBy());
            this.setModifyDate(entity.getModifyDate());
            this.setModifiedBy(entity.getModifiedBy());

            if (entity.getPatientProfile() != null) {
                this.patientId = entity.getPatientProfile().getId();
            }
            if (entity.getQuestTemplate() != null) {
                this.questTemplateId = entity.getQuestTemplate().getId();
                this.title = entity.getQuestTemplate().getTitle();
                this.description = entity.getQuestTemplate().getDescription();
                this.category = entity.getQuestTemplate().getCategory();
            }

            this.status = entity.getStatus();
            this.masteryScore = entity.getMasteryScore();
            this.pleasureScore = entity.getPleasureScore();
            this.proofImageUrl = entity.getProofImageUrl();
            this.proofAiRelevant = entity.getProofAiRelevant();
            this.proofAiConfidence = entity.getProofAiConfidence();
            this.proofAiScore = entity.getProofAiScore();
            this.proofAiReason = entity.getProofAiReason();
            this.assignedAt = entity.getAssignedAt();
            this.dueDate = entity.getDueDate();
            this.completedAt = entity.getCompletedAt();
            this.proofVerifiedAt = entity.getProofVerifiedAt();
        }
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public UUID getQuestTemplateId() {
        return questTemplateId;
    }

    public void setQuestTemplateId(UUID questTemplateId) {
        this.questTemplateId = questTemplateId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public QuestCategory getCategory() {
        return category;
    }

    public void setCategory(QuestCategory category) {
        this.category = category;
    }

    public QuestStatus getStatus() {
        return status;
    }

    public void setStatus(QuestStatus status) {
        this.status = status;
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

    public LocalDateTime getProofVerifiedAt() {
        return proofVerifiedAt;
    }

    public void setProofVerifiedAt(LocalDateTime proofVerifiedAt) {
        this.proofVerifiedAt = proofVerifiedAt;
    }
}
