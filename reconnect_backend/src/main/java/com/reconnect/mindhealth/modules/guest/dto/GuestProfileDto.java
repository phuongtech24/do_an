package com.reconnect.mindhealth.modules.guest.dto;

import com.reconnect.mindhealth.modules.guest.entity.GuestProfile;

public class GuestProfileDto {
    private String guestId;
    private String nickname;
    private String avatarIcon;
    private Boolean lsasDemoCompleted;

    public GuestProfileDto() {
    }

    public GuestProfileDto(GuestProfile entity) {
        this.guestId = entity.getId() != null ? entity.getId().toString() : null;
        this.nickname = entity.getNickname();
        this.avatarIcon = entity.getAvatarIcon();
        this.lsasDemoCompleted = entity.getLsasDemoCompleted();
    }

    public String getGuestId() {
        return guestId;
    }

    public void setGuestId(String guestId) {
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

    public Boolean getLsasDemoCompleted() {
        return lsasDemoCompleted;
    }

    public void setLsasDemoCompleted(Boolean lsasDemoCompleted) {
        this.lsasDemoCompleted = lsasDemoCompleted;
    }
}
