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

    private Guide guide = new Guide();

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

    public Guide getGuide() {
        return guide;
    }

    public void setGuide(Guide guide) {
        this.guide = guide;
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

    public static class Guide {
        private boolean retrievalEnabled = true;
        private int topK = 4;
        private int minScore = 2;
        private int screenScopeWeight = 6;
        private int routeScopeWeight = 4;
        private int phaseScopeWeight = 2;
        private int topicWeight = 2;
        private int keywordWeight = 3;
        private int contentTermWeight = 1;

        public boolean isRetrievalEnabled() {
            return retrievalEnabled;
        }

        public void setRetrievalEnabled(boolean retrievalEnabled) {
            this.retrievalEnabled = retrievalEnabled;
        }

        public int getTopK() {
            return topK;
        }

        public void setTopK(int topK) {
            this.topK = topK;
        }

        public int getMinScore() {
            return minScore;
        }

        public void setMinScore(int minScore) {
            this.minScore = minScore;
        }

        public int getScreenScopeWeight() {
            return screenScopeWeight;
        }

        public void setScreenScopeWeight(int screenScopeWeight) {
            this.screenScopeWeight = screenScopeWeight;
        }

        public int getRouteScopeWeight() {
            return routeScopeWeight;
        }

        public void setRouteScopeWeight(int routeScopeWeight) {
            this.routeScopeWeight = routeScopeWeight;
        }

        public int getPhaseScopeWeight() {
            return phaseScopeWeight;
        }

        public void setPhaseScopeWeight(int phaseScopeWeight) {
            this.phaseScopeWeight = phaseScopeWeight;
        }

        public int getTopicWeight() {
            return topicWeight;
        }

        public void setTopicWeight(int topicWeight) {
            this.topicWeight = topicWeight;
        }

        public int getKeywordWeight() {
            return keywordWeight;
        }

        public void setKeywordWeight(int keywordWeight) {
            this.keywordWeight = keywordWeight;
        }

        public int getContentTermWeight() {
            return contentTermWeight;
        }

        public void setContentTermWeight(int contentTermWeight) {
            this.contentTermWeight = contentTermWeight;
        }
    }
}
