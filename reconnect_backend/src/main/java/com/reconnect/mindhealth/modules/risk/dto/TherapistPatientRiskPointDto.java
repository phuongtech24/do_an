package com.reconnect.mindhealth.modules.risk.dto;

import java.time.LocalDate;

public class TherapistPatientRiskPointDto {

    private LocalDate riskDate;
    private Integer riskScore;
    private Integer scoreSafety;
    private Integer scoreAi;
    private Integer scoreMood;
    private Boolean overrideTriggered;
    private Boolean redFlagActive;

    public TherapistPatientRiskPointDto() {
    }

    public TherapistPatientRiskPointDto(
            LocalDate riskDate,
            Integer riskScore,
            Integer scoreSafety,
            Integer scoreAi,
            Integer scoreMood,
            Boolean overrideTriggered,
            Boolean redFlagActive) {
        this.riskDate = riskDate;
        this.riskScore = riskScore;
        this.scoreSafety = scoreSafety;
        this.scoreAi = scoreAi;
        this.scoreMood = scoreMood;
        this.overrideTriggered = overrideTriggered;
        this.redFlagActive = redFlagActive;
    }

    public LocalDate getRiskDate() {
        return riskDate;
    }

    public void setRiskDate(LocalDate riskDate) {
        this.riskDate = riskDate;
    }

    public Integer getRiskScore() {
        return riskScore;
    }

    public void setRiskScore(Integer riskScore) {
        this.riskScore = riskScore;
    }

    public Integer getScoreSafety() {
        return scoreSafety;
    }

    public void setScoreSafety(Integer scoreSafety) {
        this.scoreSafety = scoreSafety;
    }

    public Integer getScoreAi() {
        return scoreAi;
    }

    public void setScoreAi(Integer scoreAi) {
        this.scoreAi = scoreAi;
    }

    public Integer getScoreMood() {
        return scoreMood;
    }

    public void setScoreMood(Integer scoreMood) {
        this.scoreMood = scoreMood;
    }

    public Boolean getOverrideTriggered() {
        return overrideTriggered;
    }

    public void setOverrideTriggered(Boolean overrideTriggered) {
        this.overrideTriggered = overrideTriggered;
    }

    public Boolean getRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(Boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }
}
