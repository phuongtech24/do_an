package com.reconnect.mindhealth.modules.ai.dto;

import java.util.ArrayList;
import java.util.List;

public class GuidedDiscoveryResponseDto {

    private List<String> questions = new ArrayList<>();

    public GuidedDiscoveryResponseDto() {
    }

    public GuidedDiscoveryResponseDto(List<String> questions) {
        this.questions = questions;
    }

    public List<String> getQuestions() {
        return questions;
    }

    public void setQuestions(List<String> questions) {
        this.questions = questions;
    }
}

