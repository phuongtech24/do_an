package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.List;

public class LsasProgressResponseDto {
    private List<LsasProgressDto> chartData;
    private int startScore;
    private int currentScore;
    private String insightMessage;

    public LsasProgressResponseDto() {
    }

    public LsasProgressResponseDto(List<LsasProgressDto> chartData, int startScore, int currentScore, String insightMessage) {
        this.chartData = chartData;
        this.startScore = startScore;
        this.currentScore = currentScore;
        this.insightMessage = insightMessage;
    }

    public List<LsasProgressDto> getChartData() {
        return chartData;
    }

    public void setChartData(List<LsasProgressDto> chartData) {
        this.chartData = chartData;
    }

    public int getStartScore() {
        return startScore;
    }

    public void setStartScore(int startScore) {
        this.startScore = startScore;
    }

    public int getCurrentScore() {
        return currentScore;
    }

    public void setCurrentScore(int currentScore) {
        this.currentScore = currentScore;
    }

    public String getInsightMessage() {
        return insightMessage;
    }

    public void setInsightMessage(String insightMessage) {
        this.insightMessage = insightMessage;
    }
}
