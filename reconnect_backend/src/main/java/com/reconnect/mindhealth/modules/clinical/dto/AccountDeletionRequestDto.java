package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class AccountDeletionRequestDto {
    private UUID patientId;
    private Boolean confirmDelete;

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public Boolean getConfirmDelete() {
        return confirmDelete;
    }

    public void setConfirmDelete(Boolean confirmDelete) {
        this.confirmDelete = confirmDelete;
    }
}
