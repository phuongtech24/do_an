package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class RoadmapPreviewDto {
    private UUID patientId;
    private LocalDate startDate;
    private Integer days;
    private Integer lsasScore;
    private Integer totalSlots;
    private Integer behavioralCount;
    private Integer cognitiveCount;
    private List<RoadmapPreviewItemDto> items = new ArrayList<>();

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public Integer getDays() {
        return days;
    }

    public void setDays(Integer days) {
        this.days = days;
    }

    public Integer getLsasScore() {
        return lsasScore;
    }

    public void setLsasScore(Integer lsasScore) {
        this.lsasScore = lsasScore;
    }

    public Integer getTotalSlots() {
        return totalSlots;
    }

    public void setTotalSlots(Integer totalSlots) {
        this.totalSlots = totalSlots;
    }

    public Integer getBehavioralCount() {
        return behavioralCount;
    }

    public void setBehavioralCount(Integer behavioralCount) {
        this.behavioralCount = behavioralCount;
    }

    public Integer getCognitiveCount() {
        return cognitiveCount;
    }

    public void setCognitiveCount(Integer cognitiveCount) {
        this.cognitiveCount = cognitiveCount;
    }

    public List<RoadmapPreviewItemDto> getItems() {
        return items;
    }

    public void setItems(List<RoadmapPreviewItemDto> items) {
        this.items = items;
    }
}
