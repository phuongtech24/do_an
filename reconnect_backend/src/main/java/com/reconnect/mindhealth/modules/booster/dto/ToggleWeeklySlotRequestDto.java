package com.reconnect.mindhealth.modules.booster.dto;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.UUID;

public class ToggleWeeklySlotRequestDto {
    private UUID therapistId;
    private DayOfWeek dayOfWeek;
    private LocalTime startTime;
    private boolean open;

    public UUID getTherapistId() { return therapistId; }
    public void setTherapistId(UUID therapistId) { this.therapistId = therapistId; }

    public DayOfWeek getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(DayOfWeek dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public boolean isOpen() { return open; }
    public void setOpen(boolean open) { this.open = open; }
}
