package com.reconnect.mindhealth.modules.clinical.dto;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class AdminPatientProfileSearchRequestDto extends PageSearchRequestDto {
    private Boolean redFlagOnly = false;
    private Boolean triageOnly = false;
}
