package com.reconnect.mindhealth.modules.auth.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.auth.dto.ForgotPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.GuestLinkAccountRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.RefreshTokenRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
import com.reconnect.mindhealth.modules.auth.dto.ResetPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.service.IAuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private IAuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserDto>> register(@RequestBody RegisterRequest request) {
        try {
            UserDto rs = authService.register(request);
            return ResponseEntity.ok(ApiResponse.success("Đăng ký thành công.", rs));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            if (response == null) {
                return ResponseEntity.ok(ApiResponse.error("Sai mật khẩu."));
            }
            return ResponseEntity.ok(ApiResponse.success("Đăng nhập thành công.", response));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/register-anonymous")
    public ResponseEntity<ApiResponse<LoginResponse>> registerAnonymous(@RequestParam String deviceId) {
        try {
            LoginResponse rs = authService.registerAnonymous(deviceId);
            return ResponseEntity.ok(ApiResponse.success("Đã tạo phiên guest.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/guest/link-account")
    public ResponseEntity<ApiResponse<LoginResponse>> linkGuestAccount(@RequestBody GuestLinkAccountRequestDto request) {
        try {
            LoginResponse rs = authService.linkGuestAccount(request);
            return ResponseEntity.ok(ApiResponse.success("Đã liên kết tài khoản thành công.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<LoginResponse>> refresh(@RequestBody RefreshTokenRequestDto request) {
        try {
            LoginResponse rs = authService.refreshToken(request);
            return ResponseEntity.ok(ApiResponse.success("Làm mới phiên đăng nhập thành công.", rs));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(@RequestBody ForgotPasswordRequestDto request) {
        try {
            authService.requestPasswordReset(request);
            return ResponseEntity.ok(ApiResponse.success("Nếu email tồn tại, hệ thống đã tạo yêu cầu đặt lại mật khẩu.", null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@RequestBody ResetPasswordRequestDto request) {
        try {
            authService.resetPassword(request);
            return ResponseEntity.ok(ApiResponse.success("Đặt lại mật khẩu thành công.", null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}
