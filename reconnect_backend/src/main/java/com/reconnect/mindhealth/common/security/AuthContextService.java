package com.reconnect.mindhealth.common.security;

import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AuthContextService {

    private final UserRepository userRepository;

    public AuthContextService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public String requireEmail() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getPrincipal() == null) {
            throw new SecurityException("Unauthenticated");
        }
        return String.valueOf(auth.getPrincipal());
    }

    public User requireCurrentUser() {
        String email = requireEmail();
        Optional<User> user = userRepository.findByEmail(email);
        return user.orElseThrow(() -> new EntityNotFoundException("User not found for email: " + email));
    }
}

