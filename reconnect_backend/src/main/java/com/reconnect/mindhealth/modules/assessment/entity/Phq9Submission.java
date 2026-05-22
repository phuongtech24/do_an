package com.reconnect.mindhealth.modules.assessment.entity;

import java.time.LocalDateTime;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.assessment.enums.Phq9Type;
import com.reconnect.mindhealth.modules.assessment.enums.SeverityLevel;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "phq9_submissions")
public class Phq9Submission extends BaseObject {

    @Column(name = "total_score")
    private Integer totalScore;

    @Column(name = "q9_score")
    private Integer q9Score;

    @Column(name = "q2_score")
    private Integer q2Score;

    @Enumerated(EnumType.STRING)
    @Column(name = "submission_type")
    private Phq9Type submissionType;

    @Column(name = "unlocked_at")
    private LocalDateTime unlockedAt;

    @Column(name = "answers_json", columnDefinition = "json")
    private String answersJson;

    @Enumerated(EnumType.STRING)
    @Column(name = "severity_level")
    private SeverityLevel severityLevel;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id")
    private PatientProfile patientProfile;

    public Phq9Submission() {
    }

    public Phq9Submission(Integer totalScore, Integer q9Score, Integer q2Score, Phq9Type submissionType,
            LocalDateTime unlockedAt, String answersJson, SeverityLevel severityLevel, PatientProfile patientProfile) {
        this.totalScore = totalScore;
        this.q9Score = q9Score;
        this.q2Score = q2Score;
        this.submissionType = submissionType;
        this.unlockedAt = unlockedAt;
        this.answersJson = answersJson;
        this.severityLevel = severityLevel;
        this.patientProfile = patientProfile;
    }

    public Integer getTotalScore() {
        return totalScore;
    }

    public void setTotalScore(Integer totalScore) {
        this.totalScore = totalScore;
    }

    public Integer getQ9Score() {
        return q9Score;
    }

    public void setQ9Score(Integer q9Score) {
        this.q9Score = q9Score;
    }

    public Integer getQ2Score() {
        return q2Score;
    }

    public void setQ2Score(Integer q2Score) {
        this.q2Score = q2Score;
    }

    public Phq9Type getSubmissionType() {
        return submissionType;
    }

    public void setSubmissionType(Phq9Type submissionType) {
        this.submissionType = submissionType;
    }

    public LocalDateTime getUnlockedAt() {
        return unlockedAt;
    }

    public void setUnlockedAt(LocalDateTime unlockedAt) {
        this.unlockedAt = unlockedAt;
    }

    public String getAnswersJson() {
        return answersJson;
    }

    public void setAnswersJson(String answersJson) {
        this.answersJson = answersJson;
    }

    public SeverityLevel getSeverityLevel() {
        return severityLevel;
    }

    public void setSeverityLevel(SeverityLevel severityLevel) {
        this.severityLevel = severityLevel;
    }

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
    }

}
