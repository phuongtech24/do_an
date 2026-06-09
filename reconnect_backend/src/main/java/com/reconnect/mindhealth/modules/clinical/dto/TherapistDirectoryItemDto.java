package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;

public class TherapistDirectoryItemDto {
    private UUID therapistId;
    private String fullName;
    private String hometown;
    private Integer birthYear;
    private String voiceDescription;
    private String specialization;
    private String therapyStyle;
    private String bio;
    private String avatarUrl;
    private String email;
    private long credentialCount;
    private long caseloadCount;
    private int caseloadLimit = 20;
    private boolean caseloadFull;

    public TherapistDirectoryItemDto() {
    }

    public TherapistDirectoryItemDto(TherapistProfile profile, long credentialCount, long caseloadCount) {
        this.therapistId = profile.getId();
        this.fullName = profile.getFullName();
        this.hometown = profile.getHometown();
        this.birthYear = profile.getBirthYear();
        this.voiceDescription = profile.getVoiceDescription();
        this.specialization = profile.getSpecialization();
        this.therapyStyle = profile.getTherapyStyle();
        this.bio = profile.getBio();
        this.avatarUrl = profile.getAvatarUrl();
        this.email = profile.getUser() != null ? profile.getUser().getEmail() : null;
        this.credentialCount = credentialCount;
        this.caseloadCount = caseloadCount;
        this.caseloadFull = caseloadCount >= caseloadLimit;
    }

    public UUID getTherapistId() { return therapistId; }
    public void setTherapistId(UUID therapistId) { this.therapistId = therapistId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getHometown() { return hometown; }
    public void setHometown(String hometown) { this.hometown = hometown; }
    public Integer getBirthYear() { return birthYear; }
    public void setBirthYear(Integer birthYear) { this.birthYear = birthYear; }
    public String getVoiceDescription() { return voiceDescription; }
    public void setVoiceDescription(String voiceDescription) { this.voiceDescription = voiceDescription; }
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    public String getTherapyStyle() { return therapyStyle; }
    public void setTherapyStyle(String therapyStyle) { this.therapyStyle = therapyStyle; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public long getCredentialCount() { return credentialCount; }
    public void setCredentialCount(long credentialCount) { this.credentialCount = credentialCount; }
    public long getCaseloadCount() { return caseloadCount; }
    public void setCaseloadCount(long caseloadCount) { this.caseloadCount = caseloadCount; }
    public int getCaseloadLimit() { return caseloadLimit; }
    public void setCaseloadLimit(int caseloadLimit) { this.caseloadLimit = caseloadLimit; }
    public boolean isCaseloadFull() { return caseloadFull; }
    public void setCaseloadFull(boolean caseloadFull) { this.caseloadFull = caseloadFull; }
}
