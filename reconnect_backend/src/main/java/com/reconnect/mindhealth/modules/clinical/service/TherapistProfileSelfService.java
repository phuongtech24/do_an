package com.reconnect.mindhealth.modules.clinical.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Year;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.reconnect.mindhealth.common.config.StorageProperties;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.clinical.dto.AdminTherapistUpdateRequestDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class TherapistProfileSelfService {

    private static final long MAX_AVATAR_SIZE_BYTES = 2L * 1024 * 1024;
    private static final Set<String> ALLOWED_AVATAR_MIME = Set.of("image/jpeg", "image/png", "image/webp");

    private final AuthContextService authContextService;
    private final StorageProperties storageProperties;
    private final TherapistProfileRepository therapistProfileRepository;
    private final AppointmentRepository appointmentRepository;
    private final TherapistDirectoryCacheService therapistDirectoryCacheService;

    public TherapistProfileSelfService(
            AuthContextService authContextService,
            StorageProperties storageProperties,
            TherapistProfileRepository therapistProfileRepository,
            AppointmentRepository appointmentRepository,
            TherapistDirectoryCacheService therapistDirectoryCacheService) {
        this.authContextService = authContextService;
        this.storageProperties = storageProperties;
        this.therapistProfileRepository = therapistProfileRepository;
        this.appointmentRepository = appointmentRepository;
        this.therapistDirectoryCacheService = therapistDirectoryCacheService;
    }

    @Transactional(readOnly = true)
    public TherapistProfile getMyProfile() {
        User current = requireTherapist();
        return therapistProfileRepository.findById(current.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ chuyên gia."));
    }

    @Transactional
    public TherapistProfile updateMyProfile(AdminTherapistUpdateRequestDto request) {
        if (request == null) {
            throw new IllegalArgumentException("Thiếu payload cập nhật hồ sơ.");
        }

        User current = requireTherapist();
        TherapistProfile profile = therapistProfileRepository.findById(current.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ chuyên gia."));

        if (request.getFullName() != null && !request.getFullName().trim().isEmpty()) {
            profile.setFullName(request.getFullName().trim());
        }
        if (request.getPhoneNumber() != null) {
            if (request.getPhoneNumber().trim().isEmpty()) {
                throw new IllegalArgumentException("Số điện thoại không được để trống.");
            }
            profile.setPhoneNumber(request.getPhoneNumber().trim());
        }
        if (request.getHometown() != null) {
            profile.setHometown(blankToNull(request.getHometown()));
        }
        if (request.getBirthYear() != null) {
            validateBirthYear(request.getBirthYear());
            profile.setBirthYear(request.getBirthYear());
        }
        if (request.getVoiceDescription() != null) {
            profile.setVoiceDescription(blankToNull(request.getVoiceDescription()));
        }
        if (request.getSpecialization() != null) {
            profile.setSpecialization(blankToNull(request.getSpecialization()));
        }
        if (request.getTherapyStyle() != null) {
            profile.setTherapyStyle(blankToNull(request.getTherapyStyle()));
        }
        if (request.getBio() != null) {
            profile.setBio(blankToNull(request.getBio()));
        }
        if (request.getMeetingLink() != null) {
            String link = blankToNull(request.getMeetingLink());
            validateMeetingLink(link);
            profile.setMeetingLink(link);
        }

        TherapistProfile saved = therapistProfileRepository.save(profile);
        if (saved.getMeetingLink() != null && !saved.getMeetingLink().isBlank()) {
            appointmentRepository.backfillMissingMeetingLink(saved.getId(), saved.getMeetingLink());
        }
        therapistDirectoryCacheService.evictAll();
        return saved;
    }

    @Transactional
    public TherapistProfile uploadMyAvatar(MultipartFile file) {
        validateAvatarFile(file);
        User current = requireTherapist();
        TherapistProfile profile = therapistProfileRepository.findById(current.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ chuyên gia."));

        String original = file.getOriginalFilename() != null ? file.getOriginalFilename().trim() : "avatar";
        String safeName = sanitizeFileName(original);
        String ext = "";
        int dot = safeName.lastIndexOf('.');
        if (dot > 0) {
            ext = safeName.substring(dot);
            safeName = safeName.substring(0, dot);
        }

        String finalName = safeName + "_" + UUID.randomUUID() + ext;
        String relPath = "therapist-avatars/" + profile.getId() + "/" + finalName;
        Path abs = resolveUnderUploadRoot(relPath);

        try {
            Files.createDirectories(abs.getParent());
            Files.write(abs, file.getBytes());
        } catch (IOException e) {
            throw new RuntimeException("Không thể lưu ảnh đại diện: " + e.getMessage());
        }

        String oldAvatarUrl = profile.getAvatarUrl();
        profile.setAvatarUrl("/uploads/" + relPath);
        TherapistProfile saved = therapistProfileRepository.save(profile);
        deleteOldAvatarIfPossible(oldAvatarUrl, saved.getAvatarUrl());
        therapistDirectoryCacheService.evictAll();
        return saved;
    }

    private User requireTherapist() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.THERAPIST) {
            throw new SecurityException("Chỉ tài khoản bác sĩ/chuyên gia mới được cập nhật hồ sơ này.");
        }
        return current;
    }

    private String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void validateMeetingLink(String link) {
        if (link == null) {
            return;
        }
        if (!link.startsWith("https://") && !link.startsWith("http://")) {
            throw new IllegalArgumentException("Link tư vấn phải bắt đầu bằng http:// hoặc https://.");
        }
    }

    private void validateBirthYear(Integer birthYear) {
        if (birthYear == null) {
            return;
        }
        int currentYear = Year.now().getValue();
        if (birthYear < 1950 || birthYear > currentYear) {
            throw new IllegalArgumentException("Năm sinh không hợp lệ.");
        }
    }

    private void validateAvatarFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File ảnh trống hoặc không hợp lệ.");
        }
        if (file.getSize() > MAX_AVATAR_SIZE_BYTES) {
            throw new IllegalArgumentException("Ảnh đại diện vượt quá 2MB.");
        }
        String mime = file.getContentType();
        if (mime == null || !ALLOWED_AVATAR_MIME.contains(mime)) {
            throw new IllegalArgumentException("Định dạng ảnh không hợp lệ. Chỉ cho phép JPG/PNG/WebP.");
        }
    }

    private Path resolveUnderUploadRoot(String relPath) {
        Path root = Paths.get(storageProperties.getUploadDir()).toAbsolutePath().normalize();
        Path abs = root.resolve(relPath).normalize();
        if (!abs.startsWith(root)) {
            throw new SecurityException("Đường dẫn upload không hợp lệ.");
        }
        return abs;
    }

    private String sanitizeFileName(String name) {
        String normalized = name.replace("\\", "/");
        normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
        return normalized.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    private void deleteOldAvatarIfPossible(String oldAvatarUrl, String newAvatarUrl) {
        if (oldAvatarUrl == null || oldAvatarUrl.isBlank() || oldAvatarUrl.equals(newAvatarUrl)) {
            return;
        }
        if (!oldAvatarUrl.startsWith("/uploads/therapist-avatars/")) {
            return;
        }
        String relPath = oldAvatarUrl.substring("/uploads/".length());
        try {
            Files.deleteIfExists(resolveUnderUploadRoot(relPath));
        } catch (Exception ignored) {
        }
    }
}
