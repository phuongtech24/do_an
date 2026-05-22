package com.reconnect.mindhealth.modules.ai.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.ai")
public class AiProperties {

    /**
     * Master kill-switch. When disabled, AI calls are skipped and the system falls back to safe defaults.
     */
    private boolean enabled = false;

    private Gemini gemini = new Gemini();

    private Risk risk = new Risk();

    private Distortions distortions = new Distortions();

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public Gemini getGemini() {
        return gemini;
    }

    public void setGemini(Gemini gemini) {
        this.gemini = gemini;
    }

    public Risk getRisk() {
        return risk;
    }

    public void setRisk(Risk risk) {
        this.risk = risk;
    }

    public Distortions getDistortions() {
        return distortions;
    }

    public void setDistortions(Distortions distortions) {
        this.distortions = distortions;
    }

    public static class Gemini {
        /**
         * API key for Google Generative Language API.
         */
        private String apiKey;

        /**
         * Base URL (configurable to avoid hard-coding provider endpoints).
         */
        private String baseUrl = "https://generativelanguage.googleapis.com";

        /**
         * API version path segment.
         */
        private String apiVersion = "v1beta";

        /**
         * Model name, e.g. "gemini-1.5-flash".
         */
        private String model = "gemini-1.5-flash";

        /**
         * Request timeout in milliseconds.
         */
        private int timeoutMs = 8000;

        public String getApiKey() {
            return apiKey;
        }

        public void setApiKey(String apiKey) {
            this.apiKey = apiKey;
        }

        public String getBaseUrl() {
            return baseUrl;
        }

        public void setBaseUrl(String baseUrl) {
            this.baseUrl = baseUrl;
        }

        public String getApiVersion() {
            return apiVersion;
        }

        public void setApiVersion(String apiVersion) {
            this.apiVersion = apiVersion;
        }

        public String getModel() {
            return model;
        }

        public void setModel(String model) {
            this.model = model;
        }

        public int getTimeoutMs() {
            return timeoutMs;
        }

        public void setTimeoutMs(int timeoutMs) {
            this.timeoutMs = timeoutMs;
        }
    }

    public static class Risk {
        /**
         * If true, compute rule-based score first and only call AI when rule score reaches aiCallThreshold.
         */
        private boolean callAiOnlyWhenSuspicious = true;

        /**
         * Score threshold (0/70/100) at which we consider the content suspicious enough to call AI.
         */
        private int aiCallThreshold = 70;

        public boolean isCallAiOnlyWhenSuspicious() {
            return callAiOnlyWhenSuspicious;
        }

        public void setCallAiOnlyWhenSuspicious(boolean callAiOnlyWhenSuspicious) {
            this.callAiOnlyWhenSuspicious = callAiOnlyWhenSuspicious;
        }

        public int getAiCallThreshold() {
            return aiCallThreshold;
        }

        public void setAiCallThreshold(int aiCallThreshold) {
            this.aiCallThreshold = aiCallThreshold;
        }
    }

    public static class Distortions {
        /**
         * If true, try rule-based detector first and only call AI when we already have suspicious signals.
         */
        private boolean callAiOnlyWhenSuspicious = true;

        /**
         * Maximum number of distortion labels to return (UI requirement: 1-3).
         */
        private int maxSuggestions = 3;

        public boolean isCallAiOnlyWhenSuspicious() {
            return callAiOnlyWhenSuspicious;
        }

        public void setCallAiOnlyWhenSuspicious(boolean callAiOnlyWhenSuspicious) {
            this.callAiOnlyWhenSuspicious = callAiOnlyWhenSuspicious;
        }

        public int getMaxSuggestions() {
            return maxSuggestions;
        }

        public void setMaxSuggestions(int maxSuggestions) {
            this.maxSuggestions = maxSuggestions;
        }
    }
}
