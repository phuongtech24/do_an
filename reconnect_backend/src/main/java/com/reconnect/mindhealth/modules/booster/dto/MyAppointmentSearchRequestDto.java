package com.reconnect.mindhealth.modules.booster.dto;

import java.util.UUID;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class MyAppointmentSearchRequestDto extends PageSearchRequestDto {
    private UUID patientId;

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
}
