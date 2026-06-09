package com.reconnect.mindhealth.modules.booster.repository;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.booster.entity.TherapistWeeklyScheduleSlot;

@Repository
public interface TherapistWeeklyScheduleSlotRepository extends JpaRepository<TherapistWeeklyScheduleSlot, UUID> {
    List<TherapistWeeklyScheduleSlot> findByTherapistProfile_Id(UUID therapistId);

    List<TherapistWeeklyScheduleSlot> findByTherapistProfile_IdAndDayOfWeek(UUID therapistId, DayOfWeek dayOfWeek);

    Optional<TherapistWeeklyScheduleSlot> findByTherapistProfile_IdAndDayOfWeekAndStartTime(
            UUID therapistId, DayOfWeek dayOfWeek, LocalTime startTime);
}
