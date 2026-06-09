package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDate;

public class DailyQuestAssignmentSummaryDto {

    private LocalDate date;
    private int processedPatients;
    private int createdQuests;
    private int skippedPatients;
    private int failedPatients;

    public DailyQuestAssignmentSummaryDto() {
    }

    public DailyQuestAssignmentSummaryDto(LocalDate date) {
        this.date = date;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public int getProcessedPatients() {
        return processedPatients;
    }

    public void setProcessedPatients(int processedPatients) {
        this.processedPatients = processedPatients;
    }

    public int getCreatedQuests() {
        return createdQuests;
    }

    public void setCreatedQuests(int createdQuests) {
        this.createdQuests = createdQuests;
    }

    public int getSkippedPatients() {
        return skippedPatients;
    }

    public void setSkippedPatients(int skippedPatients) {
        this.skippedPatients = skippedPatients;
    }

    public int getFailedPatients() {
        return failedPatients;
    }

    public void setFailedPatients(int failedPatients) {
        this.failedPatients = failedPatients;
    }

    public void incrementProcessedPatients() {
        this.processedPatients++;
    }

    public void incrementCreatedQuests(int count) {
        this.createdQuests += count;
    }

    public void incrementSkippedPatients() {
        this.skippedPatients++;
    }

    public void incrementFailedPatients() {
        this.failedPatients++;
    }
}
