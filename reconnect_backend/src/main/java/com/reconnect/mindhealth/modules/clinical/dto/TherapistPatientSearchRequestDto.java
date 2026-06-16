package com.reconnect.mindhealth.modules.clinical.dto;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class TherapistPatientSearchRequestDto extends PageSearchRequestDto {
    private Boolean redFlagOnly = false;
}
