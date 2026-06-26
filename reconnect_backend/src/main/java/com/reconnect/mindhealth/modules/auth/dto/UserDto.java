package com.reconnect.mindhealth.modules.auth.dto;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;

public class UserDto extends BaseObjectDto {
    private String email;
    private String username;
    private Role role;
    private Boolean isAnonymous;
    private Boolean isActive;
    private Boolean emailVerified;

    public UserDto() {}

    public UserDto(User entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());
            this.email = entity.getEmail();
            this.username = entity.getUsername();
            this.role = entity.getRole();
            this.isAnonymous = entity.getIsAnonymous();
            this.isActive = entity.getIsActive();
            this.emailVerified = entity.getEmailVerified();
        }
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
    public Boolean getIsAnonymous() { return isAnonymous; }
    public void setIsAnonymous(Boolean isAnonymous) { this.isAnonymous = isAnonymous; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public Boolean getEmailVerified() { return emailVerified; }
    public void setEmailVerified(Boolean emailVerified) { this.emailVerified = emailVerified; }
}
