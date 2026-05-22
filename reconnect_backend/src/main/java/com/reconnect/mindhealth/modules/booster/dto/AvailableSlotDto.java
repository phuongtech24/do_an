package com.reconnect.mindhealth.modules.booster.dto;

import java.time.LocalDateTime;

public class AvailableSlotDto {
    private LocalDateTime startAt;
    private boolean available;

    public AvailableSlotDto() {
    }

    public AvailableSlotDto(LocalDateTime startAt, boolean available) {
        this.startAt = startAt;
        this.available = available;
    }

    public LocalDateTime getStartAt() {
        return startAt;
    }

    public void setStartAt(LocalDateTime startAt) {
        this.startAt = startAt;
    }

    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }
}

