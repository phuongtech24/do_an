package com.reconnect.mindhealth.modules.auth.service.impl;

import java.util.List;
import java.util.Locale;
import java.util.UUID;
import java.util.Date;
import java.util.concurrent.ThreadLocalRandom;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.common.util.JwtUtil;
import com.reconnect.mindhealth.common.util.PatientProfileFieldValidator;
import com.reconnect.mindhealth.modules.assessment.dto.LsasAnswerRequestDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSubmissionDto;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;
import com.reconnect.mindhealth.modules.auth.dto.GuestLinkAccountRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.ForgotPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.RefreshTokenRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
import com.reconnect.mindhealth.modules.auth.dto.ResetPasswordRequestDto;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.auth.service.IAuthService;
import com.reconnect.mindhealth.modules.auth.service.PasswordResetEmailService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;
import com.reconnect.mindhealth.modules.guest.entity.GuestProfile;
import com.reconnect.mindhealth.modules.guest.repository.GuestProfileRepository;

import jakarta.annotation.Resource;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Transactional
@Service
public class AuthServiceImpl implements IAuthService {
    private static final Logger log = LoggerFactory.getLogger(AuthServiceImpl.class);

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Resource
    private UserRepository userRepository;

    @Resource
    private PatientProfileRepository patientProfileRepository;

    @Resource
    private TherapistProfileRepository therapistProfileRepository;

    @Resource
    private GuestProfileRepository guestProfileRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private IAssessmentService assessmentService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PasswordResetEmailService passwordResetEmailService;

    @Override
    public UserDto register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã được sử dụng!");
        }

        if (Boolean.TRUE.equals(request.getIsAnonymous())) {
            if (request.getNickname() == null || request.getNickname().trim().isEmpty()) {
                throw new RuntimeException("Đăng ký ẩn danh bắt buộc phải có biệt danh!");
            }
            if (request.getAvatarIcon() == null || request.getAvatarIcon().trim().isEmpty()) {
                throw new RuntimeException("Đăng ký ẩn danh bắt buộc phải có avatar hệ thống!");
            }
        }

        String encodedPassword = passwordEncoder.encode(request.getPassword());
        User entity = new User();
        entity.setEmail(request.getEmail());
        entity.setUsername(request.getNickname() != null && !request.getNickname().trim().isEmpty()
                ? request.getNickname().trim()
                : request.getEmail().split("@")[0]);
        entity.setPasswordHash(encodedPassword);
        entity.setRole(Role.valueOf(request.getRole() != null ? request.getRole() : "PATIENT"));
        entity.setIsAnonymous(request.getIsAnonymous() != null ? request.getIsAnonymous() : false);

        User savedUser = this.userRepository.save(entity);

        if (entity.getRole() == Role.PATIENT) {
            PatientProfile profile = new PatientProfile();
            profile.setUser(savedUser);
            profile.setNickName(trimToNull(request.getNickname()));
            profile.setAvatarIcon(trimToNull(request.getAvatarIcon()) != null ? request.getAvatarIcon().trim() : "avatar_boy_1");
            profile.setAnonymousModeEnabled(request.getAnonymousModeEnabled() != null ? request.getAnonymousModeEnabled() : true);
            profile.setRealFullName(trimToNull(request.getRealFullName()));
            profile.setDateOfBirth(request.getDateOfBirth());
            profile.setGender(trimToNull(request.getGender()));
            profile.setPhoneNumber(PatientProfileFieldValidator.normalizePhone(
                    request.getPhoneNumber(),
                    "Số điện thoại cá nhân",
                    false));
            profile.setEmergencyContactPhone(PatientProfileFieldValidator.normalizePhone(
                    request.getEmergencyContactPhone(),
                    "Số điện thoại người liên hệ khẩn cấp",
                    false));
            profile.setEducationLevel(PatientProfileFieldValidator.normalizeEducationLevel(request.getEducationLevel()));
            profile.setOccupation(trimToNull(request.getOccupation()));
            profile.setRelationshipStatus(PatientProfileFieldValidator.normalizeRelationshipStatus(request.getRelationshipStatus()));
            profile.setMedicalHistory(trimToNull(request.getMedicalHistory()));
            profile.setStatus(Status.STABLE);
            profile.setTaperingStage(TaperingStage.NONE);
            profile.setCurrentRiskScore(0);
            profile.setSafetyGateCompleted(profile.getRealFullName() != null && profile.getPhoneNumber() != null);
            profile.setMedicalProfileCompleted(
                    profile.getRealFullName() != null
                            && profile.getDateOfBirth() != null
                            && profile.getGender() != null
                            && profile.getPhoneNumber() != null
                            && profile.getEmergencyContactPhone() != null
                            && profile.getEducationLevel() != null
                            && profile.getOccupation() != null
                            && profile.getRelationshipStatus() != null
                            && profile.getMedicalHistory() != null);
            patientProfileRepository.save(profile);
        }

        return new UserDto(savedUser);
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        User entity = this.userRepository
                .findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy email"));

        if (Boolean.FALSE.equals(entity.getIsActive())) {
            throw new RuntimeException("Tài khoản đã bị khóa");
        }

        validatePasswordOrThrow(request, entity);

        if (entity.getRole() == Role.THERAPIST) {
            enforceTherapistNotRejected(entity);
        }

        return buildLoginResponse(entity);
    }

    private void validatePasswordOrThrow(LoginRequest request, User user) {
        if (passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            return;
        }

        if (request.getPassword() != null && request.getPassword().equals(user.getPasswordHash())) {
            return;
        }

        throw new RuntimeException("Sai mật khẩu");
    }

    private void enforceTherapistNotRejected(User user) {
        TherapistProfile profile = therapistProfileRepository
                .findById(user.getId())
                .orElseThrow(() -> new RuntimeException("Tài khoản bác sĩ chưa có hồ sơ"));

        ApprovalStatus approvalStatus = profile.getApprovalStatus();
        if (approvalStatus == ApprovalStatus.REJECTED) {
            throw new RuntimeException("Tài khoản bác sĩ đã bị từ chối duyệt. Vui lòng liên hệ quản trị viên.");
        }
    }

    @Override
    public LoginResponse registerAnonymous(String deviceId) {
        if (deviceId == null || deviceId.trim().isEmpty()) {
            throw new RuntimeException("Thiếu mã thiết bị để tạo phiên ẩn danh.");
        }

        String normalizedDeviceId = deviceId.trim();
        String guestPrefix = normalizedDeviceId.length() >= 4
                ? normalizedDeviceId.substring(0, 4)
                : normalizedDeviceId;
        String guestEmail = normalizedDeviceId + "@mindhealth.com";
        final boolean[] createdUser = { false };
        User entity = this.userRepository.findByEmail(guestEmail)
                .orElseGet(() -> {
                    User newGuest = new User();
                    newGuest.setEmail(guestEmail);
                    newGuest.setUsername("Guest_" + guestPrefix);
                    newGuest.setPasswordHash(passwordEncoder.encode(normalizedDeviceId));
                    newGuest.setRole(Role.GUEST);
                    newGuest.setIsAnonymous(false);
                    createdUser[0] = true;
                    return userRepository.save(newGuest);
                });

        boolean guestProfileCreated = false;
        if (!guestProfileRepository.existsById(entity.getId())) {
            GuestProfile guestProfile = new GuestProfile();
            guestProfile.setUser(entity);
            guestProfile.setNickname(entity.getUsername());
            guestProfile.setAvatarIcon("avatar_cat");
            guestProfile.setLsasDemoCompleted(false);
            guestProfileRepository.save(guestProfile);
            guestProfileCreated = true;
        }

        log.info(
                "Guest auth success deviceId={}, userId={}, createdUser={}, guestProfileCreated={}",
                normalizedDeviceId,
                entity.getId(),
                createdUser[0],
                guestProfileCreated);
        return buildLoginResponse(entity);
    }

    @Override
    public LoginResponse linkGuestAccount(GuestLinkAccountRequestDto request) {
        if (request.getGuestId() == null) {
            throw new IllegalArgumentException("Thiếu guestId.");
        }
        if (isBlank(request.getEmail())) {
            throw new IllegalArgumentException("Email là bắt buộc.");
        }
        if (isBlank(request.getPassword()) || request.getPassword().trim().length() < 6) {
            throw new IllegalArgumentException("Mật khẩu phải có ít nhất 6 ký tự.");
        }
        if (isBlank(request.getRealFullName())) {
            throw new IllegalArgumentException("Họ tên thật là bắt buộc.");
        }
        if (isBlank(request.getPhoneNumber())) {
            throw new IllegalArgumentException("Số điện thoại cá nhân là bắt buộc.");
        }

        User guestUser = userRepository.findById(request.getGuestId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy guest: " + request.getGuestId()));
        if (guestUser.getRole() != Role.GUEST) {
            throw new IllegalStateException("Tài khoản này không còn ở trạng thái guest.");
        }

        String normalizedEmail = request.getEmail().trim().toLowerCase();
        userRepository.findByEmail(normalizedEmail)
                .filter(existing -> !existing.getId().equals(guestUser.getId()))
                .ifPresent(existing -> {
                    throw new IllegalArgumentException("Email đã được sử dụng.");
                });

        GuestProfile guestProfile = guestProfileRepository.findById(guestUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ guest: " + guestUser.getId()));

        String desiredNickname = firstNonBlank(guestProfile.getNickname(), guestUser.getUsername(), normalizedEmail);
        String resolvedNickname = resolveAvailableNickname(desiredNickname, guestUser.getId());

        guestUser.setEmail(normalizedEmail);
        guestUser.setPasswordHash(passwordEncoder.encode(request.getPassword().trim()));
        guestUser.setRole(Role.PATIENT);
        guestUser.setIsAnonymous(false);
        guestUser.setUsername(resolvedNickname);
        userRepository.save(guestUser);

        PatientProfile patientProfile = patientProfileRepository.findById(guestUser.getId())
                .orElseGet(() -> {
                    PatientProfile profile = new PatientProfile();
                    profile.setUser(guestUser);
                    return profile;
                });
        patientProfile.setNickName(resolvedNickname);
        patientProfile.setAvatarIcon(firstNonBlank(guestProfile.getAvatarIcon(), "avatar_cat"));
        patientProfile.setAnonymousModeEnabled(true);
        patientProfile.setRealFullName(request.getRealFullName().trim());
        patientProfile.setPhoneNumber(PatientProfileFieldValidator.normalizePhone(
                request.getPhoneNumber(),
                "Số điện thoại cá nhân",
                true));
        patientProfile.setStatus(Status.STABLE);
        patientProfile.setTaperingStage(TaperingStage.NONE);
        patientProfile.setCurrentRiskScore(patientProfile.getCurrentRiskScore() != null ? patientProfile.getCurrentRiskScore() : 0);
        patientProfile.setSafetyGateCompleted(true);
        patientProfile.setMedicalProfileCompleted(false);
        patientProfile.setLsasDemoCompleted(Boolean.TRUE.equals(guestProfile.getLsasDemoCompleted()));
        patientProfileRepository.save(patientProfile);

        migratePendingLsasIfPresent(patientProfile, guestProfile);
        guestProfileRepository.delete(guestProfile);

        log.info("Guest converted to patient guestId={}, patientId={}, email={}",
                request.getGuestId(),
                patientProfile.getId(),
                normalizedEmail);
        return buildLoginResponse(guestUser);
    }

    @Override
    public LoginResponse refreshToken(RefreshTokenRequestDto request) {
        if (request == null || isBlank(request.getRefreshToken())) {
            throw new IllegalArgumentException("Thiếu refresh token.");
        }
        String refreshToken = request.getRefreshToken().trim();
        if (!jwtUtil.validateRefreshToken(refreshToken)) {
            throw new IllegalArgumentException("Refresh token không hợp lệ hoặc đã hết hạn.");
        }
        String email = jwtUtil.getEmailFromToken(refreshToken);
        User entity = userRepository.findByEmail(email)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy tài khoản."));
        if (Boolean.FALSE.equals(entity.getIsActive())) {
            throw new IllegalStateException("Tài khoản đã bị khóa.");
        }
        return buildLoginResponse(entity);
    }

    @Override
    public void requestPasswordReset(ForgotPasswordRequestDto request) {
        if (request == null || isBlank(request.getEmail())) {
            throw new IllegalArgumentException("Email là bắt buộc.");
        }
        String normalizedEmail = request.getEmail().trim().toLowerCase(Locale.ROOT);
        userRepository.findByEmail(normalizedEmail).ifPresent(user -> {
            String resetToken = generateResetToken();
            Date expiresAt = new Date(System.currentTimeMillis() + 15 * 60 * 1000L);
            user.setResetPasswordToken(resetToken);
            user.setResetPasswordExpiresAt(expiresAt);
            userRepository.save(user);
            passwordResetEmailService.sendResetPasswordEmail(normalizedEmail, resetToken, expiresAt);
            log.info("Password reset token generated email={}, expiresAt={}",
                    normalizedEmail,
                    expiresAt);
        });
    }

    @Override
    public void resetPassword(ResetPasswordRequestDto request) {
        if (request == null || isBlank(request.getResetToken())) {
            throw new IllegalArgumentException("Thiếu reset token.");
        }
        if (isBlank(request.getNewPassword()) || request.getNewPassword().trim().length() < 6) {
            throw new IllegalArgumentException("Mật khẩu mới phải có ít nhất 6 ký tự.");
        }
        User entity = userRepository.findAll().stream()
                .filter(user -> request.getResetToken().trim().equals(user.getResetPasswordToken()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Reset token không hợp lệ."));
        if (entity.getResetPasswordExpiresAt() == null
                || entity.getResetPasswordExpiresAt().before(new Date())) {
            throw new IllegalArgumentException("Reset token đã hết hạn.");
        }
        entity.setPasswordHash(passwordEncoder.encode(request.getNewPassword().trim()));
        entity.setResetPasswordToken(null);
        entity.setResetPasswordExpiresAt(null);
        userRepository.save(entity);
    }

    private void migratePendingLsasIfPresent(PatientProfile patientProfile, GuestProfile guestProfile) {
        if (guestProfile.getPendingLsasAnswersJson() == null || guestProfile.getPendingLsasAnswersJson().isBlank()) {
            return;
        }
        try {
            List<LsasAnswerRequestDto> answers = objectMapper.readValue(
                    guestProfile.getPendingLsasAnswersJson(),
                    new TypeReference<List<LsasAnswerRequestDto>>() {
                    });
            LsasSubmissionDto submissionDto = new LsasSubmissionDto();
            submissionDto.setPatientId(patientProfile.getId());
            submissionDto.setSubmissionType(LsasSubmissionType.BASELINE);
            submissionDto.setAnswers(answers);
            assessmentService.submitLsas(submissionDto);
        } catch (Exception exception) {
            throw new IllegalStateException("Không thể chuyển LSAS tạm của guest sang patient.", exception);
        }
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (!isBlank(value)) {
                return value.trim();
            }
        }
        return null;
    }

    private String resolveAvailableNickname(String preferredNickname, java.util.UUID currentUserId) {
        String baseNickname = firstNonBlank(preferredNickname, "khach_moi");
        String candidate = baseNickname;
        int suffix = 1;
        while (true) {
            PatientProfile existing = patientProfileRepository.findByNickName(candidate);
            if (existing == null || existing.getId().equals(currentUserId)) {
                return candidate;
            }
            suffix++;
            candidate = baseNickname + "_" + suffix;
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private LoginResponse buildLoginResponse(User entity) {
        String accessToken = jwtUtil.generateAccessToken(entity.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken(entity.getEmail());
        LoginResponse response = new LoginResponse();
        response.setUser(new UserDto(entity));
        response.setAccessToken(accessToken);
        response.setRefreshToken(refreshToken);
        response.setAccessTokenExpiresAt(jwtUtil.getAccessTokenExpiresAt());
        response.setRefreshTokenExpiresAt(jwtUtil.getRefreshTokenExpiresAt());
        response.setExpiresIn(jwtUtil.getAccessTokenExpiresIn());
        response.setRefreshExpiresIn(jwtUtil.getRefreshTokenExpiresIn());
        response.setToken(accessToken);
        return response;
    }

    private String generateResetToken() {
        long randomPart = ThreadLocalRandom.current().nextLong(100000, 999999);
        return "RST-" + randomPart + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(Locale.ROOT);
    }
}
