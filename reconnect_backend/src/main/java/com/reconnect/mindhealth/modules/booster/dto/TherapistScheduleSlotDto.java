package com.reconnect.mindhealth.modules.booster.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.entity.TherapistScheduleSlot;

/**
 * DTO trả về trạng thái 1 slot lịch của bác sĩ.
 * status: "OPEN" | "CLOSED" | "BOOKED"
 */
public class TherapistScheduleSlotDto {

    private LocalDate slotDate;
    private LocalTime startTime;
    private LocalDateTime startAt;    // slotDate + startTime (tiện cho UI)
    private String status;            // "OPEN" | "CLOSED" | "BOOKED"
    private String patientNickname;   // chỉ có khi status = BOOKED (ẩn danh)
    private UUID appointmentId;       // chỉ có khi BOOKED

    public TherapistScheduleSlotDto() {}

    /** Constructor cho slot OPEN hoặc CLOSED */
    public TherapistScheduleSlotDto(TherapistScheduleSlot slot) {
        this.slotDate = slot.getSlotDate();
        this.startTime = slot.getStartTime();
        this.startAt = LocalDateTime.of(slot.getSlotDate(), slot.getStartTime());
        this.status = slot.isOpen() ? "OPEN" : "CLOSED";
    }

    /** Constructor cho slot mặc định OPEN (chưa có record trong DB) */
    public TherapistScheduleSlotDto(LocalDate date, LocalTime time) {
        this.slotDate = date;
        this.startTime = time;
        this.startAt = LocalDateTime.of(date, time);
        this.status = "OPEN";
    }

    public TherapistScheduleSlotDto(LocalDate date, LocalTime time, boolean open) {
        this.slotDate = date;
        this.startTime = time;
        this.startAt = LocalDateTime.of(date, time);
        this.status = open ? "OPEN" : "CLOSED";
    }

    /** Constructor cho slot đã được đặt (BOOKED) */
    public TherapistScheduleSlotDto(LocalDate date, LocalTime time, Appointment appt) {
        this.slotDate = date;
        this.startTime = time;
        this.startAt = LocalDateTime.of(date, time);
        this.status = "BOOKED";
        this.appointmentId = appt.getId();
        // Hiển thị ẩn danh nếu bệnh nhân bật chế độ ẩn danh
        if (Boolean.TRUE.equals(appt.getIsAnonymous())) {
            String nick = appt.getPatientProfile() != null ? appt.getPatientProfile().getNickName() : null;
            this.patientNickname = nick != null ? nick : "Bệnh nhân ẩn danh";
        } else {
            String fullName = appt.getPatientProfile() != null && appt.getPatientProfile().getUser() != null
                    ? appt.getPatientProfile().getUser().getUsername()
                    : null;
            this.patientNickname = fullName != null ? fullName : "Bệnh nhân";
        }
    }

    public LocalDate getSlotDate() { return slotDate; }
    public void setSlotDate(LocalDate slotDate) { this.slotDate = slotDate; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalDateTime getStartAt() { return startAt; }
    public void setStartAt(LocalDateTime startAt) { this.startAt = startAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPatientNickname() { return patientNickname; }
    public void setPatientNickname(String patientNickname) { this.patientNickname = patientNickname; }

    public UUID getAppointmentId() { return appointmentId; }
    public void setAppointmentId(UUID appointmentId) { this.appointmentId = appointmentId; }
}
