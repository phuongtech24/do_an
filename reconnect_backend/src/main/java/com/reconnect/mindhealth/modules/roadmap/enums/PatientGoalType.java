package com.reconnect.mindhealth.modules.roadmap.enums;

import com.fasterxml.jackson.annotation.JsonCreator;

public enum PatientGoalType {
    COGNITIVE,
    EMOTIONAL,
    BEHAVIORAL,
    SOCIAL;

    @JsonCreator
    public static PatientGoalType fromJson(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }

        return switch (raw.trim().toUpperCase()) {
            case "SOCIAL_INTERACTION", "GENERAL", "SOCIAL" -> SOCIAL;
            case "PERFORMANCE", "BEHAVIORAL" -> BEHAVIORAL;
            case "COGNITIVE" -> COGNITIVE;
            case "EMOTIONAL" -> EMOTIONAL;
            default -> throw new IllegalArgumentException("Invalid PatientGoalType: " + raw);
        };
    }
}
