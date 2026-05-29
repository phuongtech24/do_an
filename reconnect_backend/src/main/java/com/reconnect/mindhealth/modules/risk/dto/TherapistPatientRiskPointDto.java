package com.reconnect.mindhealth.modules.risk.dto;

import java.time.LocalDate;

import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;

public class TherapistPatientRiskPointDto {

    private LocalDate riskDate;
    private Integer riskScore;
    private Integer scorePhq9;
    private Integer scoreAi;
    private Integer scoreMood;
    private Boolean overrideTriggered;
    private Boolean redFlagActive;

    public TherapistPatientRiskPointDto() {
    }

    public TherapistPatientRiskPointDto(DailyRiskLog entity) {
        this.riskDate = entity.getRiskDate();
        this.riskScore = entity.getRiskScore();
        this.scorePhq9 = entity.getScorePhq9();
        this.scoreAi = entity.getScoreAi();
        this.scoreMood = entity.getScoreMood();
        this.overrideTriggered = entity.getOverrideTriggered();
        this.redFlagActive = entity.getRedFlagActive();
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

    public Integer getScorePhq9() {
        return scorePhq9;
    }

    public void setScorePhq9(Integer scorePhq9) {
        this.scorePhq9 = scorePhq9;
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
