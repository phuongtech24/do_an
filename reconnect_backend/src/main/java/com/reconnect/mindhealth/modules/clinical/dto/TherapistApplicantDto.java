package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

public class TherapistApplicantDto {
    private UUID therapistId;
    private String fullName;
    private String email;
    private String specialization;
    private ApprovalStatus approvalStatus;
    private long credentialCount;
    private boolean active;

    public TherapistApplicantDto() {
    }

    public TherapistApplicantDto(TherapistProfile profile) {
        this(profile, 0);
    }

    public TherapistApplicantDto(TherapistProfile profile, long credentialCount) {
        if (profile != null) {
            this.therapistId = profile.getId();
            this.fullName = profile.getFullName();
            this.specialization = profile.getSpecialization();
            this.approvalStatus = profile.getApprovalStatus();
            this.credentialCount = credentialCount;
            if (profile.getUser() != null) {
                this.email = profile.getUser().getEmail();
                this.active = Boolean.TRUE.equals(profile.getUser().getIsActive());
            }
        }
    }

    public UUID getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(UUID therapistId) {
        this.therapistId = therapistId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
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

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
