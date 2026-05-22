package com.reconnect.mindhealth.modules.auth.service;

import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.modules.auth.dto.UserDto;

public interface IUserService {
    List<UserDto> getAllUsers();
    UserDto getUserById(UUID id);
    UserDto getUserByEmail(String email);
}
