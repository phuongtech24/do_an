package com.reconnect.mindhealth.modules.booster.repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.booster.entity.TherapistScheduleSlot;

@Repository
public interface TherapistScheduleSlotRepository extends JpaRepository<TherapistScheduleSlot, UUID> {

    /** Lấy tất cả slot của bác sĩ theo ngày */
    List<TherapistScheduleSlot> findByTherapistProfile_IdAndSlotDate(UUID therapistId, LocalDate slotDate);

    /** Tìm 1 slot cụ thể để toggle */
    Optional<TherapistScheduleSlot> findByTherapistProfile_IdAndSlotDateAndStartTime(
            UUID therapistId, LocalDate slotDate, LocalTime startTime);
}
