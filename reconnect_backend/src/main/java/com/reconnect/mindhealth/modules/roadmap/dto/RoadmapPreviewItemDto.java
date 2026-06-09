package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDate;

import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestDifficulty;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;

public class RoadmapPreviewItemDto {
    private LocalDate date;
    private Integer cycleDayIndex;
    private Integer unlockOrder;
    private QuestCategory category;
    private QuestDifficulty difficulty;
    private QuestSourceType expectedSourceType;

    public RoadmapPreviewItemDto() {
    }

    public RoadmapPreviewItemDto(
            LocalDate date,
            Integer cycleDayIndex,
            Integer unlockOrder,
            QuestCategory category,
            QuestDifficulty difficulty,
            QuestSourceType expectedSourceType) {
        this.date = date;
        this.cycleDayIndex = cycleDayIndex;
        this.unlockOrder = unlockOrder;
        this.category = category;
        this.difficulty = difficulty;
        this.expectedSourceType = expectedSourceType;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public Integer getCycleDayIndex() {
        return cycleDayIndex;
    }

    public void setCycleDayIndex(Integer cycleDayIndex) {
        this.cycleDayIndex = cycleDayIndex;
    }

    public Integer getUnlockOrder() {
        return unlockOrder;
    }

    public void setUnlockOrder(Integer unlockOrder) {
        this.unlockOrder = unlockOrder;
    }

    public QuestCategory getCategory() {
        return category;
    }

    public void setCategory(QuestCategory category) {
        this.category = category;
    }

    public QuestDifficulty getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(QuestDifficulty difficulty) {
        this.difficulty = difficulty;
    }

    public QuestSourceType getExpectedSourceType() {
        return expectedSourceType;
    }

    public void setExpectedSourceType(QuestSourceType expectedSourceType) {
        this.expectedSourceType = expectedSourceType;
    }
}
