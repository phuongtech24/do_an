package com.reconnect.mindhealth.modules.clinical.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.Status;

public class AdminPatientProfileListItemDto {

    private String patientId;
    private String email;
    private String nickname;
    private Status status;
    private Integer currentRiskScore;
    private Boolean redFlagActive;
    private LocalDateTime graduatedAt;
    private Boolean active;

    private String therapistId;
    private String therapistName;

    public AdminPatientProfileListItemDto() {
    }

    public AdminPatientProfileListItemDto(PatientProfile p) {
        UUID id = p.getId();
        this.patientId = id != null ? id.toString() : null;
        this.email = p.getUser() != null ? p.getUser().getEmail() : null;
        this.nickname = p.getNickName();
        this.status = p.getStatus();
        this.currentRiskScore = p.getCurrentRiskScore();
        this.redFlagActive = p.getIsRedFlagActive();
        this.graduatedAt = p.getGraduatedAt();
        this.active = p.getUser() != null ? p.getUser().getIsActive() : null;

        if (p.getTherapist() != null) {
            this.therapistId = p.getTherapist().getId() != null ? p.getTherapist().getId().toString() : null;
            this.therapistName = p.getTherapist().getFullName();
        }
    }

    public String getPatientId() {
        return patientId;
    }

    public void setPatientId(String patientId) {
        this.patientId = patientId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }

    public Boolean getRedFlagActive() {
        return redFlagActive;
    }

    public void setRedFlagActive(Boolean redFlagActive) {
        this.redFlagActive = redFlagActive;
    }

    public LocalDateTime getGraduatedAt() {
        return graduatedAt;
    }

    public void setGraduatedAt(LocalDateTime graduatedAt) {
        this.graduatedAt = graduatedAt;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public String getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(String therapistId) {
        this.therapistId = therapistId;
    }

    public String getTherapistName() {
        return therapistName;
    }

    public void setTherapistName(String therapistName) {
        this.therapistName = therapistName;
    }
}

