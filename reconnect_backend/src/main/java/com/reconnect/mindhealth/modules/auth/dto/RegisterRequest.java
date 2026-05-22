package com.reconnect.mindhealth.modules.auth.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private String role;                     // "PATIENT" hoặc "THERAPIST"
    private Boolean isAnonymous = false;     // Mặc định là false nếu không truyền
    private String nickname;
    private String avatarIcon;
    
}
