package com.reconnect.mindhealth.modules.booster.service.impl;

import java.time.DayOfWeek;
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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.dto.TherapistScheduleSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.TherapistWeeklyScheduleSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.ToggleSlotRequestDto;
import com.reconnect.mindhealth.modules.booster.dto.ToggleWeeklySlotRequestDto;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.entity.TherapistScheduleSlot;
import com.reconnect.mindhealth.modules.booster.entity.TherapistWeeklyScheduleSlot;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentStatus;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.booster.repository.TherapistScheduleSlotRepository;
import com.reconnect.mindhealth.modules.booster.repository.TherapistWeeklyScheduleSlotRepository;
import com.reconnect.mindhealth.modules.booster.service.IBoosterService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class BoosterServiceImpl implements IBoosterService {

    private static final Logger log = LoggerFactory.getLogger(BoosterServiceImpl.class);
    private static final List<Integer> ALLOWED_DURATIONS = List.of(45, 50, 60, 90);
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
    private TherapistWeeklyScheduleSlotRepository weeklyScheduleSlotRepository;

    @Autowired
    private TherapistProfileRepository therapistProfileRepository;

    @Autowired
    private AuthContextService authContextService;

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
            throw new IllegalStateException("Bệnh nhân chưa chọn chuyên gia.");
        }

        LocalDateTime startAt = request.getStartAt();
        int durationMinutes = request.getDurationMinutes() == null ? 50 : request.getDurationMinutes();
        if (!ALLOWED_DURATIONS.contains(durationMinutes)) {
            throw new IllegalArgumentException("Duration chỉ hỗ trợ 45, 50, 60 hoặc 90 phút.");
        }
        AppointmentPurpose purpose = resolveAppointmentPurpose(request.getPurpose(), durationMinutes);
        validatePurposeForPatient(patient, purpose, durationMinutes);
        String carePhaseCode = normalizeCarePhaseCode(request.getCarePhaseCode(), patient);

        log.info("Book appointment: patientId={}, therapistId={}, startAt={}, duration={}, purpose={}",
                patient.getId(), therapist.getId(), startAt, durationMinutes, purpose);

        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(therapist.getId(), startAt)) {
            throw new IllegalStateException("Khung giờ này đã được đặt. Vui lòng chọn khung giờ khác.");
        }

        LocalDate slotDate = startAt.toLocalDate();
        LocalTime slotTime = startAt.toLocalTime();
        Optional<TherapistScheduleSlot> closedSlot = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDateAndStartTime(therapist.getId(), slotDate, slotTime);
        if (closedSlot.isPresent() && !closedSlot.get().isOpen()) {
            throw new IllegalStateException("Chuyên gia đã đóng khung giờ này. Vui lòng chọn khung giờ khác.");
        }

        Appointment appt = new Appointment();
        appt.setPatientProfile(patient);
        appt.setTherapistProfile(therapist);
        appt.setStartAt(startAt);
        appt.setEndAt(startAt.plusMinutes(durationMinutes));
        appt.setIsAnonymous(request.getIsAnonymous() != null ? request.getIsAnonymous() : true);
        appt.setMeetingLink(therapist.getMeetingLink());
        appt.setPurpose(purpose);
        appt.setClinicalPurposeCode(purpose.name());
        appt.setCarePhaseCode(carePhaseCode);

        Appointment saved = appointmentRepository.save(appt);
        return new AppointmentDto(saved);
    }

    private AppointmentPurpose resolveAppointmentPurpose(String rawPurpose, int durationMinutes) {
        if (rawPurpose != null && !rawPurpose.isBlank()) {
            try {
                return AppointmentPurpose.valueOf(rawPurpose.trim().toUpperCase());
            } catch (IllegalArgumentException ex) {
                throw new IllegalArgumentException("Mục đích buổi hẹn không hợp lệ: " + rawPurpose);
            }
        }
        if (durationMinutes == 60) {
            return AppointmentPurpose.INITIAL_ASSESSMENT;
        }
        if (durationMinutes == 90) {
            return AppointmentPurpose.BEHAVIORAL_EXPERIMENT;
        }
        return AppointmentPurpose.CBT_SESSION;
    }

    private void validatePurposeForPatient(PatientProfile patient, AppointmentPurpose purpose, int durationMinutes) {
        switch (purpose) {
            case INITIAL_ASSESSMENT -> {
                if (durationMinutes != 60) {
                    throw new IllegalArgumentException("Phiên đánh giá ban đầu cần thời lượng 60 phút.");
                }
            }
            case BEHAVIORAL_EXPERIMENT, INTENSIVE_EXPOSURE -> {
                if (durationMinutes != 90) {
                    throw new IllegalArgumentException("Thử nghiệm hành vi hoặc can thiệp cường độ cao cần thời lượng 90 phút.");
                }
            }
            case BOOSTER_3M, BOOSTER_6M, BOOSTER_12M -> {
                if (patient.getGraduatedAt() == null) {
                    throw new IllegalStateException("Booster session chỉ áp dụng sau khi kết thúc điều trị chính.");
                }
            }
            case CRISIS -> {
                if (!isRedFlagPatient(patient)) {
                    throw new IllegalStateException("Lịch khẩn cấp chỉ áp dụng cho ca cờ đỏ hoặc nguy cơ cao.");
                }
            }
            default -> {
            }
        }
    }

    private String normalizeCarePhaseCode(String requestedCode, PatientProfile patient) {
        if (requestedCode != null && !requestedCode.isBlank()) {
            return requestedCode.trim().toUpperCase();
        }
        return deriveCarePhaseCode(patient);
    }

    private String deriveCarePhaseCode(PatientProfile patient) {
        if (isRedFlagPatient(patient)) {
            return "RED_FLAG_OVERRIDE";
        }
        if (patient.getGraduatedAt() != null) {
            return "MAINTENANCE";
        }
        if (patient.getTaperingStage() == TaperingStage.MONTHLY) {
            return "TAPERING_BIWEEKLY";
        }
        if (patient.getTaperingStage() == TaperingStage.QUARTERLY) {
            return "TAPERING_3_TO_4_WEEKS";
        }
        return "STANDARD_WEEKLY";
    }

    private boolean isRedFlagPatient(PatientProfile patient) {
        return Boolean.TRUE.equals(patient.getIsRedFlagActive())
                || (patient.getCurrentRiskScore() != null && patient.getCurrentRiskScore() >= 70);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDto> getMyAppointments(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu patientId.");
        }
        return appointmentRepository.findByPatientProfile_IdOrderByStartAtDesc(patientId)
                .stream()
                .map(AppointmentDto::new)
                .collect(Collectors.toList());
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
            throw new IllegalStateException("Bệnh nhân chưa chọn chuyên gia.");
        }

        UUID therapistId = therapist.getId();
        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to = date.atTime(LocalTime.MAX);

        List<Appointment> booked = appointmentRepository.findTherapistAppointmentsInRange(therapistId, from, to);
        List<TherapistScheduleSlot> closedSlots = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDate(therapistId, date);
        Map<LocalTime, Boolean> dateOpenMap = closedSlots.stream()
                .collect(Collectors.toMap(TherapistScheduleSlot::getStartTime, TherapistScheduleSlot::isOpen));
        Map<LocalTime, Boolean> weeklyOpenMap = weeklyScheduleSlotRepository
                .findByTherapistProfile_IdAndDayOfWeek(therapistId, date.getDayOfWeek())
                .stream()
                .collect(Collectors.toMap(TherapistWeeklyScheduleSlot::getStartTime, TherapistWeeklyScheduleSlot::isOpen));

        List<AvailableSlotDto> slots = new ArrayList<>();
        for (LocalTime time : DEFAULT_SLOTS) {
            LocalDateTime startAt = date.atTime(time);
            boolean isBooked = booked.stream().anyMatch(a -> a.getStartAt() != null && a.getStartAt().equals(startAt));
            boolean isOpen = dateOpenMap.getOrDefault(time, weeklyOpenMap.getOrDefault(time, true));
            slots.add(new AvailableSlotDto(startAt, !isBooked && isOpen));
        }
        return slots;
    }

    @Override
    @Transactional(readOnly = true)
    public List<TherapistScheduleSlotDto> getTherapistSchedule(UUID therapistId, LocalDate date) {
        if (therapistId == null) {
            throw new IllegalArgumentException("Thiếu therapistId.");
        }
        if (date == null) {
            date = LocalDate.now();
        }

        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to = date.atTime(LocalTime.MAX);

        List<Appointment> bookedAppts = appointmentRepository.findTherapistAppointmentsInRange(therapistId, from, to);
        Map<LocalTime, Appointment> bookedMap = bookedAppts.stream()
                .filter(a -> a.getStartAt() != null)
                .collect(Collectors.toMap(
                        a -> a.getStartAt().toLocalTime(),
                        Function.identity(),
                        (a, b) -> a));

        List<TherapistScheduleSlot> savedSlots = scheduleSlotRepository
                .findByTherapistProfile_IdAndSlotDate(therapistId, date);
        Map<LocalTime, TherapistScheduleSlot> savedMap = savedSlots.stream()
                .collect(Collectors.toMap(TherapistScheduleSlot::getStartTime, Function.identity()));
        Map<LocalTime, Boolean> weeklyOpenMap = weeklyScheduleSlotRepository
                .findByTherapistProfile_IdAndDayOfWeek(therapistId, date.getDayOfWeek())
                .stream()
                .collect(Collectors.toMap(TherapistWeeklyScheduleSlot::getStartTime, TherapistWeeklyScheduleSlot::isOpen));

        final LocalDate finalDate = date;
        List<TherapistScheduleSlotDto> result = new ArrayList<>();
        for (LocalTime time : DEFAULT_SLOTS) {
            if (bookedMap.containsKey(time)) {
                result.add(new TherapistScheduleSlotDto(finalDate, time, bookedMap.get(time)));
            } else if (savedMap.containsKey(time)) {
                result.add(new TherapistScheduleSlotDto(savedMap.get(time)));
            } else if (weeklyOpenMap.containsKey(time)) {
                result.add(new TherapistScheduleSlotDto(finalDate, time, weeklyOpenMap.get(time)));
            } else {
                result.add(new TherapistScheduleSlotDto(finalDate, time));
            }
        }
        return result;
    }

    @Override
    public TherapistScheduleSlotDto toggleSlot(ToggleSlotRequestDto request) {
        if (request == null) {
            throw new IllegalArgumentException("Thiếu request.");
        }
        if (request.getTherapistId() == null) {
            throw new IllegalArgumentException("Thiếu therapistId.");
        }
        if (request.getSlotDate() == null) {
            throw new IllegalArgumentException("Thiếu slotDate.");
        }
        if (request.getStartTime() == null) {
            throw new IllegalArgumentException("Thiếu startTime.");
        }

        TherapistProfile therapist = therapistProfileRepository.findById(request.getTherapistId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist: " + request.getTherapistId()));

        LocalDateTime startAt = LocalDateTime.of(request.getSlotDate(), request.getStartTime());
        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(request.getTherapistId(), startAt)) {
            throw new IllegalStateException("Không thể thay đổi slot đã có lịch hẹn.");
        }

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

    @Override
    @Transactional(readOnly = true)
    public List<TherapistWeeklyScheduleSlotDto> getWeeklySchedule(UUID therapistId) {
        if (therapistId == null) {
            throw new IllegalArgumentException("Thiếu therapistId.");
        }

        Map<DayOfWeek, Map<LocalTime, Boolean>> savedMap = weeklyScheduleSlotRepository
                .findByTherapistProfile_Id(therapistId)
                .stream()
                .collect(Collectors.groupingBy(
                        TherapistWeeklyScheduleSlot::getDayOfWeek,
                        Collectors.toMap(TherapistWeeklyScheduleSlot::getStartTime, TherapistWeeklyScheduleSlot::isOpen)));

        List<TherapistWeeklyScheduleSlotDto> result = new ArrayList<>();
        for (DayOfWeek day : DayOfWeek.values()) {
            Map<LocalTime, Boolean> dayMap = savedMap.getOrDefault(day, Map.of());
            for (LocalTime time : DEFAULT_SLOTS) {
                result.add(new TherapistWeeklyScheduleSlotDto(day, time, dayMap.getOrDefault(time, true)));
            }
        }
        return result;
    }

    @Override
    public TherapistWeeklyScheduleSlotDto toggleWeeklySlot(ToggleWeeklySlotRequestDto request) {
        if (request == null) {
            throw new IllegalArgumentException("Thiếu request.");
        }
        if (request.getTherapistId() == null) {
            throw new IllegalArgumentException("Thiếu therapistId.");
        }
        if (request.getDayOfWeek() == null) {
            throw new IllegalArgumentException("Thiếu dayOfWeek.");
        }
        if (request.getStartTime() == null) {
            throw new IllegalArgumentException("Thiếu startTime.");
        }

        TherapistProfile therapist = therapistProfileRepository.findById(request.getTherapistId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist: " + request.getTherapistId()));

        TherapistWeeklyScheduleSlot slot = weeklyScheduleSlotRepository
                .findByTherapistProfile_IdAndDayOfWeekAndStartTime(
                        request.getTherapistId(), request.getDayOfWeek(), request.getStartTime())
                .orElse(new TherapistWeeklyScheduleSlot());

        slot.setTherapistProfile(therapist);
        slot.setDayOfWeek(request.getDayOfWeek());
        slot.setStartTime(request.getStartTime());
        slot.setOpen(request.isOpen());

        TherapistWeeklyScheduleSlot saved = weeklyScheduleSlotRepository.save(slot);
        return new TherapistWeeklyScheduleSlotDto(saved.getDayOfWeek(), saved.getStartTime(), saved.isOpen());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AppointmentDto> getTherapistAppointments(UUID therapistId) {
        if (therapistId == null) {
            throw new IllegalArgumentException("Thiếu therapistId.");
        }
        return appointmentRepository.findByTherapistProfile_IdOrderByStartAtDesc(therapistId)
                .stream()
                .map(AppointmentDto::new)
                .collect(Collectors.toList());
    }

    @Override
    public AppointmentDto updateAppointmentStatus(UUID appointmentId, AppointmentStatus status) {
        if (appointmentId == null) {
            throw new IllegalArgumentException("Thiếu appointmentId.");
        }
        if (status == null) {
            throw new IllegalArgumentException("Thiếu status.");
        }
        if (status != AppointmentStatus.COMPLETED && status != AppointmentStatus.CANCELLED) {
            throw new IllegalArgumentException("Chỉ hỗ trợ chuyển lịch hẹn sang COMPLETED hoặc CANCELLED.");
        }

        User current = authContextService.requireCurrentUser();
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy lịch hẹn: " + appointmentId));

        boolean isAdmin = current.getRole() == Role.ADMIN;
        boolean isAssignedTherapist = current.getRole() == Role.THERAPIST
                && appointment.getTherapistProfile() != null
                && appointment.getTherapistProfile().getId().equals(current.getId());
        if (!isAdmin && !isAssignedTherapist) {
            throw new SecurityException("Bạn không có quyền cập nhật lịch hẹn này.");
        }

        if (appointment.getStatus() == AppointmentStatus.COMPLETED && status != AppointmentStatus.COMPLETED) {
            throw new IllegalStateException("Lịch hẹn đã hoàn thành, không thể đổi sang trạng thái khác.");
        }

        appointment.setStatus(status);
        Appointment saved = appointmentRepository.save(appointment);
        return new AppointmentDto(saved);
    }

    @Override
    public AppointmentDto updateAppointmentNotes(UUID appointmentId, String notes) {
        if (appointmentId == null) {
            throw new IllegalArgumentException("Thiếu appointmentId.");
        }

        User current = authContextService.requireCurrentUser();
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy lịch hẹn: " + appointmentId));

        boolean isAdmin = current.getRole() == Role.ADMIN;
        boolean isAssignedTherapist = current.getRole() == Role.THERAPIST
                && appointment.getTherapistProfile() != null
                && appointment.getTherapistProfile().getId().equals(current.getId());
        if (!isAdmin && !isAssignedTherapist) {
            throw new SecurityException("Bạn không có quyền ghi chú lịch hẹn này.");
        }
        if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
            throw new IllegalStateException("Lịch hẹn đã hủy, không thể ghi chú.");
        }

        String normalized = notes == null ? null : notes.trim();
        appointment.setTherapistNotes(normalized == null || normalized.isEmpty() ? null : normalized);
        return new AppointmentDto(appointmentRepository.save(appointment));
    }
}
