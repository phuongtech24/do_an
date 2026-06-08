package com.reconnect.mindhealth.modules.auth.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.reconnect.mindhealth.common.util.JwtUtil;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
import com.reconnect.mindhealth.modules.auth.dto.RegisterRequest;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.auth.service.IAuthService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.annotation.Resource;
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

    @Autowired
    private JwtUtil jwtUtil;

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
            profile.setPhoneNumber(trimToNull(request.getPhoneNumber()));
            profile.setEmergencyContactPhone(trimToNull(request.getEmergencyContactPhone()));
            profile.setEducationLevel(trimToNull(request.getEducationLevel()));
            profile.setOccupation(trimToNull(request.getOccupation()));
            profile.setRelationshipStatus(trimToNull(request.getRelationshipStatus()));
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

        String token = this.jwtUtil.generateToken(entity.getEmail());
        return new LoginResponse(new UserDto(entity), token);
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
                .orElseThrow(() -> new RuntimeException("Tài khoản therapist chưa có profile"));

        ApprovalStatus approvalStatus = profile.getApprovalStatus();
        if (approvalStatus == ApprovalStatus.REJECTED) {
            throw new RuntimeException("Tài khoản therapist đã bị từ chối duyệt. Vui lòng liên hệ admin.");
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
                    newGuest.setRole(Role.PATIENT);
                    newGuest.setIsAnonymous(true);
                    createdUser[0] = true;
                    return userRepository.save(newGuest);
                });

        boolean patientProfileCreated = false;
        if (!patientProfileRepository.existsById(entity.getId())) {
            PatientProfile profile = new PatientProfile();
            profile.setUser(entity);
            profile.setNickName(entity.getUsername());
            profile.setAvatarIcon("avatar_boy_1");
            profile.setAnonymousModeEnabled(true);
            profile.setStatus(Status.STABLE);
            profile.setTaperingStage(TaperingStage.NONE);
            profile.setCurrentRiskScore(0);
            profile.setLsasDemoCompleted(false);
            profile.setSafetyGateCompleted(false);
            profile.setMedicalProfileCompleted(false);
            patientProfileRepository.save(profile);
            patientProfileCreated = true;
        }

        String token = this.jwtUtil.generateToken(entity.getEmail());
        log.info(
                "Anonymous auth success deviceId={}, userId={}, createdUser={}, patientProfileCreated={}",
                normalizedDeviceId,
                entity.getId(),
                createdUser[0],
                patientProfileCreated);
        return new LoginResponse(new UserDto(entity), token);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
