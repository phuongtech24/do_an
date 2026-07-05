package com.reconnect.mindhealth.modules.clinical.dto;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class AdminTherapistSearchRequestDto extends PageSearchRequestDto {
    private ApprovalStatus status;

    public ApprovalStatus getStatus() { return status; }
    public void setStatus(ApprovalStatus status) { this.status = status; }
}
