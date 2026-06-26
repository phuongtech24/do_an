package com.reconnect.mindhealth.modules.auth.service;

import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.EmailVerificationRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.EmailVerificationResponseDto;
import com.reconnect.mindhealth.modules.auth.dto.GuestLinkAccountRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
import com.reconnect.mindhealth.modules.auth.dto.ResendEmailOtpRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.dto.RefreshTokenRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.ForgotPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.ResetPasswordRequestDto;

public interface IAuthService {
    EmailVerificationResponseDto register(RegisterRequest request);

    LoginResponse login(LoginRequest request);

    LoginResponse registerAnonymous(String deviceId);

    EmailVerificationResponseDto linkGuestAccount(GuestLinkAccountRequestDto request);

    UserDto verifyEmailOtp(EmailVerificationRequestDto request);

    EmailVerificationResponseDto resendEmailOtp(ResendEmailOtpRequestDto request);

    LoginResponse refreshToken(RefreshTokenRequestDto request);

    void requestPasswordReset(ForgotPasswordRequestDto request);

    void resetPassword(ResetPasswordRequestDto request);
}
