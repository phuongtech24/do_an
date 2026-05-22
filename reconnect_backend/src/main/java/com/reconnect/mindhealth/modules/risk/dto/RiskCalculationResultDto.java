package com.reconnect.mindhealth.modules.risk.dto;

import java.util.UUID;

public class RiskCalculationResultDto {
    private UUID patientId;
    private int riskIndex;
    private int scorePhq9;
    private int scoreAi;
    private int scoreMood;
    private boolean overrideTriggered;

    public RiskCalculationResultDto() {
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public int getRiskIndex() {
        return riskIndex;
    }

    public void setRiskIndex(int riskIndex) {
        this.riskIndex = riskIndex;
    }

    public int getScorePhq9() {
        return scorePhq9;
    }

    public void setScorePhq9(int scorePhq9) {
        this.scorePhq9 = scorePhq9;
    }

    public int getScoreAi() {
        return scoreAi;
    }

    public void setScoreAi(int scoreAi) {
        this.scoreAi = scoreAi;
    }

    public int getScoreMood() {
        return scoreMood;
    }

    public void setScoreMood(int scoreMood) {
        this.scoreMood = scoreMood;
    }

    public boolean isOverrideTriggered() {
        return overrideTriggered;
    }

    public void setOverrideTriggered(boolean overrideTriggered) {
        this.overrideTriggered = overrideTriggered;
    }
}

