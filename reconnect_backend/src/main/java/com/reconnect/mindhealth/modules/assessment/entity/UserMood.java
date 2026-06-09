package com.reconnect.mindhealth.modules.assessment.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
@Entity
@Table(name = "user_moods")
public class UserMood extends BaseObject {

    @Column(name = "mood_score")
    @Min(0)
    @Max(100)
    private Integer moodScore;

    @Column(name = "anxiety_score")
    @Min(0)
    @Max(100)
    private Integer anxietyScore;

    @Column(name = "avoidance_urge_score")
    @Min(0)
    @Max(100)
    private Integer avoidanceUrgeScore;

    @Column(name = "sadness_score")
    @Min(0)
    @Max(100)
    private Integer sadnessScore;

    @Column(name = "anticipatory_anxiety_score")
    @Min(0)
    @Max(8)
    private Integer anticipatoryAnxietyScore;

    @Column(name = "post_event_rumination_score")
    @Min(0)
    @Max(8)
    private Integer postEventRuminationScore;

    @Column(name = "daily_agenda")
    private String dailyAgenda;

    @Column(name = "safety_check_required")
    private Boolean safetyCheckRequired;

    @Column(name = "safety_response")
    private String safetyResponse;

    @Column(name = "safety_responded_at")
    private java.time.LocalDateTime safetyRespondedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id")
    private PatientProfile patientProfile;

    public UserMood() {
    }

    public UserMood(Integer moodScore, String dailyAgenda, PatientProfile patientProfile) {
        this.moodScore = moodScore;
        this.dailyAgenda = dailyAgenda;
        this.patientProfile = patientProfile;
    }

    public Integer getMoodScore() {
        return moodScore;
    }

    public void setMoodScore(Integer moodScore) {
        this.moodScore = moodScore;
    }

    public Integer getAnxietyScore() {
        return anxietyScore;
    }

    public void setAnxietyScore(Integer anxietyScore) {
        this.anxietyScore = anxietyScore;
    }

    public Integer getAvoidanceUrgeScore() {
        return avoidanceUrgeScore;
    }

    public void setAvoidanceUrgeScore(Integer avoidanceUrgeScore) {
        this.avoidanceUrgeScore = avoidanceUrgeScore;
    }

    public Integer getSadnessScore() {
        return sadnessScore;
    }

    public void setSadnessScore(Integer sadnessScore) {
        this.sadnessScore = sadnessScore;
    }

    public Integer getAnticipatoryAnxietyScore() {
        return anticipatoryAnxietyScore;
    }

    public void setAnticipatoryAnxietyScore(Integer anticipatoryAnxietyScore) {
        this.anticipatoryAnxietyScore = anticipatoryAnxietyScore;
    }

    public Integer getPostEventRuminationScore() {
        return postEventRuminationScore;
    }

    public void setPostEventRuminationScore(Integer postEventRuminationScore) {
        this.postEventRuminationScore = postEventRuminationScore;
    }

    public String getDailyAgenda() {
        return dailyAgenda;
    }

    public void setDailyAgenda(String dailyAgenda) {
        this.dailyAgenda = dailyAgenda;
    }

    public Boolean getSafetyCheckRequired() {
        return safetyCheckRequired;
    }

    public void setSafetyCheckRequired(Boolean safetyCheckRequired) {
        this.safetyCheckRequired = safetyCheckRequired;
    }

    public String getSafetyResponse() {
        return safetyResponse;
    }

    public void setSafetyResponse(String safetyResponse) {
        this.safetyResponse = safetyResponse;
    }

    public java.time.LocalDateTime getSafetyRespondedAt() {
        return safetyRespondedAt;
    }

    public void setSafetyRespondedAt(java.time.LocalDateTime safetyRespondedAt) {
        this.safetyRespondedAt = safetyRespondedAt;
    }

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
    }
}
