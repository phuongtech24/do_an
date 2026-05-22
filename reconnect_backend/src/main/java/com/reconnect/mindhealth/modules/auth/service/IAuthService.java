package com.reconnect.mindhealth.modules.auth.service;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.entity.User;

public interface IAuthService {
    //Đăng ký tài khoản mới
    UserDto register(String email, String password, String role, Boolean isAnonymous, String nickname, String avatarIcon);

    //Đăng nhập
    LoginResponse login(LoginRequest request);

    // Đăng ký ẩn danh (Guest)
    LoginResponse registerAnonymous(String deviceId);
}
