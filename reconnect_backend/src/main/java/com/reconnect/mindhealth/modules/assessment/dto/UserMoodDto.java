package com.reconnect.mindhealth.modules.assessment.dto;

import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;

public class UserMoodDto extends BaseObjectDto {
    private UUID patientId;
    private Integer moodScore;
    private Integer anxietyScore;
    private Integer avoidanceUrgeScore;
    private Integer sadnessScore;
    private Integer anticipatoryAnxietyScore;
    private Integer postEventRuminationScore;
    private String dailyAgenda;
    private Boolean safetyCheckRequired;
    private String safetyResponse;
    private java.time.LocalDateTime safetyRespondedAt;

    public UserMoodDto() {
    }

    public UserMoodDto(UserMood entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());
            this.setMoodScore(entity.getMoodScore());
            this.setAnxietyScore(entity.getAnxietyScore());
            this.setAvoidanceUrgeScore(entity.getAvoidanceUrgeScore());
            this.setSadnessScore(entity.getSadnessScore());
            this.setAnticipatoryAnxietyScore(entity.getAnticipatoryAnxietyScore());
            this.setPostEventRuminationScore(entity.getPostEventRuminationScore());
            this.setDailyAgenda(entity.getDailyAgenda());
            this.setSafetyCheckRequired(entity.getSafetyCheckRequired());
            this.setSafetyResponse(entity.getSafetyResponse());
            this.setSafetyRespondedAt(entity.getSafetyRespondedAt());
            if (entity.getPatientProfile() != null) {
                this.setPatientId(entity.getPatientProfile().getId());
            }
        }
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
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
}
