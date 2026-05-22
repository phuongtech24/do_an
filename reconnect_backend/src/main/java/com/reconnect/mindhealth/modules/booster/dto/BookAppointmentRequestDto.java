package com.reconnect.mindhealth.modules.booster.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public class BookAppointmentRequestDto {
    private UUID patientId;
    private LocalDateTime startAt;
    private Boolean isAnonymous = true;

    public BookAppointmentRequestDto() {
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public LocalDateTime getStartAt() {
        return startAt;
    }

    public void setStartAt(LocalDateTime startAt) {
        this.startAt = startAt;
    }

    public Boolean getIsAnonymous() {
        return isAnonymous;
    }

    public void setIsAnonymous(Boolean isAnonymous) {
        this.isAnonymous = isAnonymous;
    }
}

