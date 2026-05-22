package com.reconnect.mindhealth.modules.ai.dto;

import jakarta.validation.constraints.NotBlank;

public class GuidedDiscoveryRequestDto {

    @NotBlank
    private String situation;

    @NotBlank
    private String automaticThought;

    private String emotion;

    private Integer moodScore;

    public String getSituation() {
        return situation;
    }

    public void setSituation(String situation) {
        this.situation = situation;
    }

    public String getAutomaticThought() {
        return automaticThought;
    }

    public void setAutomaticThought(String automaticThought) {
        this.automaticThought = automaticThought;
    }

    public String getEmotion() {
        return emotion;
    }

    public void setEmotion(String emotion) {
        this.emotion = emotion;
    }

    public Integer getMoodScore() {
        return moodScore;
    }

    public void setMoodScore(Integer moodScore) {
        this.moodScore = moodScore;
    }
}

