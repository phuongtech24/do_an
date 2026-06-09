package com.reconnect.mindhealth.modules.assessment.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "lsas_answers")
public class LsasAnswer extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "submission_id", nullable = false)
    private LsasSubmission submission;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "situation_id", nullable = false)
    private LsasSituation situation;

    @Column(name = "fear_score", nullable = false)
    private Integer fearScore = 0;

    @Column(name = "avoidance_score", nullable = false)
    private Integer avoidanceScore = 0;

    @Column(name = "total_score", nullable = false)
    private Integer totalScore = 0;

    public LsasSubmission getSubmission() {
        return submission;
    }

    public void setSubmission(LsasSubmission submission) {
        this.submission = submission;
    }

    public LsasSituation getSituation() {
        return situation;
    }

    public void setSituation(LsasSituation situation) {
        this.situation = situation;
    }

    public Integer getFearScore() {
        return fearScore;
    }

    public void setFearScore(Integer fearScore) {
        this.fearScore = fearScore;
    }

    public Integer getAvoidanceScore() {
        return avoidanceScore;
    }

    public void setAvoidanceScore(Integer avoidanceScore) {
        this.avoidanceScore = avoidanceScore;
    }

    public Integer getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(Integer totalScore) {
        this.totalScore = totalScore;
    }
}
