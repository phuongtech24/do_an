package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;

public class TherapistPatientQuestProgressItemDto {

    private UUID questId;
    private String title;
    private QuestCategory category;
    private QuestSourceType sourceType;
    private QuestStatus status;
    private Integer masteryScore;
    private Integer pleasureScore;
    private LocalDateTime assignedAt;
    private LocalDateTime dueDate;
    private LocalDateTime completedAt;

    public TherapistPatientQuestProgressItemDto() {
    }

    public TherapistPatientQuestProgressItemDto(PatientQuest entity) {
        this.questId = entity.getId();
        if (entity.getQuestTemplate() != null) {
            this.title = entity.getQuestTemplate().getTitle();
            this.category = entity.getQuestTemplate().getCategory();
        }
        this.sourceType = entity.getSourceType();
        this.status = entity.getStatus();
        this.masteryScore = entity.getMasteryScore();
        this.pleasureScore = entity.getPleasureScore();
        this.assignedAt = entity.getAssignedAt();
        this.dueDate = entity.getDueDate();
        this.completedAt = entity.getCompletedAt();
    }

    public UUID getQuestId() {
        return questId;
    }

    public void setQuestId(UUID questId) {
        this.questId = questId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public QuestCategory getCategory() {
        return category;
    }

    public void setCategory(QuestCategory category) {
        this.category = category;
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
