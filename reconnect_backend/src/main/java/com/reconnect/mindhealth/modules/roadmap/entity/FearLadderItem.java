package com.reconnect.mindhealth.modules.roadmap.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSituation;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderBucket;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
        name = "fear_ladder_items",
        uniqueConstraints = @UniqueConstraint(name = "uq_ladder_patient_situation", columnNames = {"patient_id", "situation_id"})
)
public class FearLadderItem extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "situation_id", nullable = false)
    private LsasSituation situation;

    @Column(name = "baseline_fear_score", nullable = false)
    private Integer baselineFearScore = 0;

    @Column(name = "baseline_avoidance_score", nullable = false)
    private Integer baselineAvoidanceScore = 0;

    @Column(name = "baseline_total_score", nullable = false)
    private Integer baselineTotalScore = 0;

    @Column(name = "current_fear_score", nullable = false)
    private Integer currentFearScore = 0;

    @Column(name = "current_avoidance_score", nullable = false)
    private Integer currentAvoidanceScore = 0;

    @Column(name = "current_total_score", nullable = false)
    private Integer currentTotalScore = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "bucket", nullable = false)
    private FearLadderBucket bucket = FearLadderBucket.EASY;

    @Column(name = "ladder_order", nullable = false)
    private Integer ladderOrder = 1;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private FearLadderStatus status = FearLadderStatus.ACTIVE;

    public PatientProfile getPatientProfile() { return patientProfile; }
    public void setPatientProfile(PatientProfile patientProfile) { this.patientProfile = patientProfile; }
    public LsasSituation getSituation() { return situation; }
    public void setSituation(LsasSituation situation) { this.situation = situation; }
    public Integer getBaselineFearScore() { return baselineFearScore; }
    public void setBaselineFearScore(Integer baselineFearScore) { this.baselineFearScore = baselineFearScore; }
    public Integer getBaselineAvoidanceScore() { return baselineAvoidanceScore; }
    public void setBaselineAvoidanceScore(Integer baselineAvoidanceScore) { this.baselineAvoidanceScore = baselineAvoidanceScore; }
    public Integer getBaselineTotalScore() { return baselineTotalScore; }
    public void setBaselineTotalScore(Integer baselineTotalScore) { this.baselineTotalScore = baselineTotalScore; }
    public Integer getCurrentFearScore() { return currentFearScore; }
    public void setCurrentFearScore(Integer currentFearScore) { this.currentFearScore = currentFearScore; }
    public Integer getCurrentAvoidanceScore() { return currentAvoidanceScore; }
    public void setCurrentAvoidanceScore(Integer currentAvoidanceScore) { this.currentAvoidanceScore = currentAvoidanceScore; }
    public Integer getCurrentTotalScore() { return currentTotalScore; }
    public void setCurrentTotalScore(Integer currentTotalScore) { this.currentTotalScore = currentTotalScore; }
    public FearLadderBucket getBucket() { return bucket; }
    public void setBucket(FearLadderBucket bucket) { this.bucket = bucket; }
    public Integer getLadderOrder() { return ladderOrder; }
    public void setLadderOrder(Integer ladderOrder) { this.ladderOrder = ladderOrder; }
    public FearLadderStatus getStatus() { return status; }
    public void setStatus(FearLadderStatus status) { this.status = status; }
}
