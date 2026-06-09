package com.reconnect.mindhealth.modules.auth.dto;

import java.time.LocalDate;

import lombok.Data;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private String role;
    private Boolean isAnonymous = false;
    private String nickname;
    private String avatarIcon;
    private Boolean anonymousModeEnabled = true;
    private String realFullName;
    private LocalDate dateOfBirth;
    private String gender;
    private String phoneNumber;
    private String emergencyContactPhone;
    private String educationLevel;
    private String occupation;
    private String relationshipStatus;
    private String medicalHistory;
}
