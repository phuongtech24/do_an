package com.reconnect.mindhealth.modules.clinical.dto;

import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

public class TherapistProfileStatusDto {

    private ApprovalStatus approvalStatus;
    private long credentialCount;

    public TherapistProfileStatusDto() {
    }

    public TherapistProfileStatusDto(ApprovalStatus approvalStatus, long credentialCount) {
        this.approvalStatus = approvalStatus;
        this.credentialCount = credentialCount;
    }

    public ApprovalStatus getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(ApprovalStatus approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public long getCredentialCount() {
        return credentialCount;
    }

    public void setCredentialCount(long credentialCount) {
        this.credentialCount = credentialCount;
    }
}

