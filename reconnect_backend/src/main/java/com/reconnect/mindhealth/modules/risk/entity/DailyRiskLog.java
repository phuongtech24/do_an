package com.reconnect.mindhealth.modules.risk.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
        name = "daily_risk_logs",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_daily_risk_patient_date",
                columnNames = {"patient_id", "risk_date"}
        )
)
public class DailyRiskLog extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @Column(name = "risk_date", nullable = false)
    private LocalDate riskDate;

    @Column(name = "risk_score", nullable = false)
    private Integer riskScore;

    @Column(name = "score_safety", nullable = false)
    private Integer scoreSafety;

    @Column(name = "score_ai", nullable = false)
    private Integer scoreAi;

    @Column(name = "score_mood", nullable = false)
    private Integer scoreMood;

    @Column(name = "override_triggered", nullable = false)
    private Boolean overrideTriggered = false;

    @Column(name = "red_flag_active", nullable = false)
    private Boolean redFlagActive = false;

    @Column(name = "calculated_at", nullable = false)
    private LocalDateTime calculatedAt = LocalDateTime.now();

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
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

    public LocalDateTime getCalculatedAt() {
        return calculatedAt;
    }

    public void setCalculatedAt(LocalDateTime calculatedAt) {
        this.calculatedAt = calculatedAt;
    }
}
