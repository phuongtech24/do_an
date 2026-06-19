package com.reconnect.mindhealth.modules.auth.service.impl;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.common.util.JwtUtil;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;
import com.reconnect.mindhealth.modules.auth.dto.ForgotPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.auth.service.PasswordResetEmailService;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;
import com.reconnect.mindhealth.modules.guest.repository.GuestProfileRepository;

@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PatientProfileRepository patientProfileRepository;

    @Mock
    private TherapistProfileRepository therapistProfileRepository;

    @Mock
    private GuestProfileRepository guestProfileRepository;

    @Mock
    private JwtUtil jwtUtil;

    @Mock
    private IAssessmentService assessmentService;

    @Mock
    private ObjectMapper objectMapper;

    @Mock
    private PasswordResetEmailService passwordResetEmailService;

    @InjectMocks
    private AuthServiceImpl authService;

    @Test
    void requestPasswordReset_generatesTokenAndSendsEmail_whenUserExists() {
        ForgotPasswordRequestDto request = new ForgotPasswordRequestDto();
        request.setEmail("bn12@gmail.com");
        User user = new User();
        user.setEmail("bn12@gmail.com");
        when(userRepository.findByEmail("bn12@gmail.com")).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        assertDoesNotThrow(() -> authService.requestPasswordReset(request));

        verify(userRepository).save(user);
        verify(passwordResetEmailService).sendResetPasswordEmail(any(), any(), any());
        assertNotNull(user.getResetPasswordToken());
        assertNotNull(user.getResetPasswordExpiresAt());
    }

    @Test
    void requestPasswordReset_throws_whenEmailBlank() {
        ForgotPasswordRequestDto request = new ForgotPasswordRequestDto();
        request.setEmail("   ");

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> authService.requestPasswordReset(request));

        assertEquals("Email là bắt buộc.", exception.getMessage());
    }

    @Test
    void requestPasswordReset_doesNothing_whenUserNotFound() {
        ForgotPasswordRequestDto request = new ForgotPasswordRequestDto();
        request.setEmail("missing@gmail.com");
        when(userRepository.findByEmail("missing@gmail.com")).thenReturn(Optional.empty());

        assertDoesNotThrow(() -> authService.requestPasswordReset(request));

        verify(userRepository, never()).save(any(User.class));
        verify(passwordResetEmailService, never()).sendResetPasswordEmail(any(), any(), any());
    }
}
