package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

public class TherapistApplicantDto {
    private UUID therapistId;
    private String fullName;
    private String phoneNumber;
    private String email;
    private String hometown;
    private Integer birthYear;
    private String voiceDescription;
    private String specialization;
    private String therapyStyle;
    private String bio;
    private String meetingLink;
    private String avatarUrl;
    private ApprovalStatus approvalStatus;
    private long credentialCount;
    private boolean active;
    private long caseloadCount;
    private int caseloadLimit = 20;
    private boolean caseloadFull;

    public TherapistApplicantDto() {
    }

    public TherapistApplicantDto(TherapistProfile profile) {
        this(profile, 0, 0);
    }

    public TherapistApplicantDto(TherapistProfile profile, long credentialCount) {
        if (profile != null) {
            this.therapistId = profile.getId();
            this.fullName = profile.getFullName();
            this.phoneNumber = profile.getPhoneNumber();
            this.hometown = profile.getHometown();
            this.birthYear = profile.getBirthYear();
            this.voiceDescription = profile.getVoiceDescription();
            this.specialization = profile.getSpecialization();
            this.therapyStyle = profile.getTherapyStyle();
            this.bio = profile.getBio();
            this.meetingLink = profile.getMeetingLink();
            this.avatarUrl = profile.getAvatarUrl();
            this.approvalStatus = profile.getApprovalStatus();
            this.credentialCount = credentialCount;
            if (profile.getUser() != null) {
                this.email = profile.getUser().getEmail();
                this.active = Boolean.TRUE.equals(profile.getUser().getIsActive());
            }
        }
    }

    public TherapistApplicantDto(TherapistProfile profile, long credentialCount, long caseloadCount) {
        this(profile, credentialCount);
        this.caseloadCount = caseloadCount;
        this.caseloadFull = caseloadCount >= this.caseloadLimit;
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

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getHometown() {
        return hometown;
    }

    public void setHometown(String hometown) {
        this.hometown = hometown;
    }

    public Integer getBirthYear() {
        return birthYear;
    }

    public void setBirthYear(Integer birthYear) {
        this.birthYear = birthYear;
    }

    public String getVoiceDescription() {
        return voiceDescription;
    }

    public void setVoiceDescription(String voiceDescription) {
        this.voiceDescription = voiceDescription;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getTherapyStyle() {
        return therapyStyle;
    }

    public void setTherapyStyle(String therapyStyle) {
        this.therapyStyle = therapyStyle;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getMeetingLink() {
        return meetingLink;
    }

    public void setMeetingLink(String meetingLink) {
        this.meetingLink = meetingLink;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
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

    public long getCaseloadCount() {
        return caseloadCount;
    }

    public void setCaseloadCount(long caseloadCount) {
        this.caseloadCount = caseloadCount;
        this.caseloadFull = caseloadCount >= this.caseloadLimit;
    }

    public int getCaseloadLimit() {
        return caseloadLimit;
    }

    public void setCaseloadLimit(int caseloadLimit) {
        this.caseloadLimit = caseloadLimit;
        this.caseloadFull = this.caseloadCount >= caseloadLimit;
    }

    public boolean isCaseloadFull() {
        return caseloadFull;
    }

    public void setCaseloadFull(boolean caseloadFull) {
        this.caseloadFull = caseloadFull;
    }
}
