package com.reconnect.mindhealth.modules.clinical.dto;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class AdminPatientProfileSearchRequestDto extends PageSearchRequestDto {
    private Boolean redFlagOnly = false;
    private Boolean triageOnly = false;

    public Boolean getRedFlagOnly() { return redFlagOnly; }
    public void setRedFlagOnly(Boolean redFlagOnly) { this.redFlagOnly = redFlagOnly; }
    public Boolean getTriageOnly() { return triageOnly; }
    public void setTriageOnly(Boolean triageOnly) { this.triageOnly = triageOnly; }
}
