package com.reconnect.mindhealth.modules.clinical.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

@ExtendWith(MockitoExtension.class)
class PatientProfileSelfServiceTest {

    @Mock
    private PatientProfileRepository patientProfileRepository;

    @InjectMocks
    private PatientProfileSelfService patientProfileSelfService;

    @Test
    void updateProfile_normalizesValidFields_andMarksMedicalProfileComplete() {
        UUID patientId = UUID.randomUUID();
        PatientProfile profile = new PatientProfile();
        profile.setId(patientId);
        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(profile));
        when(patientProfileRepository.save(any(PatientProfile.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PatientProfileUpdateRequestDto request = new PatientProfileUpdateRequestDto();
        request.setPatientId(patientId);
        request.setRealFullName("Nguyen Van A");
        request.setDateOfBirth(LocalDate.now().minusYears(20));
        request.setGender("Nam");
        request.setPhoneNumber("0987654321");
        request.setEmergencyContactPhone("0911222333");
        request.setEducationLevel("Đại học");
        request.setOccupation("Lập trình viên");
        request.setRelationshipStatus("Độc thân");
        request.setMedicalHistory("Không");

        PatientProfileDto result = patientProfileSelfService.updateProfile(request);

        assertEquals("0987654321", result.getPhoneNumber());
        assertEquals("Đại học", result.getEducationLevel());
        assertEquals("Độc thân", result.getRelationshipStatus());
        assertEquals(Boolean.TRUE, result.getMedicalProfileCompleted());
    }

    @Test
    void updateProfile_throws_whenPhoneContainsLetters() {
        UUID patientId = UUID.randomUUID();
        PatientProfile profile = new PatientProfile();
        profile.setId(patientId);
        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(profile));

        PatientProfileUpdateRequestDto request = new PatientProfileUpdateRequestDto();
        request.setPatientId(patientId);
        request.setPhoneNumber("09AB567");

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> patientProfileSelfService.updateProfile(request));

        assertEquals("Số điện thoại cá nhân chỉ được chứa chữ số.", exception.getMessage());
    }
}
