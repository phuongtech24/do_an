package com.reconnect.mindhealth.modules.auth.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String email;
    private String password;
    private Boolean rememberMe;
    
    public LoginRequest() {
    }

    public LoginRequest(String email, String password) {
        this.email = email;
        this.password = password;
    }
}
