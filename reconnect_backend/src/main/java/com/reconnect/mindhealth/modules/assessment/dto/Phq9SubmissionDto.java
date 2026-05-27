package com.reconnect.mindhealth.modules.assessment.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.assessment.entity.Phq9Submission;
import com.reconnect.mindhealth.modules.assessment.enums.Phq9Type;
import com.reconnect.mindhealth.modules.assessment.enums.SeverityLevel;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;

public class Phq9SubmissionDto extends BaseObjectDto {
    private UUID patientId;
    private Integer totalScore;
    private Integer q9Score;
    private Integer q2Score;
    private Integer functionalDifficultyScore;
    private Phq9Type submissionType;
    private LocalDateTime unlockedAt;
    private List<Integer> answers;
    private SeverityLevel severityLevel;
    private Boolean graduatedNow;
    private TaperingStage taperingStage;

    public Phq9SubmissionDto() {
    }

    public Phq9SubmissionDto(Phq9Submission entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());
            this.setPatientId(entity.getPatientProfile().getId());
            this.setTotalScore(entity.getTotalScore());
            this.setQ9Score(entity.getQ9Score());
            this.setQ2Score(entity.getQ2Score());
            this.setFunctionalDifficultyScore(entity.getFunctionalDifficultyScore());
            this.setSubmissionType(entity.getSubmissionType());
            this.setUnlockedAt(entity.getUnlockedAt());
            if (entity.getAnswersJson() != null) {
                try {
                    ObjectMapper mapper = new ObjectMapper();
                    List<Integer> answersList = mapper.readValue(entity.getAnswersJson(),
                            new TypeReference<List<Integer>>() {
                            });
                    this.setAnswers(answersList);
                } catch (Exception e) {
                    // Nếu có lỗi parse (ví dụ dữ liệu DB bị sai định dạng), gán mảng trống để tránh
                    // crash app
                    this.setAnswers(java.util.Collections.emptyList());
                }
            }
            this.setSeverityLevel(entity.getSeverityLevel());
        }
    }

    public Boolean getGraduatedNow() {
        return graduatedNow;
    }

    public void setGraduatedNow(Boolean graduatedNow) {
        this.graduatedNow = graduatedNow;
    }

    public TaperingStage getTaperingStage() {
        return taperingStage;
    }

    public void setTaperingStage(TaperingStage taperingStage) {
        this.taperingStage = taperingStage;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
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

    public Integer getFunctionalDifficultyScore() {
        return functionalDifficultyScore;
    }

    public void setFunctionalDifficultyScore(Integer functionalDifficultyScore) {
        this.functionalDifficultyScore = functionalDifficultyScore;
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

    public List<Integer> getAnswers() {
        return answers;
    }

    public void setAnswers(List<Integer> answers) {
        this.answers = answers;
    }

    public SeverityLevel getSeverityLevel() {
        return severityLevel;
    }

    public void setSeverityLevel(SeverityLevel severityLevel) {
        this.severityLevel = severityLevel;
    }

}
