package com.reconnect.mindhealth.modules.auth.service;

import java.util.Date;

public interface EmailVerificationMailService {
    void sendOtp(String email, String otp, Date expiresAt);
}
