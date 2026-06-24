package com.reconnect.mindhealth.modules.clinical.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TherapistPreSessionReviewDto {
    private Integer baselineLsasScore;
    private Integer currentLsasScore;
    private Integer latestLsasScore;
    private String goalSummary;
    private Integer fearLadderTotalItems;
    private Integer fearLadderUnlockedItems;
    private Integer behavioralExperimentsLastWeek;
    private Integer thoughtRecordsLastWeek;
    private Integer dailyCheckinsLastWeek;
    private Integer programWeek;
    private String programPhaseLabel;
    private Integer currentRiskScore;
    private Boolean redFlagActive;
    private LocalDateTime upcomingAppointmentAt;
    private List<String> recentThoughtRecordSummaries = new ArrayList<>();
    private List<String> recentBehavioralExperimentSummaries = new ArrayList<>();
    private List<String> recentDailyCheckinSummaries = new ArrayList<>();

    public Integer getBaselineLsasScore() {
        return baselineLsasScore;
    }

    public void setBaselineLsasScore(Integer baselineLsasScore) {
        this.baselineLsasScore = baselineLsasScore;
    }

    public Integer getCurrentLsasScore() {
        return currentLsasScore;
    }

    public void setCurrentLsasScore(Integer currentLsasScore) {
        this.currentLsasScore = currentLsasScore;
    }

    public Integer getLatestLsasScore() {
        return latestLsasScore;
    }

    public void setLatestLsasScore(Integer latestLsasScore) {
        this.latestLsasScore = latestLsasScore;
    }

    public String getGoalSummary() {
        return goalSummary;
    }

    public void setGoalSummary(String goalSummary) {
        this.goalSummary = goalSummary;
    }

    public Integer getFearLadderTotalItems() {
        return fearLadderTotalItems;
    }

    public void setFearLadderTotalItems(Integer fearLadderTotalItems) {
        this.fearLadderTotalItems = fearLadderTotalItems;
    }

    public Integer getFearLadderUnlockedItems() {
        return fearLadderUnlockedItems;
    }

    public void setFearLadderUnlockedItems(Integer fearLadderUnlockedItems) {
        this.fearLadderUnlockedItems = fearLadderUnlockedItems;
    }

    public Integer getBehavioralExperimentsLastWeek() {
        return behavioralExperimentsLastWeek;
    }

    public void setBehavioralExperimentsLastWeek(Integer behavioralExperimentsLastWeek) {
        this.behavioralExperimentsLastWeek = behavioralExperimentsLastWeek;
    }

    public Integer getThoughtRecordsLastWeek() {
        return thoughtRecordsLastWeek;
    }

    public void setThoughtRecordsLastWeek(Integer thoughtRecordsLastWeek) {
        this.thoughtRecordsLastWeek = thoughtRecordsLastWeek;
    }

    public Integer getDailyCheckinsLastWeek() {
        return dailyCheckinsLastWeek;
    }

    public void setDailyCheckinsLastWeek(Integer dailyCheckinsLastWeek) {
        this.dailyCheckinsLastWeek = dailyCheckinsLastWeek;
    }

    public Integer getProgramWeek() {
        return programWeek;
    }

    public void setProgramWeek(Integer programWeek) {
        this.programWeek = programWeek;
    }

    public String getProgramPhaseLabel() {
        return programPhaseLabel;
    }

    public void setProgramPhaseLabel(String programPhaseLabel) {
        this.programPhaseLabel = programPhaseLabel;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }

    public Boolean getRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(Boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }

    public LocalDateTime getUpcomingAppointmentAt() {
        return upcomingAppointmentAt;
    }

    public void setUpcomingAppointmentAt(LocalDateTime upcomingAppointmentAt) {
        this.upcomingAppointmentAt = upcomingAppointmentAt;
    }

    public List<String> getRecentThoughtRecordSummaries() {
        return recentThoughtRecordSummaries;
    }

    public void setRecentThoughtRecordSummaries(List<String> recentThoughtRecordSummaries) {
        this.recentThoughtRecordSummaries = recentThoughtRecordSummaries;
    }

    public List<String> getRecentBehavioralExperimentSummaries() {
        return recentBehavioralExperimentSummaries;
    }

    public void setRecentBehavioralExperimentSummaries(List<String> recentBehavioralExperimentSummaries) {
        this.recentBehavioralExperimentSummaries = recentBehavioralExperimentSummaries;
    }

    public List<String> getRecentDailyCheckinSummaries() {
        return recentDailyCheckinSummaries;
    }

    public void setRecentDailyCheckinSummaries(List<String> recentDailyCheckinSummaries) {
        this.recentDailyCheckinSummaries = recentDailyCheckinSummaries;
    }
}
