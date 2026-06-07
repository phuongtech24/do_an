package com.reconnect.mindhealth.modules.booster.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public class BookAppointmentRequestDto {
    private UUID patientId;
    private LocalDateTime startAt;
    private Boolean isAnonymous = true;
    private Integer durationMinutes;
    private String purpose;
    private String carePhaseCode;

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

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public String getCarePhaseCode() {
        return carePhaseCode;
    }

    public void setCarePhaseCode(String carePhaseCode) {
        this.carePhaseCode = carePhaseCode;
    }
}
