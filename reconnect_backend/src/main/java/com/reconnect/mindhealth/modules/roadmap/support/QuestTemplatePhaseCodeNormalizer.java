package com.reconnect.mindhealth.modules.roadmap.support;

public final class QuestTemplatePhaseCodeNormalizer {

    private QuestTemplatePhaseCodeNormalizer() {
    }

    public static String normalize(String rawValue) {
        if (rawValue == null || rawValue.trim().isEmpty()) {
            return null;
        }
        String normalized = rawValue.trim().toUpperCase();
        return switch (normalized) {
            case "PHASE_1_FOUNDATION", "MAP_AND_BELIEF_BREAK" -> "MAP_AND_BELIEF_BREAK";
            case "PHASE_2_REAL_WORLD", "REAL_WORLD_EXPERIMENTS" -> "REAL_WORLD_EXPERIMENTS";
            case "PHASE_3_DEEP_COGNITIVE", "DEEP_COGNITIVE_MEMORY" -> "DEEP_COGNITIVE_MEMORY";
            default -> normalized;
        };
    }
}
