package com.reconnect.mindhealth.modules.ai.dto;

import java.util.ArrayList;
import java.util.List;

public class CognitiveDistortionResponseDto {
    private List<String> distortions = new ArrayList<>();
    private String hint;

    public CognitiveDistortionResponseDto() {
    }

    public CognitiveDistortionResponseDto(List<String> distortions, String hint) {
        this.distortions = distortions;
        this.hint = hint;
    }

    public List<String> getDistortions() {
        return distortions;
    }

    public void setDistortions(List<String> distortions) {
        this.distortions = distortions;
    }

    public String getHint() {
        return hint;
    }

    public void setHint(String hint) {
        this.hint = hint;
    }
}

