package com.reconnect.mindhealth.modules.booster.dto;

import java.time.DayOfWeek;
import java.time.LocalTime;

public class TherapistWeeklyScheduleSlotDto {
    private DayOfWeek dayOfWeek;
    private LocalTime startTime;
    private String status;

    public TherapistWeeklyScheduleSlotDto() {}

    public TherapistWeeklyScheduleSlotDto(DayOfWeek dayOfWeek, LocalTime startTime, boolean open) {
        this.dayOfWeek = dayOfWeek;
        this.startTime = startTime;
        this.status = open ? "OPEN" : "CLOSED";
    }

    public DayOfWeek getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(DayOfWeek dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
