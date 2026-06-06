package com.reconnect.mindhealth.modules.journal.dto;

import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;

public class JournalDto extends BaseObjectDto {

    private UUID patientId;
    private JournalType journalType;
    private Integer aiRiskScore;
    private String severityLevel;
    private List<String> aiRiskDistortions;
    private String aiRiskReason;

    private String situation;
    private String worstPrediction;
    private String automaticThought;
    private String emotion;
    private Integer emotionScore;
    private List<String> bodySymptoms;
    private String selfFocusThought;
    private String negativeSelfImage;
    private List<String> safetyBehaviors;
    private List<String> distortions;
    private String adaptiveResponse;
    private String safetyBehaviorCommitment;
    private Integer reRatedScore;
    private Integer reRatedBeliefScore;
    private String behavioralExperimentIdea;

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
            this.aiRiskReason = entity.getAiRiskReason();
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

    public List<String> getAiRiskDistortions() {
        return aiRiskDistortions;
    }

    public void setAiRiskDistortions(List<String> aiRiskDistortions) {
        this.aiRiskDistortions = aiRiskDistortions;
    }

    public String getAiRiskReason() {
        return aiRiskReason;
    }

    public void setAiRiskReason(String aiRiskReason) {
        this.aiRiskReason = aiRiskReason;
    }

    public String getSituation() {
        return situation;
    }

    public void setSituation(String situation) {
        this.situation = situation;
    }

    public String getWorstPrediction() {
        return worstPrediction;
    }

    public void setWorstPrediction(String worstPrediction) {
        this.worstPrediction = worstPrediction;
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

    public List<String> getBodySymptoms() {
        return bodySymptoms;
    }

    public void setBodySymptoms(List<String> bodySymptoms) {
        this.bodySymptoms = bodySymptoms;
    }

    public String getSelfFocusThought() {
        return selfFocusThought;
    }

    public void setSelfFocusThought(String selfFocusThought) {
        this.selfFocusThought = selfFocusThought;
    }

    public String getNegativeSelfImage() {
        return negativeSelfImage;
    }

    public void setNegativeSelfImage(String negativeSelfImage) {
        this.negativeSelfImage = negativeSelfImage;
    }

    public List<String> getSafetyBehaviors() {
        return safetyBehaviors;
    }

    public void setSafetyBehaviors(List<String> safetyBehaviors) {
        this.safetyBehaviors = safetyBehaviors;
    }

    public List<String> getDistortions() {
        return distortions;
    }

    public void setDistortions(List<String> distortions) {
        this.distortions = distortions;
    }

    public String getAdaptiveResponse() {
        return adaptiveResponse;
    }

    public void setAdaptiveResponse(String adaptiveResponse) {
        this.adaptiveResponse = adaptiveResponse;
    }

    public String getSafetyBehaviorCommitment() {
        return safetyBehaviorCommitment;
    }

    public void setSafetyBehaviorCommitment(String safetyBehaviorCommitment) {
        this.safetyBehaviorCommitment = safetyBehaviorCommitment;
    }

    public Integer getReRatedScore() {
        return reRatedScore;
    }

    public void setReRatedScore(Integer reRatedScore) {
        this.reRatedScore = reRatedScore;
    }

    public Integer getReRatedBeliefScore() {
        return reRatedBeliefScore;
    }

    public void setReRatedBeliefScore(Integer reRatedBeliefScore) {
        this.reRatedBeliefScore = reRatedBeliefScore;
    }

    public String getBehavioralExperimentIdea() {
        return behavioralExperimentIdea;
    }

    public void setBehavioralExperimentIdea(String behavioralExperimentIdea) {
        this.behavioralExperimentIdea = behavioralExperimentIdea;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
