package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class AdminResetPasswordResponseDto {

    private UUID therapistId;
    private String newPassword;

    public AdminResetPasswordResponseDto() {
    }

    public AdminResetPasswordResponseDto(UUID therapistId, String newPassword) {
        this.therapistId = therapistId;
        this.newPassword = newPassword;
    }

    public UUID getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(UUID therapistId) {
        this.therapistId = therapistId;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
}

