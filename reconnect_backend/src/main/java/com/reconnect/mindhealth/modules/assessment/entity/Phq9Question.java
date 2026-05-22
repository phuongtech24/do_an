package com.reconnect.mindhealth.modules.assessment.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "phq9_questions")
public class Phq9Question extends BaseObject {

    @Column(name = "question_number", nullable = false)
    private Integer questionNumber; // Số thứ tự câu hỏi (1 đến 9)

    @Column(name = "text", nullable = false, length = 1000)
    private String text;

    public Phq9Question() {
    }

    public Phq9Question(Integer questionNumber, String text) {
        this.questionNumber = questionNumber;
        this.text = text;
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
