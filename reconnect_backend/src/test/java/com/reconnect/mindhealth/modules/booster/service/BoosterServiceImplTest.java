package com.reconnect.mindhealth.modules.booster.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Stream;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.entity.TherapistScheduleSlot;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.booster.repository.TherapistScheduleSlotRepository;
import com.reconnect.mindhealth.modules.booster.repository.TherapistWeeklyScheduleSlotRepository;
import com.reconnect.mindhealth.modules.booster.service.impl.BoosterServiceImpl;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

@ExtendWith(MockitoExtension.class)
class BoosterServiceImplTest {

    private static final String THERAPIST_SLOT_TAKEN_MESSAGE =
            "Khung giờ này vừa được đặt. Vui lòng chọn khung giờ khác.";
    private static final String PATIENT_SLOT_CONFLICT_MESSAGE =
            "Bạn đã có lịch khác trùng giờ này. Vui lòng chọn khung giờ khác.";

    @Mock
    private PatientProfileRepository patientProfileRepository;
    @Mock
    private AppointmentRepository appointmentRepository;
    @Mock
    private TherapistScheduleSlotRepository scheduleSlotRepository;
    @Mock
    private TherapistWeeklyScheduleSlotRepository weeklyScheduleSlotRepository;
    @Mock
    private TherapistProfileRepository therapistProfileRepository;
    @Mock
    private AuthContextService authContextService;

    @InjectMocks
    private BoosterServiceImpl boosterService;

    @Test
    void bookAppointment_rejectsWhenPatientAlreadyHasSameStartAt() {
        UUID patientId = UUID.randomUUID();
        LocalDateTime startAt = LocalDateTime.now().plusDays(1).withSecond(0).withNano(0);
        PatientProfile patient = buildPatient(patientId);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(appointmentRepository.existsByTherapistProfile_IdAndStartAt(patient.getTherapist().getId(), startAt))
                .thenReturn(false);
        when(appointmentRepository.existsByPatientProfile_IdAndStartAt(patientId, startAt)).thenReturn(true);

        IllegalStateException exception = assertThrows(
                IllegalStateException.class,
                () -> boosterService.bookAppointment(buildRequest(patientId, startAt)));

        assertEquals(PATIENT_SLOT_CONFLICT_MESSAGE, exception.getMessage());
    }

    @Test
    void bookAppointment_mapsTherapistConstraintViolationToBusinessMessage() {
        UUID patientId = UUID.randomUUID();
        LocalDateTime startAt = LocalDateTime.now().plusDays(1).withSecond(0).withNano(0);
        PatientProfile patient = buildPatient(patientId);

        stubHappyPath(patient, startAt);
        when(appointmentRepository.save(any(Appointment.class)))
                .thenThrow(new DataIntegrityViolationException("uq_appointments_therapist_start_at"));

        IllegalStateException exception = assertThrows(
                IllegalStateException.class,
                () -> boosterService.bookAppointment(buildRequest(patientId, startAt)));

        assertEquals(THERAPIST_SLOT_TAKEN_MESSAGE, exception.getMessage());
    }

    @Test
    void concurrentBookingRequests_onlyOneSucceedsWhenConstraintTrips() throws Exception {
        UUID patientId = UUID.randomUUID();
        LocalDateTime startAt = LocalDateTime.now().plusDays(1).withSecond(0).withNano(0);
        PatientProfile patient = buildPatient(patientId);

        stubHappyPath(patient, startAt);

        CountDownLatch enteredSave = new CountDownLatch(2);
        CountDownLatch releaseSave = new CountDownLatch(1);
        AtomicBoolean winnerChosen = new AtomicBoolean(false);

        when(appointmentRepository.save(any(Appointment.class))).thenAnswer(invocation -> {
            enteredSave.countDown();
            assertTrue(releaseSave.await(2, TimeUnit.SECONDS));
            Appointment appointment = invocation.getArgument(0);
            if (winnerChosen.compareAndSet(false, true)) {
                appointment.setId(UUID.randomUUID());
                return appointment;
            }
            throw new DataIntegrityViolationException("uq_appointments_therapist_start_at");
        });

        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            Callable<Object> task = () -> {
                try {
                    return boosterService.bookAppointment(buildRequest(patientId, startAt));
                } catch (Exception ex) {
                    return ex;
                }
            };

            Future<Object> first = executor.submit(task);
            Future<Object> second = executor.submit(task);

            assertTrue(enteredSave.await(2, TimeUnit.SECONDS));
            releaseSave.countDown();

            Object result1 = first.get(2, TimeUnit.SECONDS);
            Object result2 = second.get(2, TimeUnit.SECONDS);

            long successCount = Stream.of(result1, result2)
                    .filter(AppointmentDto.class::isInstance)
                    .count();
            List<IllegalStateException> failures = Stream.of(result1, result2)
                    .filter(IllegalStateException.class::isInstance)
                    .map(IllegalStateException.class::cast)
                    .toList();

            assertEquals(1, successCount);
            assertEquals(1, failures.size());
            assertEquals(THERAPIST_SLOT_TAKEN_MESSAGE, failures.get(0).getMessage());
            assertInstanceOf(AppointmentDto.class,
                    result1 instanceof AppointmentDto ? result1 : result2);
        } finally {
            executor.shutdownNow();
        }
    }

    private void stubHappyPath(PatientProfile patient, LocalDateTime startAt) {
        when(patientProfileRepository.findById(patient.getId())).thenReturn(Optional.of(patient));
        when(appointmentRepository.existsByTherapistProfile_IdAndStartAt(patient.getTherapist().getId(), startAt))
                .thenReturn(false);
        when(appointmentRepository.existsByPatientProfile_IdAndStartAt(patient.getId(), startAt))
                .thenReturn(false);
        when(scheduleSlotRepository.findByTherapistProfile_IdAndSlotDateAndStartTime(
                eq(patient.getTherapist().getId()),
                eq(startAt.toLocalDate()),
                eq(startAt.toLocalTime()))).thenReturn(Optional.empty());
    }

    private BookAppointmentRequestDto buildRequest(UUID patientId, LocalDateTime startAt) {
        BookAppointmentRequestDto request = new BookAppointmentRequestDto();
        request.setPatientId(patientId);
        request.setStartAt(startAt);
        request.setDurationMinutes(50);
        request.setPurpose(AppointmentPurpose.CBT_SESSION.name());
        return request;
    }

    private PatientProfile buildPatient(UUID patientId) {
        User patientUser = new User();
        patientUser.setId(patientId);
        patientUser.setEmail("patient@example.com");
        patientUser.setUsername("BN12");
        patientUser.setPasswordHash("hash");
        patientUser.setRole(Role.PATIENT);

        User therapistUser = new User();
        therapistUser.setId(UUID.randomUUID());
        therapistUser.setEmail("therapist@example.com");
        therapistUser.setUsername("BS1");
        therapistUser.setPasswordHash("hash");
        therapistUser.setRole(Role.THERAPIST);

        TherapistProfile therapist = new TherapistProfile();
        therapist.setId(therapistUser.getId());
        therapist.setUser(therapistUser);
        therapist.setFullName("Bác sĩ Minh");
        therapist.setMeetingLink("https://meet.example.com/room-1");

        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);
        patient.setUser(patientUser);
        patient.setTherapist(therapist);
        patient.setNickName("BN12");
        patient.setAnonymousModeEnabled(true);
        return patient;
    }
}
