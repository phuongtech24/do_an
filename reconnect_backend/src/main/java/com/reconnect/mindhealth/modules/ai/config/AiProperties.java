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

    private Rag rag = new Rag();

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

    public Rag getRag() {
        return rag;
    }

    public void setRag(Rag rag) {
        this.rag = rag;
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
         * Model name, e.g. "gemini-2.5-flash".
         */
        private String model = "gemini-2.5-flash";

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

    public static class Rag {
        private boolean enabled = false;
        private boolean autoIngestOnStartup = false;
        private String qdrantScheme = "http";
        private String qdrantHost = "localhost";
        private int qdrantPort = 6333;
        private String qdrantCollection = "mindhealth_ai_knowledge";
        private String qdrantApiKey = "";
        private String embeddingModel = "text-embedding-004";
        private int vectorSize = 768;
        private int topK = 4;
        private int candidateLimit = 12;
        private double minScore = 0.25d;
        private int chunkSize = 600;
        private int chunkOverlap = 80;

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public boolean isAutoIngestOnStartup() {
            return autoIngestOnStartup;
        }

        public void setAutoIngestOnStartup(boolean autoIngestOnStartup) {
            this.autoIngestOnStartup = autoIngestOnStartup;
        }

        public String getQdrantHost() {
            return qdrantHost;
        }

        public String getQdrantScheme() {
            return qdrantScheme;
        }

        public void setQdrantScheme(String qdrantScheme) {
            this.qdrantScheme = qdrantScheme;
        }

        public void setQdrantHost(String qdrantHost) {
            this.qdrantHost = qdrantHost;
        }

        public int getQdrantPort() {
            return qdrantPort;
        }

        public void setQdrantPort(int qdrantPort) {
            this.qdrantPort = qdrantPort;
        }

        public String getQdrantCollection() {
            return qdrantCollection;
        }

        public void setQdrantCollection(String qdrantCollection) {
            this.qdrantCollection = qdrantCollection;
        }

        public String getQdrantApiKey() {
            return qdrantApiKey;
        }

        public void setQdrantApiKey(String qdrantApiKey) {
            this.qdrantApiKey = qdrantApiKey;
        }

        public String getEmbeddingModel() {
            return embeddingModel;
        }

        public void setEmbeddingModel(String embeddingModel) {
            this.embeddingModel = embeddingModel;
        }

        public int getVectorSize() {
            return vectorSize;
        }

        public void setVectorSize(int vectorSize) {
            this.vectorSize = vectorSize;
        }

        public int getTopK() {
            return topK;
        }

        public void setTopK(int topK) {
            this.topK = topK;
        }

        public int getCandidateLimit() {
            return candidateLimit;
        }

        public void setCandidateLimit(int candidateLimit) {
            this.candidateLimit = candidateLimit;
        }

        public double getMinScore() {
            return minScore;
        }

        public void setMinScore(double minScore) {
            this.minScore = minScore;
        }

        public int getChunkSize() {
            return chunkSize;
        }

        public void setChunkSize(int chunkSize) {
            this.chunkSize = chunkSize;
        }

        public int getChunkOverlap() {
            return chunkOverlap;
        }

        public void setChunkOverlap(int chunkOverlap) {
            this.chunkOverlap = chunkOverlap;
        }
    }
}
