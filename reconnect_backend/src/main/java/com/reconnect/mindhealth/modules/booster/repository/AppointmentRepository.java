package com.reconnect.mindhealth.modules.booster.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, UUID> {

    boolean existsByTherapistProfile_IdAndStartAt(UUID therapistId, LocalDateTime startAt);

    boolean existsByPatientProfile_IdAndStartAt(UUID patientId, LocalDateTime startAt);

    boolean existsByPatientProfile_IdAndPurposeAndStartAt(UUID patientId, AppointmentPurpose purpose, LocalDateTime startAt);

    List<Appointment> findByPatientProfile_IdOrderByStartAtDesc(UUID patientId);

    Appointment findTopByPatientProfile_IdAndPurposeOrderByStartAtDesc(UUID patientId, AppointmentPurpose purpose);

    @Query("SELECT a FROM Appointment a WHERE a.therapistProfile.id = :therapistId AND a.startAt BETWEEN :from AND :to ORDER BY a.startAt ASC")
    List<Appointment> findTherapistAppointmentsInRange(@Param("therapistId") UUID therapistId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to);
}
