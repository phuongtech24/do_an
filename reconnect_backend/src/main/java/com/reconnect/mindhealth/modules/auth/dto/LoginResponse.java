package com.reconnect.mindhealth.modules.auth.dto;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginResponse {
    private UserDto user;
    private String accessToken;
    private String refreshToken;
    private Date accessTokenExpiresAt;
    private Date refreshTokenExpiresAt;
    private Long expiresIn;
    private Long refreshExpiresIn;
    private String token;
}
