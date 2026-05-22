package com.reconnect.mindhealth.modules.booster.service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;

public interface IBoosterService {
    AppointmentDto bookAppointment(BookAppointmentRequestDto request);

    List<AppointmentDto> getMyAppointments(UUID patientId);

    List<AvailableSlotDto> getAvailableSlots(UUID patientId, LocalDate date);
}

