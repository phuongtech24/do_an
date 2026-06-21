package com.reconnect.mindhealth.modules.booster.repository;

import static org.junit.jupiter.api.Assertions.assertThrows;

import java.time.LocalDateTime;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase.Replace;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.dao.DataIntegrityViolationException;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;

@DataJpaTest(properties = {
        "spring.flyway.enabled=false",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
})
@AutoConfigureTestDatabase(replace = Replace.ANY)
class AppointmentRepositoryConstraintTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Test
    void duplicateTherapistAndStartAt_isRejectedByDatabaseConstraint() {
        TherapistProfile therapist = persistTherapist("therapist-1");
        PatientProfile patient1 = persistPatient("patient-1", therapist);
        PatientProfile patient2 = persistPatient("patient-2", therapist);
        LocalDateTime startAt = LocalDateTime.now().plusDays(2).withSecond(0).withNano(0);

        appointmentRepository.saveAndFlush(buildAppointment(patient1, therapist, startAt));

        assertThrows(
                DataIntegrityViolationException.class,
                () -> appointmentRepository.saveAndFlush(buildAppointment(patient2, therapist, startAt)));
    }

    @Test
    void duplicatePatientAndStartAt_isRejectedByDatabaseConstraint() {
        TherapistProfile therapist1 = persistTherapist("therapist-2");
        TherapistProfile therapist2 = persistTherapist("therapist-3");
        PatientProfile patient = persistPatient("patient-3", therapist1);
        LocalDateTime startAt = LocalDateTime.now().plusDays(3).withSecond(0).withNano(0);

        appointmentRepository.saveAndFlush(buildAppointment(patient, therapist1, startAt));

        assertThrows(
                DataIntegrityViolationException.class,
                () -> appointmentRepository.saveAndFlush(buildAppointment(patient, therapist2, startAt)));
    }

    private TherapistProfile persistTherapist(String key) {
        User user = new User();
        user.setEmail(key + "@example.com");
        user.setUsername(key);
        user.setPasswordHash("hash");
        user.setRole(Role.THERAPIST);
        entityManager.persistAndFlush(user);

        TherapistProfile therapist = new TherapistProfile();
        therapist.setUser(user);
        therapist.setFullName("Therapist " + key);
        therapist.setMeetingLink("https://meet.example.com/" + key);
        entityManager.persistAndFlush(therapist);
        return therapist;
    }

    private PatientProfile persistPatient(String key, TherapistProfile therapist) {
        User user = new User();
        user.setEmail(key + "@example.com");
        user.setUsername(key);
        user.setPasswordHash("hash");
        user.setRole(Role.PATIENT);
        entityManager.persistAndFlush(user);

        PatientProfile patient = new PatientProfile();
        patient.setUser(user);
        patient.setTherapist(therapist);
        patient.setNickName(key);
        patient.setAnonymousModeEnabled(true);
        entityManager.persistAndFlush(patient);
        return patient;
    }

    private Appointment buildAppointment(PatientProfile patient, TherapistProfile therapist, LocalDateTime startAt) {
        Appointment appointment = new Appointment();
        appointment.setPatientProfile(patient);
        appointment.setTherapistProfile(therapist);
        appointment.setStartAt(startAt);
        appointment.setEndAt(startAt.plusMinutes(50));
        appointment.setMeetingLink(therapist.getMeetingLink());
        return appointment;
    }
}
