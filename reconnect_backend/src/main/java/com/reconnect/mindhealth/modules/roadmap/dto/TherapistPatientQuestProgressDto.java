package com.reconnect.mindhealth.modules.roadmap.dto;

import java.util.List;
import java.util.UUID;

public class TherapistPatientQuestProgressDto {

    private UUID patientId;
    private long totalAssigned;
    private long completed;
    private double completionRate;
    private long systemAssigned;
    private long therapistAssigned;
    private Double averageMastery;
    private Double averagePleasure;
    private List<TherapistPatientQuestProgressItemDto> recentQuests;

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public long getTotalAssigned() {
        return totalAssigned;
    }

    public void setTotalAssigned(long totalAssigned) {
        this.totalAssigned = totalAssigned;
    }

    public long getCompleted() {
        return completed;
    }

    public void setCompleted(long completed) {
        this.completed = completed;
    }

    public double getCompletionRate() {
        return completionRate;
    }

    public void setCompletionRate(double completionRate) {
        this.completionRate = completionRate;
    }

    public long getSystemAssigned() {
        return systemAssigned;
    }

    public void setSystemAssigned(long systemAssigned) {
        this.systemAssigned = systemAssigned;
    }

    public long getTherapistAssigned() {
        return therapistAssigned;
    }

    public void setTherapistAssigned(long therapistAssigned) {
        this.therapistAssigned = therapistAssigned;
    }

    public Double getAverageMastery() {
        return averageMastery;
    }

    public void setAverageMastery(Double averageMastery) {
        this.averageMastery = averageMastery;
    }

    public Double getAveragePleasure() {
        return averagePleasure;
    }

    public void setAveragePleasure(Double averagePleasure) {
        this.averagePleasure = averagePleasure;
    }

    public List<TherapistPatientQuestProgressItemDto> getRecentQuests() {
        return recentQuests;
    }

    public void setRecentQuests(List<TherapistPatientQuestProgressItemDto> recentQuests) {
        this.recentQuests = recentQuests;
    }
}
