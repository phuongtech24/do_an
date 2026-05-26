package com.reconnect.mindhealth.modules.booster.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentStatus;

public class AppointmentDto extends BaseObjectDto {
    private UUID patientId;
    private UUID therapistId;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private AppointmentStatus status;
    private AppointmentPurpose purpose;
    private Boolean isAnonymous;
    private String meetingLink;
    private String patientDisplayName;
    private String therapistDisplayName;
    private String therapistNotes;

    public AppointmentDto() {
    }

    public AppointmentDto(Appointment entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());

            if (entity.getPatientProfile() != null) {
                this.patientId = entity.getPatientProfile().getId();
                String nickname = entity.getPatientProfile().getNickName();
                String username = entity.getPatientProfile().getUser() != null ? entity.getPatientProfile().getUser().getUsername() : null;
                String email = entity.getPatientProfile().getUser() != null ? entity.getPatientProfile().getUser().getEmail() : null;
                this.patientDisplayName = firstNonBlank(nickname, username, email, "Bệnh nhân");
            }
            if (entity.getTherapistProfile() != null) {
                this.therapistId = entity.getTherapistProfile().getId();
                this.meetingLink = firstNonBlank(entity.getMeetingLink(), entity.getTherapistProfile().getMeetingLink());
                String fullName = entity.getTherapistProfile().getFullName();
                String username = entity.getTherapistProfile().getUser() != null ? entity.getTherapistProfile().getUser().getUsername() : null;
                String email = entity.getTherapistProfile().getUser() != null ? entity.getTherapistProfile().getUser().getEmail() : null;
                this.therapistDisplayName = firstNonBlank(fullName, username, email, "Bác sĩ");
            }
            this.startAt = entity.getStartAt();
            this.endAt = entity.getEndAt();
            this.status = entity.getStatus();
            this.purpose = entity.getPurpose();
            this.isAnonymous = entity.getIsAnonymous();
            if (this.meetingLink == null || this.meetingLink.isBlank()) {
                this.meetingLink = entity.getMeetingLink();
            }
            this.therapistNotes = entity.getTherapistNotes();
        }
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public UUID getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(UUID therapistId) {
        this.therapistId = therapistId;
    }

    public LocalDateTime getStartAt() {
        return startAt;
    }

    public void setStartAt(LocalDateTime startAt) {
        this.startAt = startAt;
    }

    public LocalDateTime getEndAt() {
        return endAt;
    }

    public void setEndAt(LocalDateTime endAt) {
        this.endAt = endAt;
    }

    public AppointmentStatus getStatus() {
        return status;
    }

    public void setStatus(AppointmentStatus status) {
        this.status = status;
    }

    public AppointmentPurpose getPurpose() {
        return purpose;
    }

    public void setPurpose(AppointmentPurpose purpose) {
        this.purpose = purpose;
    }

    public Boolean getIsAnonymous() {
        return isAnonymous;
    }

    public void setIsAnonymous(Boolean isAnonymous) {
        this.isAnonymous = isAnonymous;
    }

    public String getMeetingLink() {
        return meetingLink;
    }

    public void setMeetingLink(String meetingLink) {
        this.meetingLink = meetingLink;
    }

    public String getPatientDisplayName() {
        return patientDisplayName;
    }

    public void setPatientDisplayName(String patientDisplayName) {
        this.patientDisplayName = patientDisplayName;
    }

    public String getTherapistDisplayName() {
        return therapistDisplayName;
    }

    public void setTherapistDisplayName(String therapistDisplayName) {
        this.therapistDisplayName = therapistDisplayName;
    }

    public String getTherapistNotes() {
        return therapistNotes;
    }

    public void setTherapistNotes(String therapistNotes) {
        this.therapistNotes = therapistNotes;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }
}
