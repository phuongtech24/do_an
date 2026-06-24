package com.reconnect.mindhealth.modules.journal.dto;

import java.util.UUID;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class JournalSearchRequestDto extends PageSearchRequestDto {
    private UUID patientId;

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
}
