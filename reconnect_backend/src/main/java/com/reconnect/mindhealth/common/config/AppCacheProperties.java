package com.reconnect.mindhealth.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.cache")
public class AppCacheProperties {

    private boolean enabled = false;
    private long therapistDirectoryTtlMinutes = 10;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public long getTherapistDirectoryTtlMinutes() {
        return therapistDirectoryTtlMinutes;
    }

    public void setTherapistDirectoryTtlMinutes(long therapistDirectoryTtlMinutes) {
        this.therapistDirectoryTtlMinutes = therapistDirectoryTtlMinutes;
    }
}
