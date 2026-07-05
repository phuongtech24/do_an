package com.reconnect.mindhealth.modules.clinical.service;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

@ExtendWith(MockitoExtension.class)
class TherapistAssignmentServiceTest {

    @Mock
    private AuthContextService authContextService;
    @Mock
    private PatientProfileRepository patientProfileRepository;
    @Mock
    private TherapistProfileRepository therapistProfileRepository;
    @Mock
    private TherapistAccessGuardService therapistAccessGuardService;
    @Mock
    private TherapistDirectoryQueryService therapistDirectoryQueryService;
    @Mock
    private TherapistDirectoryCacheService therapistDirectoryCacheService;

    @InjectMocks
    private TherapistAssignmentService therapistAssignmentService;

    @Test
    void selectTherapist_rejectsInactiveTherapist() {
        UUID patientId = UUID.randomUUID();
        UUID therapistId = UUID.randomUUID();

        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);

        User therapistUser = new User();
        therapistUser.setIsActive(false);

        TherapistProfile therapist = new TherapistProfile();
        therapist.setId(therapistId);
        therapist.setApprovalStatus(ApprovalStatus.ACTIVE);
        therapist.setUser(therapistUser);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(therapistProfileRepository.findByIdForUpdate(therapistId)).thenReturn(therapist);

        assertThrows(IllegalStateException.class,
                () -> therapistAssignmentService.selectTherapist(patientId, therapistId));
    }

    @Test
    void selectTherapist_rejectsFullCaseload() {
        UUID patientId = UUID.randomUUID();
        UUID therapistId = UUID.randomUUID();

        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);

        User therapistUser = new User();
        therapistUser.setIsActive(true);

        TherapistProfile therapist = new TherapistProfile();
        therapist.setId(therapistId);
        therapist.setApprovalStatus(ApprovalStatus.ACTIVE);
        therapist.setUser(therapistUser);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(therapistProfileRepository.findByIdForUpdate(therapistId)).thenReturn(therapist);
        when(patientProfileRepository.countByTherapist_IdAndIsActiveTrueAndGraduatedAtIsNull(therapistId))
                .thenReturn((long) TherapistAssignmentService.CASELOAD_LIMIT);

        assertThrows(IllegalStateException.class,
                () -> therapistAssignmentService.selectTherapist(patientId, therapistId));
        verify(therapistProfileRepository).findByIdForUpdate(therapistId);
    }
}
