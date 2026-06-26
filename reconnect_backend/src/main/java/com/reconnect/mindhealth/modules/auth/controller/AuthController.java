package com.reconnect.mindhealth.modules.auth.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.auth.dto.EmailVerificationRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.EmailVerificationResponseDto;
import com.reconnect.mindhealth.modules.auth.dto.ForgotPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.GuestLinkAccountRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.RefreshTokenRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
import com.reconnect.mindhealth.modules.auth.dto.ResendEmailOtpRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.ResetPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.service.IAuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private IAuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<EmailVerificationResponseDto>> register(@RequestBody RegisterRequest request) {
        try {
            EmailVerificationResponseDto rs = authService.register(request);
            return ResponseEntity.ok(ApiResponse.success("Da tao tai khoan va gui ma OTP xac minh email.", rs));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            if (response == null) {
                return ResponseEntity.ok(ApiResponse.error("Sai mat khau."));
            }
            return ResponseEntity.ok(ApiResponse.success("Dang nhap thanh cong.", response));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/register-anonymous")
    public ResponseEntity<ApiResponse<LoginResponse>> registerAnonymous(@RequestParam String deviceId) {
        try {
            LoginResponse rs = authService.registerAnonymous(deviceId);
            return ResponseEntity.ok(ApiResponse.success("Da tao phien guest.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/guest/link-account")
    public ResponseEntity<ApiResponse<EmailVerificationResponseDto>> linkGuestAccount(@RequestBody GuestLinkAccountRequestDto request) {
        try {
            EmailVerificationResponseDto rs = authService.linkGuestAccount(request);
            return ResponseEntity.ok(ApiResponse.success("Da gui ma OTP de hoan tat lien ket tai khoan.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/verify-email-otp")
    public ResponseEntity<ApiResponse<UserDto>> verifyEmailOtp(@RequestBody EmailVerificationRequestDto request) {
        try {
            UserDto rs = authService.verifyEmailOtp(request);
            return ResponseEntity.ok(ApiResponse.success("Xac minh email thanh cong.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/resend-email-otp")
    public ResponseEntity<ApiResponse<EmailVerificationResponseDto>> resendEmailOtp(@RequestBody ResendEmailOtpRequestDto request) {
        try {
            EmailVerificationResponseDto rs = authService.resendEmailOtp(request);
            return ResponseEntity.ok(ApiResponse.success("Da gui lai ma OTP.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<LoginResponse>> refresh(@RequestBody RefreshTokenRequestDto request) {
        try {
            LoginResponse rs = authService.refreshToken(request);
            return ResponseEntity.ok(ApiResponse.success("Lam moi phien dang nhap thanh cong.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(@RequestBody ForgotPasswordRequestDto request) {
        try {
            authService.requestPasswordReset(request);
            return ResponseEntity.ok(ApiResponse.success("Neu email ton tai, he thong da tao yeu cau dat lai mat khau.", null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@RequestBody ResetPasswordRequestDto request) {
        try {
            authService.resetPassword(request);
            return ResponseEntity.ok(ApiResponse.success("Dat lai mat khau thanh cong.", null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Loi: " + e.getMessage()));
        }
    }
}
