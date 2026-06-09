package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class PatientSafetyGateRequestDto {
    private UUID patientId;
    private String realFullName;
    private String phoneNumber;

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public String getRealFullName() { return realFullName; }
    public void setRealFullName(String realFullName) { this.realFullName = realFullName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}
