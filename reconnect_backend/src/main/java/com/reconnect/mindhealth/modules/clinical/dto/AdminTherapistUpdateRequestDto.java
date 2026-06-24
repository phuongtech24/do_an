package com.reconnect.mindhealth.modules.clinical.dto;

public class AdminTherapistUpdateRequestDto {

    private String fullName;
    private String phoneNumber;
    private String hometown;
    private Integer birthYear;
    private String voiceDescription;
    private String specialization;
    private String therapyStyle;
    private String bio;
    private String meetingLink;

    public AdminTherapistUpdateRequestDto() {
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
}
