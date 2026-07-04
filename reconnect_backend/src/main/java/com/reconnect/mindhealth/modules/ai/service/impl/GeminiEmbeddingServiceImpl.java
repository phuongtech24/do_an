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
            String modelName = rag.getEmbeddingModel();
            String url = String.format("%s/%s/models/%s:embedContent?key=%s",
                    gemini.getBaseUrl(),
                    gemini.getApiVersion(),
                    modelName,
                    gemini.getApiKey());

            Map<String, Object> body = Map.of(
                    "model", "models/" + modelName,
                    "content", Map.of(
                            "parts", List.of(Map.of("text", text))));

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofMillis(gemini.getTimeoutMs()))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body)))
                    .build();

            HttpResponse<String> response = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                log.warn("Gemini embedding failed status={}", response.statusCode());
                return List.of();
            }

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode values = root.path("embedding").path("values");
            if (!values.isArray() || values.isEmpty()) {
                return List.of();
            }

            List<Double> vector = new java.util.ArrayList<>();
            for (JsonNode node : values) {
                vector.add(node.asDouble());
            }
            return vector;
        } catch (Exception exception) {
            log.warn("Gemini embedding call failed: {}", exception.getMessage());
            return List.of();
        }
    }
}
