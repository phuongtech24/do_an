package com.reconnect.mindhealth.modules.booster.entity;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
    name = "therapist_weekly_schedule_slots",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_therapist_weekday_time",
        columnNames = {"therapist_id", "day_of_week", "start_time"}
    )
)
public class TherapistWeeklyScheduleSlot {

    @Id
    @GeneratedValue(generator = "UUID")
    @org.hibernate.annotations.GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "therapist_id", nullable = false)
    private TherapistProfile therapistProfile;

    @Enumerated(EnumType.STRING)
    @Column(name = "day_of_week", nullable = false, length = 16)
    private DayOfWeek dayOfWeek;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "is_open", nullable = false)
    private boolean open = true;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public TherapistProfile getTherapistProfile() { return therapistProfile; }
    public void setTherapistProfile(TherapistProfile therapistProfile) { this.therapistProfile = therapistProfile; }

    public DayOfWeek getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(DayOfWeek dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public boolean isOpen() { return open; }
    public void setOpen(boolean open) { this.open = open; }
}
