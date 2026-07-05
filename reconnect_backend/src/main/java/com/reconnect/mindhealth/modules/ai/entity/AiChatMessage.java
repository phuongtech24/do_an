package com.reconnect.mindhealth.modules.ai.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(
        name = "ai_chat_messages",
        indexes = {
                @Index(name = "idx_ai_chat_messages_session_created_at", columnList = "session_id, created_at"),
                @Index(name = "idx_ai_chat_messages_sender_created_at", columnList = "sender_type, created_at")
        })
public class AiChatMessage extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private AiChatSession session;

    @Column(name = "sender_type", nullable = false, length = 16)
    private String senderType;

    @Column(name = "message_text", nullable = false, columnDefinition = "TEXT")
    private String messageText;

    @Column(name = "used_fallback", nullable = false)
    private Boolean usedFallback = false;

    @Column(name = "related_topic_code", length = 64)
    private String relatedTopicCode;

    @Column(name = "safety_escalation", nullable = false)
    private Boolean safetyEscalation = false;

    @Column(name = "intent_detected", length = 64)
    private String intentDetected;

    public AiChatSession getSession() {
        return session;
    }

    public void setSession(AiChatSession session) {
        this.session = session;
    }

    public String getSenderType() {
        return senderType;
    }

    public void setSenderType(String senderType) {
        this.senderType = senderType;
    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public Boolean getUsedFallback() {
        return usedFallback;
    }

    public void setUsedFallback(Boolean usedFallback) {
        this.usedFallback = usedFallback;
    }

    public String getRelatedTopicCode() {
        return relatedTopicCode;
    }

    public void setRelatedTopicCode(String relatedTopicCode) {
        this.relatedTopicCode = relatedTopicCode;
    }

    public Boolean getSafetyEscalation() {
        return safetyEscalation;
    }

    public void setSafetyEscalation(Boolean safetyEscalation) {
        this.safetyEscalation = safetyEscalation;
    }

    public String getIntentDetected() {
        return intentDetected;
    }

    public void setIntentDetected(String intentDetected) {
        this.intentDetected = intentDetected;
    }
}
