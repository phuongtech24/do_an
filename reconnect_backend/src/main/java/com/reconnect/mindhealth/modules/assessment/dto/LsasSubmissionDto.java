package com.reconnect.mindhealth.modules.assessment.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;

public class LsasSubmissionDto {
    private UUID id;
    private UUID patientId;
    private LsasSubmissionType submissionType;
    private Integer fearTotal;
    private Integer avoidanceTotal;
    private Integer totalScore;
    private LocalDateTime unlockedAt;
    private List<LsasAnswerRequestDto> answers = new ArrayList<>();

    public LsasSubmissionDto() {
    }

    public LsasSubmissionDto(LsasSubmission entity) {
        this.id = entity.getId();
        this.patientId = entity.getPatientProfile() != null ? entity.getPatientProfile().getId() : null;
        this.submissionType = entity.getSubmissionType();
        this.fearTotal = entity.getFearTotal();
        this.avoidanceTotal = entity.getAvoidanceTotal();
        this.totalScore = entity.getTotalScore();
        this.unlockedAt = entity.getUnlockedAt();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public LsasSubmissionType getSubmissionType() { return submissionType; }
    public void setSubmissionType(LsasSubmissionType submissionType) { this.submissionType = submissionType; }
    public Integer getFearTotal() { return fearTotal; }
    public void setFearTotal(Integer fearTotal) { this.fearTotal = fearTotal; }
    public Integer getAvoidanceTotal() { return avoidanceTotal; }
    public void setAvoidanceTotal(Integer avoidanceTotal) { this.avoidanceTotal = avoidanceTotal; }
    public Integer getTotalScore() { return totalScore; }
    public void setTotalScore(Integer totalScore) { this.totalScore = totalScore; }
    public LocalDateTime getUnlockedAt() { return unlockedAt; }
    public void setUnlockedAt(LocalDateTime unlockedAt) { this.unlockedAt = unlockedAt; }
    public List<LsasAnswerRequestDto> getAnswers() { return answers; }
    public void setAnswers(List<LsasAnswerRequestDto> answers) { this.answers = answers; }
}
