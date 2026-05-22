package com.reconnect.mindhealth.modules.roadmap.dto;

import com.reconnect.mindhealth.modules.ai.dto.QuestProofVisionResultDto;

public class VerifyQuestProofResponseDto {
    private boolean accepted;
    private String proofImageUrl;
    private QuestProofVisionResultDto vision;

    public VerifyQuestProofResponseDto() {
    }

    public VerifyQuestProofResponseDto(boolean accepted, String proofImageUrl, QuestProofVisionResultDto vision) {
        this.accepted = accepted;
        this.proofImageUrl = proofImageUrl;
        this.vision = vision;
    }

    public boolean isAccepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }

    public String getProofImageUrl() {
        return proofImageUrl;
    }

    public void setProofImageUrl(String proofImageUrl) {
        this.proofImageUrl = proofImageUrl;
    }

    public QuestProofVisionResultDto getVision() {
        return vision;
    }

    public void setVision(QuestProofVisionResultDto vision) {
        this.vision = vision;
    }
}

