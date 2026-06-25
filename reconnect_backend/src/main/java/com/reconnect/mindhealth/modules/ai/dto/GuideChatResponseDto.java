package com.reconnect.mindhealth.modules.ai.dto;

import java.util.UUID;
import java.util.ArrayList;
import java.util.List;

public class GuideChatResponseDto {

    private String answer;

    private List<GuideChatSuggestedActionDto> suggestedActions = new ArrayList<>();

    private String relatedTopicCode;

    private boolean usedFallback;

    private boolean safetyEscalation;

    private boolean handoffRecommended;

    private UUID sessionId;

    private UUID messageId;

    public GuideChatResponseDto() {
    }

    public GuideChatResponseDto(
            String answer,
            List<GuideChatSuggestedActionDto> suggestedActions,
            String relatedTopicCode,
            boolean usedFallback,
            boolean safetyEscalation,
            boolean handoffRecommended) {
        this.answer = answer;
        this.suggestedActions = suggestedActions != null ? suggestedActions : new ArrayList<>();
        this.relatedTopicCode = relatedTopicCode;
        this.usedFallback = usedFallback;
        this.safetyEscalation = safetyEscalation;
        this.handoffRecommended = handoffRecommended;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

    public List<GuideChatSuggestedActionDto> getSuggestedActions() {
        return suggestedActions;
    }

    public void setSuggestedActions(List<GuideChatSuggestedActionDto> suggestedActions) {
        this.suggestedActions = suggestedActions;
    }

    public String getRelatedTopicCode() {
        return relatedTopicCode;
    }

    public void setRelatedTopicCode(String relatedTopicCode) {
        this.relatedTopicCode = relatedTopicCode;
    }

    public boolean isUsedFallback() {
        return usedFallback;
    }

    public void setUsedFallback(boolean usedFallback) {
        this.usedFallback = usedFallback;
    }

    public boolean isSafetyEscalation() {
        return safetyEscalation;
    }

    public void setSafetyEscalation(boolean safetyEscalation) {
        this.safetyEscalation = safetyEscalation;
    }

    public boolean isHandoffRecommended() {
        return handoffRecommended;
    }

    public void setHandoffRecommended(boolean handoffRecommended) {
        this.handoffRecommended = handoffRecommended;
    }

    public UUID getSessionId() {
        return sessionId;
    }

    public void setSessionId(UUID sessionId) {
        this.sessionId = sessionId;
    }

    public UUID getMessageId() {
        return messageId;
    }

    public void setMessageId(UUID messageId) {
        this.messageId = messageId;
    }
}
