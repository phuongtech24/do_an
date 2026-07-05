package com.reconnect.mindhealth.modules.ai.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(
        name = "ai_chat_feedback",
        indexes = {
                @Index(name = "idx_ai_chat_feedback_message_created_at", columnList = "message_id, created_at"),
                @Index(name = "idx_ai_chat_feedback_patient_created_at", columnList = "patient_id, created_at")
        })
public class AiChatFeedback extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "message_id", nullable = false)
    private AiChatMessage message;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @Column(name = "rating")
    private Integer rating;

    @Column(name = "feedback_text", columnDefinition = "TEXT")
    private String feedbackText;

    public AiChatMessage getMessage() {
        return message;
    }

    public void setMessage(AiChatMessage message) {
        this.message = message;
    }

    public PatientProfile getPatientProfile() {
        return patientProfile;
    }

    public void setPatientProfile(PatientProfile patientProfile) {
        this.patientProfile = patientProfile;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public String getFeedbackText() {
        return feedbackText;
    }

    public void setFeedbackText(String feedbackText) {
        this.feedbackText = feedbackText;
    }
}
