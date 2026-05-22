package com.reconnect.mindhealth.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.storage")
public class StorageProperties {

    /**
     * Root directory on the server filesystem to store uploaded files.
     * Default: "uploads" (relative to working directory).
     */
    private String uploadDir = "uploads";

    /**
     * Sub-directory for quest proof images, under uploadDir.
     */
    private String questProofDir = "proofs";

    public String getUploadDir() {
        return uploadDir;
    }

    public void setUploadDir(String uploadDir) {
        this.uploadDir = uploadDir;
    }

    public String getQuestProofDir() {
        return questProofDir;
    }

    public void setQuestProofDir(String questProofDir) {
        this.questProofDir = questProofDir;
    }
}

