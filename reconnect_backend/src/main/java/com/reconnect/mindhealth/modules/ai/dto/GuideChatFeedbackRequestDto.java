package com.reconnect.mindhealth.modules.ai.dto;

import java.util.UUID;

public class GuideChatFeedbackRequestDto {

    private UUID messageId;
    private Integer rating;
    private String feedbackText;

    public UUID getMessageId() {
        return messageId;
    }

    public void setMessageId(UUID messageId) {
        this.messageId = messageId;
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
