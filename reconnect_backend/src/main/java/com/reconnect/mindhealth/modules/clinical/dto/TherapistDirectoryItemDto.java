package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;

public class TherapistDirectoryItemDto {
    private UUID therapistId;
    private String fullName;
    private String specialization;
    private String bio;
    private String avatarUrl;
    private String email;
    private long caseloadCount;
    private int caseloadLimit = 20;
    private boolean caseloadFull;

    public TherapistDirectoryItemDto() {
    }

    public TherapistDirectoryItemDto(TherapistProfile profile, long caseloadCount) {
        this.therapistId = profile.getId();
        this.fullName = profile.getFullName();
        this.specialization = profile.getSpecialization();
        this.bio = profile.getBio();
        this.avatarUrl = profile.getAvatarUrl();
        this.email = profile.getUser() != null ? profile.getUser().getEmail() : null;
        this.caseloadCount = caseloadCount;
        this.caseloadFull = caseloadCount >= caseloadLimit;
    }

    public UUID getTherapistId() { return therapistId; }
    public void setTherapistId(UUID therapistId) { this.therapistId = therapistId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public long getCaseloadCount() { return caseloadCount; }
    public void setCaseloadCount(long caseloadCount) { this.caseloadCount = caseloadCount; }
    public int getCaseloadLimit() { return caseloadLimit; }
    public void setCaseloadLimit(int caseloadLimit) { this.caseloadLimit = caseloadLimit; }
    public boolean isCaseloadFull() { return caseloadFull; }
    public void setCaseloadFull(boolean caseloadFull) { this.caseloadFull = caseloadFull; }
}
