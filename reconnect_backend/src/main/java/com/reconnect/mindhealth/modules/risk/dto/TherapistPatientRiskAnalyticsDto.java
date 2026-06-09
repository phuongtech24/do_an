package com.reconnect.mindhealth.modules.risk.dto;

import java.util.List;
import java.util.UUID;

public class TherapistPatientRiskAnalyticsDto {

    private UUID patientId;
    private int days;
    private Integer latestRiskScore;
    private Double averageRiskScore;
    private Integer maxRiskScore;
    private long redFlagDays;
    private Boolean latestRedFlagActive;
    private String trend;
    private List<TherapistPatientRiskPointDto> points;

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public int getDays() {
        return days;
    }

    public void setDays(int days) {
        this.days = days;
    }

    public Integer getLatestRiskScore() {
        return latestRiskScore;
    }

    public void setLatestRiskScore(Integer latestRiskScore) {
        this.latestRiskScore = latestRiskScore;
    }

    public Double getAverageRiskScore() {
        return averageRiskScore;
    }

    public void setAverageRiskScore(Double averageRiskScore) {
        this.averageRiskScore = averageRiskScore;
    }

    public Integer getMaxRiskScore() {
        return maxRiskScore;
    }

    public void setMaxRiskScore(Integer maxRiskScore) {
        this.maxRiskScore = maxRiskScore;
    }

    public long getRedFlagDays() {
        return redFlagDays;
    }

    public void setRedFlagDays(long redFlagDays) {
        this.redFlagDays = redFlagDays;
    }

    public Boolean getLatestRedFlagActive() {
        return latestRedFlagActive;
    }

    public void setLatestRedFlagActive(Boolean latestRedFlagActive) {
        this.latestRedFlagActive = latestRedFlagActive;
    }

    public String getTrend() {
        return trend;
    }

    public void setTrend(String trend) {
        this.trend = trend;
    }

    public List<TherapistPatientRiskPointDto> getPoints() {
        return points;
    }

    public void setPoints(List<TherapistPatientRiskPointDto> points) {
        this.points = points;
    }
}
