package com.reconnect.mindhealth.modules.auth.service.impl;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.reconnect.mindhealth.modules.auth.service.PasswordResetEmailService;

@Service
public class PasswordResetEmailServiceImpl implements PasswordResetEmailService {
    private static final Logger log = LoggerFactory.getLogger(PasswordResetEmailServiceImpl.class);

    private final ObjectProvider<JavaMailSender> mailSenderProvider;

    @Value("${app.mail.enabled:false}")
    private boolean mailEnabled;

    @Value("${app.mail.from:no-reply@mindhealth.local}")
    private String mailFrom;

    @Value("${app.mail.reset-password-subject:MindHealth - Đặt lại mật khẩu}")
    private String resetPasswordSubject;

    @Value("${app.mail.reset-password-url-base:}")
    private String resetPasswordUrlBase;

    public PasswordResetEmailServiceImpl(ObjectProvider<JavaMailSender> mailSenderProvider) {
        this.mailSenderProvider = mailSenderProvider;
    }

    @Override
    public void sendResetPasswordEmail(String email, String resetToken, Date expiresAt) {
        if (!mailEnabled) {
            log.info("Password reset email skipped because app.mail.enabled=false email={}, resetToken={}, expiresAt={}",
                    email,
                    resetToken,
                    expiresAt);
            return;
        }

        JavaMailSender mailSender = mailSenderProvider.getIfAvailable();
        if (mailSender == null) {
            log.warn("Password reset email fallback because JavaMailSender is unavailable email={}, resetToken={}, expiresAt={}",
                    email,
                    resetToken,
                    expiresAt);
            return;
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(mailFrom);
        message.setTo(email);
        message.setSubject(resetPasswordSubject);
        message.setText(buildMailBody(resetToken, expiresAt));

        try {
            mailSender.send(message);
            log.info("Password reset email sent successfully email={}, expiresAt={}", email, expiresAt);
        } catch (MailException exception) {
            log.error("Failed to send password reset email email={}, resetToken={}, expiresAt={}",
                    email,
                    resetToken,
                    expiresAt,
                    exception);
        }
    }

    private String buildMailBody(String resetToken, Date expiresAt) {
        String expiresText = new SimpleDateFormat("dd/MM/yyyy HH:mm", new Locale("vi", "VN")).format(expiresAt);
        StringBuilder builder = new StringBuilder();
        builder.append("MindHealth xin chào,")
                .append("\n\n")
                .append("Chúng tôi đã nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.")
                .append("\n")
                .append("Mã đặt lại mật khẩu của bạn là: ")
                .append(resetToken)
                .append("\n")
                .append("Mã này có hiệu lực đến: ")
                .append(expiresText)
                .append(".")
                .append("\n\n");

        if (resetPasswordUrlBase != null && !resetPasswordUrlBase.isBlank()) {
            builder.append("Bạn cũng có thể mở liên kết sau để tiếp tục:")
                    .append("\n")
                    .append(resetPasswordUrlBase)
                    .append(resetPasswordUrlBase.contains("?") ? "&" : "?")
                    .append("token=")
                    .append(resetToken)
                    .append("\n\n");
        }

        builder.append("Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.")
                .append("\n\n")
                .append("Trân trọng,")
                .append("\n")
                .append("MindHealth");
        return builder.toString();
    }
}
