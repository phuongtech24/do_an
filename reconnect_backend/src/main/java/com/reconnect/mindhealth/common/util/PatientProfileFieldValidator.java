package com.reconnect.mindhealth.common.util;

import java.util.LinkedHashSet;
import java.util.Set;

public final class PatientProfileFieldValidator {

    public static final Set<String> EDUCATION_LEVELS = Set.of(
            "Cấp 2",
            "Cấp 3",
            "Trung cấp",
            "Cao đẳng",
            "Đại học",
            "Sau đại học",
            "Khác");

    public static final Set<String> RELATIONSHIP_STATUSES = Set.of(
            "Độc thân",
            "Đang tìm hiểu",
            "Hẹn hò",
            "Đã kết hôn",
            "Ly hôn",
            "Góa",
            "Khác");

    private PatientProfileFieldValidator() {
    }

    public static String normalizePhone(String value, String fieldLabel, boolean required) {
        String normalized = trimToNull(value);
        if (normalized == null) {
            if (required) {
                throw new IllegalArgumentException(fieldLabel + " là bắt buộc.");
            }
            return null;
        }
        if (!normalized.matches("\\d+")) {
            throw new IllegalArgumentException(fieldLabel + " chỉ được chứa chữ số.");
        }
        return normalized;
    }

    public static String normalizeEducationLevel(String value) {
        return normalizeEnumValue(value, "Trình độ học vấn", EDUCATION_LEVELS);
    }

    public static String normalizeRelationshipStatus(String value) {
        return normalizeEnumValue(value, "Tình trạng hôn nhân / mối quan hệ", RELATIONSHIP_STATUSES);
    }

    public static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    public static Set<String> educationLevelsWithLegacy(String currentValue) {
        return mergeWithLegacyValue(EDUCATION_LEVELS, currentValue);
    }

    public static Set<String> relationshipStatusesWithLegacy(String currentValue) {
        return mergeWithLegacyValue(RELATIONSHIP_STATUSES, currentValue);
    }

    private static String normalizeEnumValue(String value, String fieldLabel, Set<String> allowedValues) {
        String normalized = trimToNull(value);
        if (normalized == null) {
            return null;
        }
        if (!allowedValues.contains(normalized)) {
            throw new IllegalArgumentException(fieldLabel + " không hợp lệ.");
        }
        return normalized;
    }

    private static Set<String> mergeWithLegacyValue(Set<String> allowedValues, String currentValue) {
        LinkedHashSet<String> merged = new LinkedHashSet<>(allowedValues);
        String legacy = trimToNull(currentValue);
        if (legacy != null && !allowedValues.contains(legacy)) {
            merged.add(legacy);
        }
        return merged;
    }
}
