package com.reconnect.mindhealth.modules.clinical.dto;

public class LsasProgressDto {
    private String weekLabel;
    private Integer totalScore;

    public LsasProgressDto() {
    }

    public LsasProgressDto(String weekLabel, Integer totalScore) {
        this.weekLabel = weekLabel;
        this.totalScore = totalScore;
    }

    public String getWeekLabel() {
        return weekLabel;
    }

    public void setWeekLabel(String weekLabel) {
        this.weekLabel = weekLabel;
    }

    public Integer getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(Integer totalScore) {
        this.totalScore = totalScore;
    }
}
