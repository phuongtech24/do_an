package com.reconnect.mindhealth.modules.ai.service.impl;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.service.IEmbeddingService;

@Service
public class GeminiEmbeddingServiceImpl implements IEmbeddingService {

    private static final Logger log = LoggerFactory.getLogger(GeminiEmbeddingServiceImpl.class);

    private final AiProperties aiProperties;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public GeminiEmbeddingServiceImpl(AiProperties aiProperties) {
        this.aiProperties = aiProperties;
    }

    @Override
    public List<Double> embed(String text) {
        AiProperties.Rag rag = aiProperties.getRag();
        AiProperties.Gemini gemini = aiProperties.getGemini();
        if (!rag.isEnabled() || gemini.getApiKey() == null || gemini.getApiKey().isBlank()) {
            return List.of();
        }
        try {
            String modelName = resolveEmbeddingModel(rag.getEmbeddingModel());
            String url = String.format("%s/%s/models/%s:embedContent?key=%s",
                    gemini.getBaseUrl(),
                    gemini.getApiVersion(),
                    modelName,
                    gemini.getApiKey());

            HttpResponse<String> lastResponse = null;
            for (Map<String, Object> body : buildEmbeddingRequestBodies(modelName, text, rag.getVectorSize())) {
                HttpRequest req = HttpRequest.newBuilder()
                        .uri(URI.create(url))
                        .timeout(Duration.ofMillis(gemini.getTimeoutMs()))
                        .header("Content-Type", "application/json")
                        .header("x-goog-api-key", gemini.getApiKey())
                        .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body)))
                        .build();

                HttpResponse<String> response = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
                lastResponse = response;
                if (response.statusCode() < 200 || response.statusCode() >= 300) {
                    continue;
                }

                JsonNode root = objectMapper.readTree(response.body());
                JsonNode values = extractEmbeddingValues(root);
                if (values == null || !values.isArray() || values.isEmpty()) {
                    continue;
                }

                List<Double> vector = new java.util.ArrayList<>();
                for (JsonNode node : values) {
                    vector.add(node.asDouble());
                }
                return vector;
            }

            if (lastResponse != null) {
                log.warn("Gemini embedding failed model={} status={} body={}",
                        modelName,
                        lastResponse.statusCode(),
                        safeSnippet(lastResponse.body(), 500));
            }
            return List.of();
        } catch (Exception exception) {
            log.warn("Gemini embedding call failed: {}", exception.getMessage());
            return List.of();
        }
    }

    private String resolveEmbeddingModel(String configuredModel) {
        if (configuredModel == null || configuredModel.isBlank()) {
            return "gemini-embedding-2";
        }
        if ("text-embedding-004".equalsIgnoreCase(configuredModel.trim())) {
            return "gemini-embedding-2";
        }
        return configuredModel.trim();
    }

    private List<Map<String, Object>> buildEmbeddingRequestBodies(String modelName, String text, int vectorSize) {
        String safeText = text == null ? "" : text;
        Map<String, Object> content = Map.of("parts", List.of(Map.of("text", safeText)));

        List<Map<String, Object>> bodies = new java.util.ArrayList<>();

        Map<String, Object> primary = new java.util.HashMap<>();
        primary.put("content", content);
        primary.put("outputDimensionality", vectorSize);
        if ("gemini-embedding-001".equalsIgnoreCase(modelName)) {
            primary.put("taskType", "RETRIEVAL_DOCUMENT");
            primary.put("model", "models/" + modelName);
        }
        bodies.add(primary);

        Map<String, Object> snakeCaseVariant = new java.util.HashMap<>();
        snakeCaseVariant.put("content", content);
        snakeCaseVariant.put("output_dimensionality", vectorSize);
        if ("gemini-embedding-001".equalsIgnoreCase(modelName)) {
            snakeCaseVariant.put("taskType", "RETRIEVAL_DOCUMENT");
            snakeCaseVariant.put("model", "models/" + modelName);
        }
        bodies.add(snakeCaseVariant);

        Map<String, Object> minimal = new java.util.HashMap<>();
        minimal.put("content", content);
        if ("gemini-embedding-001".equalsIgnoreCase(modelName)) {
            minimal.put("taskType", "RETRIEVAL_DOCUMENT");
            minimal.put("model", "models/" + modelName);
        }
        bodies.add(minimal);

        return bodies;
    }

    private JsonNode extractEmbeddingValues(JsonNode root) {
        JsonNode direct = root.path("embedding").path("values");
        if (direct.isArray() && !direct.isEmpty()) {
            return direct;
        }

        JsonNode embeddings = root.path("embeddings");
        if (embeddings.isArray() && !embeddings.isEmpty()) {
            JsonNode first = embeddings.get(0).path("values");
            if (first.isArray() && !first.isEmpty()) {
                return first;
            }
        }
        return null;
    }

    private String safeSnippet(String text, int maxLength) {
        if (text == null) {
            return "";
        }
        String normalized = text.replaceAll("\\s+", " ").trim();
        if (normalized.length() > maxLength) {
            return normalized.substring(0, maxLength) + "...";
        }
        return normalized;
    }
}
