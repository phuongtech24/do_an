package com.reconnect.mindhealth.modules.ai.dto;

import jakarta.validation.constraints.NotBlank;

public class CognitiveDistortionRequestDto {

    @NotBlank
    private String situation;

    @NotBlank
    private String automaticThought;

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
}

