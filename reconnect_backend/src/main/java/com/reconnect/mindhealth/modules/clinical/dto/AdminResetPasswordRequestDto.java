package com.reconnect.mindhealth.modules.clinical.dto;

public class AdminResetPasswordRequestDto {

    /**
     * Optional. If empty -> backend generates a random password.
     */
    private String newPassword;

    public AdminResetPasswordRequestDto() {
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
}

