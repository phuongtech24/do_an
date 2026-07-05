package com.reconnect.mindhealth.modules.clinical.dto;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class TherapistPatientSearchRequestDto extends PageSearchRequestDto {
    private Boolean redFlagOnly = false;

    public Boolean getRedFlagOnly() { return redFlagOnly; }
    public void setRedFlagOnly(Boolean redFlagOnly) { this.redFlagOnly = redFlagOnly; }
}
