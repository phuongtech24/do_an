package com.reconnect.mindhealth.modules.journal.dto;

import java.util.UUID;
import java.util.List;
import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;

/**
 * Data Transfer Object for Journal logs.
 * Offers flattened fields for easy parsing on Flutter frontend.
 */
public class JournalDto extends BaseObjectDto {

    private UUID patientId;
    private JournalType journalType;
    private Integer aiRiskScore;
    private String severityLevel;

    // Thought Record fields
    private String situation;
    private String automaticThought;
    private String emotion;
    private Integer emotionScore;
    private String adaptiveResponse;
    private Integer reRatedScore;
    private List<String> distortions;

    // Credit List field
    private String content;

    public JournalDto() {
    }

    public JournalDto(Journal entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());
            this.setCreatedBy(entity.getCreatedBy());
            this.setModifyDate(entity.getModifyDate());
            this.setModifiedBy(entity.getModifiedBy());

            this.journalType = entity.getJournalType();
            this.aiRiskScore = entity.getAiRiskScore();
            this.severityLevel = entity.getSeverityLevel();
            if (entity.getPatientProfile() != null) {
                this.patientId = entity.getPatientProfile().getId();
            }
        }
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public JournalType getJournalType() {
        return journalType;
    }

    public void setJournalType(JournalType journalType) {
        this.journalType = journalType;
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

    public String getSituation() {
        return situation;
    }

    public void setSituation(String situation) {
        this.situation = situation;
    }

    public String getAutomaticThought() {
        return automaticThought;
    }

    public void setAutomaticThought(String automaticThought) {
        this.automaticThought = automaticThought;
    }

    public String getEmotion() {
        return emotion;
    }

    public void setEmotion(String emotion) {
        this.emotion = emotion;
    }

    public Integer getEmotionScore() {
        return emotionScore;
    }

    public void setEmotionScore(Integer emotionScore) {
        this.emotionScore = emotionScore;
    }

    public String getAdaptiveResponse() {
        return adaptiveResponse;
    }

    public void setAdaptiveResponse(String adaptiveResponse) {
        this.adaptiveResponse = adaptiveResponse;
    }

    public Integer getReRatedScore() {
        return reRatedScore;
    }

    public void setReRatedScore(Integer reRatedScore) {
        this.reRatedScore = reRatedScore;
    }

    public List<String> getDistortions() {
        return distortions;
    }

    public void setDistortions(List<String> distortions) {
        this.distortions = distortions;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
