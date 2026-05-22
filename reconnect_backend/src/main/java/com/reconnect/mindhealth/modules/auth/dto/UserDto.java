package com.reconnect.mindhealth.modules.auth.dto;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import java.util.UUID;

public class UserDto extends BaseObjectDto {
    private String email;
    private Role role;
    private Boolean isAnonymous;

    // Constructor mặc định
    public UserDto() {}

    // Constructor convert từ Entity (Chuẩn ECDS)
    public UserDto(User entity) {
        if (entity != null) {
               // Copy thông tin từ BaseObject (id, createDate, ...)
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());
            // Copy thông tin riêng của User
            this.email = entity.getEmail();
            this.role = entity.getRole() != null ? entity.getRole() : null;
            this.isAnonymous = entity.getIsAnonymous();
        }
    }


    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public Boolean getIsAnonymous() {
        return isAnonymous;
    }

    public void setIsAnonymous(Boolean isAnonymous) {
        this.isAnonymous = isAnonymous;
    }
    
}
