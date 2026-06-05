package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class TherapistSelectionRequestDto {
    private UUID patientId;
    private UUID therapistId;

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public UUID getTherapistId() { return therapistId; }
    public void setTherapistId(UUID therapistId) { this.therapistId = therapistId; }
}
