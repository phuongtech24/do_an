package com.reconnect.mindhealth.modules.booster.dto;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

/** Request body để bác sĩ toggle (bật/tắt) 1 slot lịch rảnh */
public class ToggleSlotRequestDto {

    private UUID therapistId;
    private LocalDate slotDate;
    private LocalTime startTime;
    private boolean isOpen;

    public ToggleSlotRequestDto() {}

    public UUID getTherapistId() { return therapistId; }
    public void setTherapistId(UUID therapistId) { this.therapistId = therapistId; }

    public LocalDate getSlotDate() { return slotDate; }
    public void setSlotDate(LocalDate slotDate) { this.slotDate = slotDate; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public boolean isOpen() { return isOpen; }
    public void setOpen(boolean open) { isOpen = open; }
}
