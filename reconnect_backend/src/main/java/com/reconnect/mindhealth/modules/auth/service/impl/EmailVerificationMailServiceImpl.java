package com.reconnect.mindhealth.modules.auth.service.impl;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.reconnect.mindhealth.modules.auth.service.EmailVerificationMailService;

@Service
public class EmailVerificationMailServiceImpl implements EmailVerificationMailService {

    private final JavaMailSender mailSender;
    private final boolean mailEnabled;
    private final String mailFrom;

    public EmailVerificationMailServiceImpl(
            JavaMailSender mailSender,
            @Value("${app.mail.enabled:false}") boolean mailEnabled,
            @Value("${app.mail.from:no-reply@reconnect.local}") String mailFrom) {
        this.mailSender = mailSender;
        this.mailEnabled = mailEnabled;
        this.mailFrom = mailFrom;
    }

    @Override
    public void sendOtp(String email, String otp, Date expiresAt) {
        if (!mailEnabled) {
            return;
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(mailFrom);
        message.setTo(email);
        message.setSubject("Ma xac minh email ReConnect MindHealth");
        message.setText(buildBody(otp, expiresAt));
        try {
            mailSender.send(message);
        } catch (MailException exception) {
            throw new IllegalStateException("Khong the gui ma OTP xac minh email.", exception);
        }
    }

    private String buildBody(String otp, Date expiresAt) {
        String expiresText = expiresAt == null
                ? "trong vai phut"
                : new SimpleDateFormat("HH:mm dd/MM/yyyy", Locale.forLanguageTag("vi-VN")).format(expiresAt);
        return """
                Chao ban,

                Ma xac minh email cua ban la: %s
                Ma co hieu luc den: %s

                Neu ban khong thuc hien yeu cau nay, vui long bo qua email.

                ReConnect MindHealth
                """.formatted(otp, expiresText);
    }
}
