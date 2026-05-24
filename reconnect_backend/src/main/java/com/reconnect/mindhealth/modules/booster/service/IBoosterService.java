package com.reconnect.mindhealth.modules.booster.service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.dto.TherapistScheduleSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.ToggleSlotRequestDto;

public interface IBoosterService {
    AppointmentDto bookAppointment(BookAppointmentRequestDto request);

    List<AppointmentDto> getMyAppointments(UUID patientId);

    List<AvailableSlotDto> getAvailableSlots(UUID patientId, LocalDate date);

    /** Bác sĩ xem lịch của mình theo ngày (OPEN/CLOSED/BOOKED) */
    List<TherapistScheduleSlotDto> getTherapistSchedule(UUID therapistId, LocalDate date);

    /** Bác sĩ toggle bật/tắt 1 slot */
    TherapistScheduleSlotDto toggleSlot(ToggleSlotRequestDto request);

    /** Bác sĩ xem danh sách lịch hẹn của mình */
    List<AppointmentDto> getTherapistAppointments(UUID therapistId);
}


