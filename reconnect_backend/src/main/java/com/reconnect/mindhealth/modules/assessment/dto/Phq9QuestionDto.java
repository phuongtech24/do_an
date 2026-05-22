package com.reconnect.mindhealth.modules.assessment.dto;

import java.util.UUID;
import com.reconnect.mindhealth.modules.assessment.entity.Phq9Question;

public class Phq9QuestionDto {
    private UUID id;
    private Integer questionNumber;
    private String text;

    public Phq9QuestionDto() {
    }

    public Phq9QuestionDto(Phq9Question question) {
        this.id = question.getId();
        this.questionNumber = question.getQuestionNumber();
        this.text = question.getText();
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Integer getQuestionNumber() {
        return questionNumber;
    }

    public void setQuestionNumber(Integer questionNumber) {
        this.questionNumber = questionNumber;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }
}
