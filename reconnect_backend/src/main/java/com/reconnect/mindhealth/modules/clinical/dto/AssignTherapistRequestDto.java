package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;

public class AssignTherapistRequestDto {

    @NotNull
    private UUID therapistId;

    public UUID getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(UUID therapistId) {
        this.therapistId = therapistId;
    }
}

