package com.reconnect.mindhealth.modules.clinical.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.reconnect.mindhealth.common.config.StorageProperties;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistProfileStatusDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistCredential;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistCredentialRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class TherapistCredentialService {

    private static final Logger log = LoggerFactory.getLogger(TherapistCredentialService.class);

    private static final long MAX_SIZE_BYTES = 5L * 1024 * 1024;
    private static final Set<String> ALLOWED_MIME = Set.of(
            "application/pdf",
            "image/jpeg",
            "image/png");

    private final AuthContextService authContextService;
    private final StorageProperties storageProperties;
    private final TherapistProfileRepository therapistProfileRepository;
    private final TherapistCredentialRepository therapistCredentialRepository;

    public TherapistCredentialService(
            AuthContextService authContextService,
            StorageProperties storageProperties,
            TherapistProfileRepository therapistProfileRepository,
            TherapistCredentialRepository therapistCredentialRepository) {
        this.authContextService = authContextService;
        this.storageProperties = storageProperties;
        this.therapistProfileRepository = therapistProfileRepository;
        this.therapistCredentialRepository = therapistCredentialRepository;
    }

    @Transactional(readOnly = true)
    public List<TherapistCredential> listMyCredentials() {
        TherapistProfile therapist = requireTherapistProfileForCurrentUser();
        return therapistCredentialRepository.findByTherapistProfile_IdOrderByUploadedAtDesc(therapist.getId());
    }

    @Transactional
    public TherapistCredential uploadMyCredential(MultipartFile file) {
        TherapistProfile therapist = requireTherapistProfileForCurrentUser();
        validateFileOrThrow(file);

        log.info("TherapistCredential upload start: therapistId={}, originalName={}, sizeBytes={}, contentType={}",
                therapist.getId(),
                file.getOriginalFilename(),
                file.getSize(),
                file.getContentType());

        String original = file.getOriginalFilename() != null ? file.getOriginalFilename().trim() : "credential";
        String safeName = sanitizeFileName(original);
        String ext = "";
        int dot = safeName.lastIndexOf('.');
        if (dot > 0) {
            ext = safeName.substring(dot);
            safeName = safeName.substring(0, dot);
        }

        String finalName = safeName + "_" + UUID.randomUUID() + ext;
        String relPath = "therapist-credentials/" + therapist.getId() + "/" + finalName;
        Path abs = resolveUnderUploadRoot(relPath);

        try {
            Files.createDirectories(abs.getParent());
            Files.write(abs, file.getBytes());
        } catch (IOException e) {
            log.warn("TherapistCredential upload failed: therapistId={}, relPath={}, err={}",
                    therapist.getId(), relPath, e.getMessage());
            throw new RuntimeException("Không thể lưu file chứng chỉ: " + e.getMessage());
        }

        TherapistCredential c = new TherapistCredential();
        c.setTherapistProfile(therapist);
        c.setFileName(original);
        c.setMimeType(file.getContentType() != null ? file.getContentType() : MediaType.APPLICATION_OCTET_STREAM_VALUE);
        c.setSizeBytes(file.getSize());
        c.setStoragePath(relPath);
        c.setUploadedAt(LocalDateTime.now());
        TherapistCredential saved = therapistCredentialRepository.save(c);

        log.info("TherapistCredential upload success: therapistId={}, credentialId={}, relPath={}",
                therapist.getId(), saved.getId(), relPath);

        return saved;
    }

    @Transactional(readOnly = true)
    public Resource downloadMyCredential(UUID credentialId) {
        TherapistProfile therapist = requireTherapistProfileForCurrentUser();
        TherapistCredential c = therapistCredentialRepository.findById(credentialId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy chứng chỉ: " + credentialId));
        if (c.getTherapistProfile() == null || c.getTherapistProfile().getId() == null
                || !c.getTherapistProfile().getId().equals(therapist.getId())) {
            throw new SecurityException("Forbidden");
        }
        return new FileSystemResource(resolveUnderUploadRoot(c.getStoragePath()));
    }

    @Transactional
    public void deleteMyCredential(UUID credentialId) {
        TherapistProfile therapist = requireTherapistProfileForCurrentUser();
        TherapistCredential c = therapistCredentialRepository.findById(credentialId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy chứng chỉ: " + credentialId));
        if (c.getTherapistProfile() == null || c.getTherapistProfile().getId() == null
                || !c.getTherapistProfile().getId().equals(therapist.getId())) {
            throw new SecurityException("Forbidden");
        }

        String storagePath = c.getStoragePath();
        therapistCredentialRepository.delete(c);
        try {
            Files.deleteIfExists(resolveUnderUploadRoot(storagePath));
        } catch (Exception e) {
            log.warn("TherapistCredential physical delete failed: therapistId={}, credentialId={}, path={}, err={}",
                    therapist.getId(), credentialId, storagePath, e.toString());
        }
        log.info("TherapistCredential deleted: therapistId={}, credentialId={}", therapist.getId(), credentialId);
    }

    @Transactional(readOnly = true)
    public List<TherapistCredential> listCredentialsForAdmin(UUID therapistId) {
        requireAdmin();
        return therapistCredentialRepository.findByTherapistProfile_IdOrderByUploadedAtDesc(therapistId);
    }

    @Transactional(readOnly = true)
    public Resource downloadCredentialForAdmin(UUID therapistId, UUID credentialId) {
        requireAdmin();
        TherapistCredential c = therapistCredentialRepository.findById(credentialId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy chứng chỉ: " + credentialId));
        if (c.getTherapistProfile() == null || c.getTherapistProfile().getId() == null
                || !c.getTherapistProfile().getId().equals(therapistId)) {
            throw new SecurityException("Forbidden");
        }
        return new FileSystemResource(resolveUnderUploadRoot(c.getStoragePath()));
    }

    @Transactional(readOnly = true)
    public long countCredentials(UUID therapistId) {
        return therapistCredentialRepository.countByTherapistProfile_Id(therapistId);
    }

    @Transactional(readOnly = true)
    public TherapistProfileStatusDto getMyStatus() {
        TherapistProfile therapist = requireTherapistProfileForCurrentUser();
        long count = therapistCredentialRepository.countByTherapistProfile_Id(therapist.getId());
        return new TherapistProfileStatusDto(therapist.getApprovalStatus(), count);
    }

    private void requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Forbidden: ADMIN role required.");
        }
    }

    private TherapistProfile requireTherapistProfileForCurrentUser() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.THERAPIST) {
            throw new SecurityException("Forbidden: THERAPIST role required.");
        }
        return therapistProfileRepository.findById(current.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy therapist profile"));
    }

    private void validateFileOrThrow(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File trống hoặc không hợp lệ.");
        }
        if (file.getSize() > MAX_SIZE_BYTES) {
            throw new IllegalArgumentException("File vượt quá 5MB.");
        }
        String mime = file.getContentType();
        if (mime == null || !ALLOWED_MIME.contains(mime)) {
            throw new IllegalArgumentException("Định dạng không hợp lệ. Chỉ cho phép PDF/JPG/PNG.");
        }
    }

    private Path resolveUnderUploadRoot(String relPath) {
        Path root = Paths.get(storageProperties.getUploadDir()).toAbsolutePath().normalize();
        Path abs = root.resolve(relPath).normalize();
        if (!abs.startsWith(root)) {
            throw new SecurityException("Invalid path.");
        }
        return abs;
    }

    private String sanitizeFileName(String name) {
        String n = name.replace("\\", "/");
        n = n.substring(n.lastIndexOf('/') + 1);
        return n.replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}
