package com.reconnect.mindhealth.modules.auth.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.auth.dto.GuestLinkAccountRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
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
}
