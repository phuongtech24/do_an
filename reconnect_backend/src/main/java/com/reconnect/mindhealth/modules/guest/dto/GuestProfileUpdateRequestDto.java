package com.reconnect.mindhealth.modules.guest.dto;

import java.util.UUID;

public class GuestProfileUpdateRequestDto {
    private UUID guestId;
    private String nickname;
    private String avatarIcon;

    public UUID getGuestId() {
        return guestId;
    }

    public void setGuestId(UUID guestId) {
        this.guestId = guestId;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarIcon() {
        return avatarIcon;
    }

    public void setAvatarIcon(String avatarIcon) {
        this.avatarIcon = avatarIcon;
    }
}
