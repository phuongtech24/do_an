package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class TherapistAssignmentStatusDto {
    private UUID patientId;
    private boolean assigned;
    private UUID therapistId;
    private String therapistName;
    private String message;

    public TherapistAssignmentStatusDto() {
    }

    public TherapistAssignmentStatusDto(UUID patientId, boolean assigned, UUID therapistId, String therapistName, String message) {
        this.patientId = patientId;
        this.assigned = assigned;
        this.therapistId = therapistId;
        this.therapistName = therapistName;
        this.message = message;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public boolean isAssigned() {
        return assigned;
    }

    public void setAssigned(boolean assigned) {
        this.assigned = assigned;
    }

    public UUID getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(UUID therapistId) {
        this.therapistId = therapistId;
    }

    public String getTherapistName() {
        return therapistName;
    }

    public void setTherapistName(String therapistName) {
        this.therapistName = therapistName;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

