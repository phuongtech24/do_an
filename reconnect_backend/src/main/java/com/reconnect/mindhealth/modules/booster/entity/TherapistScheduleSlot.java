package com.reconnect.mindhealth.modules.booster.entity;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

/**
 * Bảng lưu trạng thái bật/tắt của từng slot lịch theo ngày (do bác sĩ tự quản lý).
 * Mặc định tất cả slot đều OPEN (is_open = true).
 * Bác sĩ chỉ cần tắt slot nào mình bận.
 */
@Entity
@Table(
    name = "therapist_schedule_slots",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_therapist_date_time",
        columnNames = {"therapist_id", "slot_date", "start_time"}
    )
)
public class TherapistScheduleSlot {

    @Id
    @GeneratedValue(generator = "UUID")
    @org.hibernate.annotations.GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "therapist_id", nullable = false)
    private TherapistProfile therapistProfile;

    @Column(name = "slot_date", nullable = false)
    private LocalDate slotDate;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    /** true = bác sĩ mở slot, false = bác sĩ đóng slot */
    @Column(name = "is_open", nullable = false)
    private boolean isOpen = true;

    public TherapistScheduleSlot() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public TherapistProfile getTherapistProfile() { return therapistProfile; }
    public void setTherapistProfile(TherapistProfile therapistProfile) { this.therapistProfile = therapistProfile; }

    public LocalDate getSlotDate() { return slotDate; }
    public void setSlotDate(LocalDate slotDate) { this.slotDate = slotDate; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public boolean isOpen() { return isOpen; }
    public void setOpen(boolean open) { isOpen = open; }
}
