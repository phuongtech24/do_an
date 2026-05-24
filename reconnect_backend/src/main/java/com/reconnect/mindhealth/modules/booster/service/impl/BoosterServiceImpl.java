package com.reconnect.mindhealth.modules.booster.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.dto.TherapistScheduleSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.ToggleSlotRequestDto;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.entity.TherapistScheduleSlot;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.booster.repository.TherapistScheduleSlotRepository;
import com.reconnect.mindhealth.modules.booster.service.IBoosterService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class BoosterServiceImpl implements IBoosterService {

    /** 6 slot mặc định trong ngày */
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

    @Autowired
    private TherapistScheduleSlotRepository scheduleSlotRepository;

    @Autowired
    private TherapistProfileRepository therapistProfileRepository;

    // ====================================================
    // Bệnh nhân: Đặt lịch
    // ====================================================

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
            throw new IllegalStateException("Bệnh nhân chưa được gán bác sĩ.");
        }

        LocalDateTime startAt = request.getStartAt();

        // Kiểm tra slot đã bị đặt chưa
        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(therapist.getId(), startAt)) {
            throw new IllegalStateException("Khung giờ này đã được đặt. Vui lòng chọn khung giờ khác.");
        }

        // Kiểm tra bác sĩ có đóng slot này không
        LocalDate slotDate = startAt.toLocalDate();
        LocalTime slotTime = startAt.toLocalTime();
        Optional<TherapistScheduleSlot> closedSlot = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDateAndStartTime(therapist.getId(), slotDate, slotTime);
        if (closedSlot.isPresent() && !closedSlot.get().isOpen()) {
            throw new IllegalStateException("Bác sĩ đã đóng khung giờ này. Vui lòng chọn khung giờ khác.");
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

    // ====================================================
    // Bệnh nhân: Xem lịch đã đặt
    // ====================================================

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDto> getMyAppointments(UUID patientId) {
        if (patientId == null) throw new IllegalArgumentException("Thiếu patientId.");
        return appointmentRepository.findByPatientProfile_IdOrderByStartAtDesc(patientId)
                .stream().map(AppointmentDto::new).collect(Collectors.toList());
    }

    // ====================================================
    // Bệnh nhân: Xem slot còn trống
    // ====================================================

    @Override
    @Transactional(readOnly = true)
    public List<AvailableSlotDto> getAvailableSlots(UUID patientId, LocalDate date) {
        if (patientId == null) throw new IllegalArgumentException("Thiếu patientId.");
        if (date == null) date = LocalDate.now();

        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân với ID: " + patientId));

        TherapistProfile therapist = patient.getTherapist();
        if (therapist == null) {
            throw new IllegalStateException("Bệnh nhân chưa được gán bác sĩ.");
        }

        UUID therapistId = therapist.getId();
        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to = date.atTime(LocalTime.MAX);

        // Lịch hẹn đã đặt
        List<Appointment> booked = appointmentRepository.findTherapistAppointmentsInRange(therapistId, from, to);
        // Slot bác sĩ đã đóng
        List<TherapistScheduleSlot> closedSlots = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDate(therapistId, date);
        Map<LocalTime, Boolean> closedMap = closedSlots.stream()
                .collect(Collectors.toMap(TherapistScheduleSlot::getStartTime, s -> !s.isOpen()));

        List<AvailableSlotDto> slots = new ArrayList<>();
        for (LocalTime t : DEFAULT_SLOTS) {
            LocalDateTime startAt = date.atTime(t);
            boolean isBooked = booked.stream().anyMatch(a -> a.getStartAt() != null && a.getStartAt().equals(startAt));
            boolean isClosed = closedMap.getOrDefault(t, false); // false = mặc định OPEN
            slots.add(new AvailableSlotDto(startAt, !isBooked && !isClosed));
        }
        return slots;
    }

    // ====================================================
    // Bác sĩ: Xem lịch của mình theo ngày
    // ====================================================

    @Override
    @Transactional(readOnly = true)
    public List<TherapistScheduleSlotDto> getTherapistSchedule(UUID therapistId, LocalDate date) {
        if (therapistId == null) throw new IllegalArgumentException("Thiếu therapistId.");
        if (date == null) date = LocalDate.now();

        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to = date.atTime(LocalTime.MAX);

        // Lịch hẹn đã đặt trong ngày
        List<Appointment> bookedAppts = appointmentRepository.findTherapistAppointmentsInRange(therapistId, from, to);
        Map<LocalTime, Appointment> bookedMap = bookedAppts.stream()
                .filter(a -> a.getStartAt() != null)
                .collect(Collectors.toMap(
                        a -> a.getStartAt().toLocalTime(),
                        Function.identity(),
                        (a, b) -> a // keep first nếu trùng
                ));

        // Slot bác sĩ đã toggle
        List<TherapistScheduleSlot> savedSlots = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDate(therapistId, date);
        Map<LocalTime, TherapistScheduleSlot> savedMap = savedSlots.stream()
                .collect(Collectors.toMap(TherapistScheduleSlot::getStartTime, Function.identity()));

        final LocalDate finalDate = date;
        List<TherapistScheduleSlotDto> result = new ArrayList<>();
        for (LocalTime t : DEFAULT_SLOTS) {
            if (bookedMap.containsKey(t)) {
                result.add(new TherapistScheduleSlotDto(finalDate, t, bookedMap.get(t)));
            } else if (savedMap.containsKey(t)) {
                result.add(new TherapistScheduleSlotDto(savedMap.get(t)));
            } else {
                result.add(new TherapistScheduleSlotDto(finalDate, t)); // mặc định OPEN
            }
        }
        return result;
    }

    // ====================================================
    // Bác sĩ: Toggle slot
    // ====================================================

    @Override
    public TherapistScheduleSlotDto toggleSlot(ToggleSlotRequestDto request) {
        if (request.getTherapistId() == null) throw new IllegalArgumentException("Thiếu therapistId.");
        if (request.getSlotDate() == null) throw new IllegalArgumentException("Thiếu slotDate.");
        if (request.getStartTime() == null) throw new IllegalArgumentException("Thiếu startTime.");

        TherapistProfile therapist = therapistProfileRepository.findById(request.getTherapistId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist: " + request.getTherapistId()));

        // Kiểm tra slot không phải đang BOOKED
        LocalDateTime startAt = LocalDateTime.of(request.getSlotDate(), request.getStartTime());
        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(request.getTherapistId(), startAt)) {
            throw new IllegalStateException("Không thể thay đổi slot đã có lịch hẹn.");
        }

        // Upsert record
        TherapistScheduleSlot slot = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDateAndStartTime(
                        request.getTherapistId(), request.getSlotDate(), request.getStartTime())
                .orElse(new TherapistScheduleSlot());

        slot.setTherapistProfile(therapist);
        slot.setSlotDate(request.getSlotDate());
        slot.setStartTime(request.getStartTime());
        slot.setOpen(request.isOpen());

        TherapistScheduleSlot saved = scheduleSlotRepository.save(slot);
        return new TherapistScheduleSlotDto(saved);
    }

    // ====================================================
    // Bác sĩ: Xem lịch hẹn của mình
    // ====================================================

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDto> getTherapistAppointments(UUID therapistId) {
        if (therapistId == null) throw new IllegalArgumentException("Thiếu therapistId.");
        return appointmentRepository.findByTherapistProfile_IdOrderByStartAtDesc(therapistId)
                .stream().map(AppointmentDto::new).collect(Collectors.toList());
    }
}
