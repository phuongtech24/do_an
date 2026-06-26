package com.reconnect.mindhealth.modules.clinical.service;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
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

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.dto.AccountDeletionRequestDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileDto;
import com.reconnect.mindhealth.modules.clinical.dto.PatientProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

@ExtendWith(MockitoExtension.class)
class PatientProfileSelfServiceTest {

    @Mock
    private PatientProfileRepository patientProfileRepository;

    @Mock
    private UserRepository userRepository;

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
        request.setEducationLevel("Dai hoc");
        request.setOccupation("Lap trinh vien");
        request.setRelationshipStatus("Doc than");
        request.setMedicalHistory("Khong");

        PatientProfileDto result = patientProfileSelfService.updateProfile(request);

        assertEquals("0987654321", result.getPhoneNumber());
        assertEquals("Dai hoc", result.getEducationLevel());
        assertEquals("Doc than", result.getRelationshipStatus());
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

        assertEquals("So dien thoai ca nhan chi duoc chua chu so.", exception.getMessage());
    }

    @Test
    void softDeleteAccount_anonymizesProfileAndDisablesUser() {
        UUID patientId = UUID.randomUUID();
        User user = new User();
        user.setId(patientId);
        user.setEmail("patient@example.com");
        user.setUsername("patient");

        PatientProfile profile = new PatientProfile();
        profile.setId(patientId);
        profile.setUser(user);
        profile.setNickName("patient");

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(profile));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(patientProfileRepository.save(any(PatientProfile.class))).thenAnswer(invocation -> invocation.getArgument(0));

        AccountDeletionRequestDto request = new AccountDeletionRequestDto();
        request.setPatientId(patientId);
        request.setConfirmDelete(true);

        assertDoesNotThrow(() -> patientProfileSelfService.softDeleteAccount(request));

        assertEquals(Boolean.FALSE, user.getIsActive());
        assertEquals(Boolean.TRUE, user.getVoided());
        assertEquals(Boolean.FALSE, profile.getIsActive());
        assertEquals(Boolean.TRUE, profile.getVoided());
    }
}

