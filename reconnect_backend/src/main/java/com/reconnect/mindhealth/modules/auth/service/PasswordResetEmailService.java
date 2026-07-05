package com.reconnect.mindhealth.modules.auth.service;

import java.util.Date;

public interface PasswordResetEmailService {
    void sendResetPasswordEmail(String email, String resetToken, Date expiresAt);
}
