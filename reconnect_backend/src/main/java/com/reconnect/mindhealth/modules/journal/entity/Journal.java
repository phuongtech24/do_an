package com.reconnect.mindhealth.modules.journal.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * Entity class for CBT Journal logs.
 * Maps to 'journals' table in MySQL database.
 */
@Entity
@Table(name = "journals")
public class Journal extends BaseObject {

    @Enumerated(EnumType.STRING)
    @Column(name = "journal_type", nullable = false)
    private JournalType journalType;

    @Column(name = "content_encrypted", columnDefinition = "TEXT")
    private String contentEncrypted;

    @Column(name = "ai_risk_score")
    private Integer aiRiskScore = 0;

    @Column(name = "severity_level")
    private String severityLevel = "NORMAL";

    @Column(name = "ai_risk_distortions_json", columnDefinition = "TEXT")
    private String aiRiskDistortionsJson;

    @Column(name = "ai_risk_reason", columnDefinition = "TEXT")
    private String aiRiskReason;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    public Journal() {
    }

    public Journal(JournalType journalType, String contentEncrypted, Integer aiRiskScore, String severityLevel, PatientProfile patientProfile) {
        this.journalType = journalType;
        this.contentEncrypted = contentEncrypted;
        this.aiRiskScore = aiRiskScore;
        this.severityLevel = severityLevel;
        this.patientProfile = patientProfile;
    }

    public JournalType getJournalType() {
        return journalType;
    }

    public void setJournalType(JournalType journalType) {
        this.journalType = journalType;
    }

    public String getContentEncrypted() {
        return contentEncrypted;
    }

    public void setContentEncrypted(String contentEncrypted) {
        this.contentEncrypted = contentEncrypted;
    }

    public Integer getAiRiskScore() {
        return aiRiskScore;
    }

    public void setAiRiskScore(Integer aiRiskScore) {
        this.aiRiskScore = aiRiskScore;
    }

    public String getSeverityLevel() {
        return severityLevel;
    }

    public void setSeverityLevel(String severityLevel) {
        this.severityLevel = severityLevel;
    }

    public String getAiRiskDistortionsJson() {
        return aiRiskDistortionsJson;
    }

    public void setAiRiskDistortionsJson(String aiRiskDistortionsJson) {
        this.aiRiskDistortionsJson = aiRiskDistortionsJson;
    }

    public String getAiRiskReason() {
        return aiRiskReason;
    }

    public void setAiRiskReason(String aiRiskReason) {
        this.aiRiskReason = aiRiskReason;
    }

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
    }
}
