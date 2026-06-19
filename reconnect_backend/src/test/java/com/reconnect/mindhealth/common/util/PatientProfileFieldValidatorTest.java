package com.reconnect.mindhealth.common.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class PatientProfileFieldValidatorTest {

    @Test
    void normalizePhone_returnsTrimmedDigits_whenValid() {
        String result = PatientProfileFieldValidator.normalizePhone(" 0987654321 ", "Số điện thoại", true);

        assertEquals("0987654321", result);
    }

    @Test
    void normalizePhone_throws_whenContainsNonDigits() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> PatientProfileFieldValidator.normalizePhone("09A876", "Số điện thoại", true));

        assertEquals("Số điện thoại chỉ được chứa chữ số.", exception.getMessage());
    }

    @Test
    void normalizeEducationLevel_returnsNull_whenBlank() {
        assertNull(PatientProfileFieldValidator.normalizeEducationLevel("   "));
    }

    @Test
    void normalizeRelationshipStatus_throws_whenInvalid() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> PatientProfileFieldValidator.normalizeRelationshipStatus("Complicated"));

        assertEquals("Tình trạng hôn nhân / mối quan hệ không hợp lệ.", exception.getMessage());
    }
}
