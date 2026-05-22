package com.reconnect.mindhealth.modules.clinical.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistCredential;

public class TherapistCredentialDto {

    private UUID id;
    private String fileName;
    private String mimeType;
    private Long sizeBytes;
    private LocalDateTime uploadedAt;

    public TherapistCredentialDto() {
    }

    public TherapistCredentialDto(TherapistCredential entity) {
        if (entity != null) {
            this.id = entity.getId();
            this.fileName = entity.getFileName();
            this.mimeType = entity.getMimeType();
            this.sizeBytes = entity.getSizeBytes();
            this.uploadedAt = entity.getUploadedAt();
        }
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public Long getSizeBytes() {
        return sizeBytes;
    }

    public void setSizeBytes(Long sizeBytes) {
        this.sizeBytes = sizeBytes;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(LocalDateTime uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
}

