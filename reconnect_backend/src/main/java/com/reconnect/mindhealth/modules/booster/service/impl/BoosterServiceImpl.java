package com.reconnect.mindhealth.modules.booster.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.booster.service.IBoosterService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class BoosterServiceImpl implements IBoosterService {

    private static final List<LocalTime> DEFAULT_SLOTS = List.of(
            LocalTime.of(9, 0),
            LocalTime.of(10, 0),
            LocalTime.of(11, 0),
            LocalTime.of(14, 0),
            LocalTime.of(15, 30),
            LocalTime.of(17, 0));

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Override
    public AppointmentDto bookAppointment(BookAppointmentRequestDto request) {
        if (request == null || request.getPatientId() == null) {
            throw new IllegalArgumentException("Thiếu patientId.");
        }
        if (request.getStartAt() == null) {
            throw new IllegalArgumentException("Thiếu startAt.");
        }

        PatientProfile patient = patientProfileRepository.findById(request.getPatientId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân với ID: " + request.getPatientId()));

        TherapistProfile therapist = patient.getTherapist();
        if (therapist == null) {
            throw new IllegalStateException("Bệnh nhân chưa được gán bác sĩ (therapist).");
        }

        LocalDateTime startAt = request.getStartAt();
        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(therapist.getId(), startAt)) {
            throw new IllegalStateException("Khung giờ này đã được đặt. Vui lòng chọn khung giờ khác.");
        }

        Appointment appt = new Appointment();
        appt.setPatientProfile(patient);
        appt.setTherapistProfile(therapist);
        appt.setStartAt(startAt);
        appt.setEndAt(startAt.plusMinutes(30));
        appt.setIsAnonymous(request.getIsAnonymous() != null ? request.getIsAnonymous() : true);
        appt.setMeetingLink(therapist.getMeetingLink());
        appt.setPurpose(AppointmentPurpose.TAPERING);

        Appointment saved = appointmentRepository.save(appt);
        return new AppointmentDto(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDto> getMyAppointments(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu patientId.");
        }
        List<Appointment> list = appointmentRepository.findByPatientProfile_IdOrderByStartAtDesc(patientId);
        List<AppointmentDto> out = new ArrayList<>();
        for (Appointment a : list) {
            out.add(new AppointmentDto(a));
        }
        return out;
    }

    @Override
    @Transactional(readOnly = true)
    public List<AvailableSlotDto> getAvailableSlots(UUID patientId, LocalDate date) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu patientId.");
        }
        if (date == null) {
            date = LocalDate.now();
        }

        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân với ID: " + patientId));

        TherapistProfile therapist = patient.getTherapist();
        if (therapist == null) {
            throw new IllegalStateException("Bệnh nhân chưa được gán bác sĩ (therapist).");
        }

        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to = date.atTime(LocalTime.MAX);
        List<Appointment> booked = appointmentRepository.findTherapistAppointmentsInRange(therapist.getId(), from, to);

        List<AvailableSlotDto> slots = new ArrayList<>();
        for (LocalTime t : DEFAULT_SLOTS) {
            LocalDateTime startAt = date.atTime(t);
            boolean available = true;
            for (Appointment a : booked) {
                if (a.getStartAt() != null && a.getStartAt().equals(startAt)) {
                    available = false;
                    break;
                }
            }
            slots.add(new AvailableSlotDto(startAt, available));
        }
        return slots;
    }
}
