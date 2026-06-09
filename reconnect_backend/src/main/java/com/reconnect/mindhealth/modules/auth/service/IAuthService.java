package com.reconnect.mindhealth.modules.auth.service;

import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.GuestLinkAccountRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;

public interface IAuthService {
    UserDto register(RegisterRequest request);

    LoginResponse login(LoginRequest request);

    LoginResponse registerAnonymous(String deviceId);

    LoginResponse linkGuestAccount(GuestLinkAccountRequestDto request);
}
