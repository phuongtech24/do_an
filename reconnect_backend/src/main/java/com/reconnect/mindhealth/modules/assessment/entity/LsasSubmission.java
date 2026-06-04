package com.reconnect.mindhealth.modules.assessment.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "lsas_submissions")
public class LsasSubmission extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @Enumerated(EnumType.STRING)
    @Column(name = "submission_type", nullable = false)
    private LsasSubmissionType submissionType = LsasSubmissionType.BASELINE;

    @Column(name = "fear_total", nullable = false)
    private Integer fearTotal = 0;

    @Column(name = "avoidance_total", nullable = false)
    private Integer avoidanceTotal = 0;

    @Column(name = "total_score", nullable = false)
    private Integer totalScore = 0;

    @Column(name = "unlocked_at")
    private LocalDateTime unlockedAt;

    @OneToMany(mappedBy = "submission", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<LsasAnswer> answers = new ArrayList<>();

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
    }

    public LsasSubmissionType getSubmissionType() {
        return submissionType;
    }

    public void setSubmissionType(LsasSubmissionType submissionType) {
        this.submissionType = submissionType;
    }

    public Integer getFearTotal() {
        return fearTotal;
    }

    public void setFearTotal(Integer fearTotal) {
        this.fearTotal = fearTotal;
    }

    public Integer getAvoidanceTotal() {
        return avoidanceTotal;
    }

    public void setAvoidanceTotal(Integer avoidanceTotal) {
        this.avoidanceTotal = avoidanceTotal;
    }

    public Integer getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(Integer totalScore) {
        this.totalScore = totalScore;
    }

    public LocalDateTime getUnlockedAt() {
        return unlockedAt;
    }

    public void setUnlockedAt(LocalDateTime unlockedAt) {
        this.unlockedAt = unlockedAt;
    }

    public List<LsasAnswer> getAnswers() {
        return answers;
    }

    public void setAnswers(List<LsasAnswer> answers) {
        this.answers = answers;
    }
}
