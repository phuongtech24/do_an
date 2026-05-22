package com.reconnect.mindhealth.modules.roadmap.dto;

public class CompleteQuestRequest {
    private Integer masteryScore;
    private Integer pleasureScore;
    private String proofImageUrl;

    public CompleteQuestRequest() {
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
}

