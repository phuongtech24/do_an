package com.reconnect.mindhealth.modules.guest.service;

import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.guest.dto.GuestProfileDto;
import com.reconnect.mindhealth.modules.guest.dto.GuestProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.guest.entity.GuestProfile;
import com.reconnect.mindhealth.modules.guest.repository.GuestProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class GuestProfileSelfService {

    private final GuestProfileRepository guestProfileRepository;
    private final UserRepository userRepository;

    public GuestProfileSelfService(GuestProfileRepository guestProfileRepository, UserRepository userRepository) {
        this.guestProfileRepository = guestProfileRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public GuestProfileDto getProfile(UUID guestId) {
        return new GuestProfileDto(load(guestId));
    }

    @Transactional
    public GuestProfileDto updateProfile(GuestProfileUpdateRequestDto request) {
        GuestProfile guestProfile = load(request.getGuestId());
        if (request.getNickname() != null && !request.getNickname().trim().isEmpty()) {
            guestProfile.setNickname(request.getNickname().trim());
        }
        if (request.getAvatarIcon() != null && !request.getAvatarIcon().trim().isEmpty()) {
            guestProfile.setAvatarIcon(request.getAvatarIcon().trim());
        }
        return new GuestProfileDto(guestProfileRepository.save(guestProfile));
    }

    private GuestProfile load(UUID guestId) {
        if (guestId == null) {
            throw new IllegalArgumentException("Thiếu guestId.");
        }
        GuestProfile guestProfile = guestProfileRepository.findById(guestId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ guest: " + guestId));
        userRepository.findById(guestId)
                .filter(user -> user.getRole() == Role.GUEST)
                .orElseThrow(() -> new IllegalStateException("Tài khoản này không còn ở trạng thái guest."));
        return guestProfile;
    }
}
