package com.reconnect.mindhealth.modules.auth.dto;

import java.util.UUID;

public class GuestLinkAccountRequestDto {
    private UUID guestId;
    private String email;
    private String password;
    private String realFullName;
    private String phoneNumber;

    public UUID getGuestId() {
        return guestId;
    }

    public void setGuestId(UUID guestId) {
        this.guestId = guestId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRealFullName() {
        return realFullName;
    }

    public void setRealFullName(String realFullName) {
        this.realFullName = realFullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
}
