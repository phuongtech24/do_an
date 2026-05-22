package com.reconnect.mindhealth.modules.auth.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.reconnect.mindhealth.common.util.JwtUtil;
import com.reconnect.mindhealth.modules.auth.dto.LoginRequest;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.auth.service.IAuthService;
import com.reconnect.mindhealth.modules.auth.dto.LoginResponse;
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
    public UserDto register(String email, String password, String role, Boolean isAnonymous, String nickname, String avatarIcon) {
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email đã được sử dụng!");
        }

        // Validation cho trường hợp ẩn danh (theo đặc tả Module 1)
        if (Boolean.TRUE.equals(isAnonymous)) {
            if (nickname == null || nickname.trim().isEmpty()) {
                throw new RuntimeException("Đăng ký ẩn danh bắt buộc phải có Nickname!");
            }
            if (avatarIcon == null || avatarIcon.trim().isEmpty()) {
                throw new RuntimeException("Đăng ký ẩn danh bắt buộc phải có Avatar!");
            }
        }

        String encodedPassword = passwordEncoder.encode(password);
        User entity = new User();
        entity.setEmail(email);
        entity.setUsername(nickname != null ? nickname : email.split("@")[0]);
        entity.setPasswordHash(encodedPassword);
        entity.setRole(Role.valueOf(role));
        entity.setIsAnonymous(isAnonymous != null ? isAnonymous : false);
        
        User savedUser = this.userRepository.save(entity);

        // Nếu là bệnh nhân, tự động tạo Profile
        if (entity.getRole() == Role.PATIENT) {
            PatientProfile profile = new PatientProfile();
            profile.setUser(savedUser);
            profile.setNickName(nickname);
            profile.setAvatarIcon(avatarIcon);
            profile.setStatus(Status.STABLE); // Mặc định
            profile.setTaperingStage(TaperingStage.NONE);
            profile.setCurrentRiskScore(0);
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
            enforceTherapistApproved(entity);
        }

        String token = this.jwtUtil.generateToken(entity.getEmail());
        return new LoginResponse(new UserDto(entity), token);
    }

    private void validatePasswordOrThrow(LoginRequest request, User user) {
        if (passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            return;
        }

        // Fallback cho mật khẩu dạng thô chưa mã hóa (dữ liệu seed từ CSV)
        if (request.getPassword() != null && request.getPassword().equals(user.getPasswordHash())) {
            return;
        }

        throw new RuntimeException("Sai mật khẩu");
    }

    private void enforceTherapistApproved(User user) {
        TherapistProfile profile = therapistProfileRepository
            .findById(user.getId())
            .orElseThrow(() -> new RuntimeException("Tài khoản therapist chưa có profile"));

        ApprovalStatus approvalStatus = profile.getApprovalStatus();
        if (approvalStatus == ApprovalStatus.ACTIVE) {
            return;
        }

        if (approvalStatus == ApprovalStatus.PENDING) {
            throw new RuntimeException("Tài khoản therapist đang chờ duyệt. Vui lòng thử lại sau.");
        }

        if (approvalStatus == ApprovalStatus.REJECTED) {
            throw new RuntimeException("Tài khoản therapist đã bị từ chối duyệt. Vui lòng liên hệ admin.");
        }

        throw new RuntimeException("Tài khoản therapist chưa được duyệt.");
    }

    @Override
    public LoginResponse registerAnonymous(String deviceId) {
        String guestEmail = deviceId + "@mindhealth.com";
        User entity = this.userRepository.findByEmail(guestEmail)
                                        .orElseGet(() -> {
                                            User newGuest = new User();
                                            newGuest.setEmail(guestEmail);
                                            newGuest.setUsername("Guest_" + deviceId.substring(0, 4));
                                            newGuest.setPasswordHash(passwordEncoder.encode(deviceId)); // Dùng chính deviceId làm pass ẩn
                                            newGuest.setRole(Role.PATIENT);
                                            newGuest.setIsAnonymous(true);
                                            return userRepository.save(newGuest);
                                        });

        // Tự động tạo PatientProfile cho khách ẩn danh nếu chưa tồn tại
        if (!patientProfileRepository.existsById(entity.getId())) {
            PatientProfile profile = new PatientProfile();
            profile.setUser(entity);
            profile.setNickName(entity.getUsername());
            profile.setAvatarIcon("avatar_boy_1"); // Default icon
            profile.setStatus(Status.STABLE); // Mặc định
            profile.setTaperingStage(TaperingStage.NONE);
            profile.setCurrentRiskScore(0);
            patientProfileRepository.save(profile);
        }

        String token = this.jwtUtil.generateToken(entity.getEmail());
        return new LoginResponse(new UserDto(entity), token);
    }
    
}
