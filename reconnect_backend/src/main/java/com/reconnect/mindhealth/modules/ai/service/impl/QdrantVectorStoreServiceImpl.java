package com.reconnect.mindhealth.modules.ai.service.impl;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.model.VectorDocumentChunk;
import com.reconnect.mindhealth.modules.ai.model.VectorSearchResult;
import com.reconnect.mindhealth.modules.ai.service.IVectorStoreService;

@Service
public class QdrantVectorStoreServiceImpl implements IVectorStoreService {

    private static final Logger log = LoggerFactory.getLogger(QdrantVectorStoreServiceImpl.class);

    private final AiProperties aiProperties;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public QdrantVectorStoreServiceImpl(AiProperties aiProperties) {
        this.aiProperties = aiProperties;
    }

    @Override
    public boolean ensureCollection() {
        if (!aiProperties.getRag().isEnabled()) {
            return false;
        }
        try {
            HttpResponse<String> getResp = send("GET", collectionUrl(), null);
            if (getResp.statusCode() >= 200 && getResp.statusCode() < 300) {
                return true;
            }

            Map<String, Object> body = Map.of(
                    "vectors", Map.of(
                            "size", aiProperties.getRag().getVectorSize(),
                            "distance", "Cosine"));
            HttpResponse<String> putResp = send("PUT", collectionUrl(), objectMapper.writeValueAsString(body));
            boolean ok = putResp.statusCode() >= 200 && putResp.statusCode() < 300;
            if (!ok) {
                log.warn("Qdrant create collection failed status={} body={}", putResp.statusCode(), putResp.body());
            }
            return ok;
        } catch (Exception exception) {
            log.warn("Qdrant ensureCollection failed: {}", exception.getMessage());
            return false;
        }
    }

    @Override
    public void upsert(List<VectorDocumentChunk> chunks, List<List<Double>> vectors) {
        if (chunks == null || chunks.isEmpty() || vectors == null || vectors.isEmpty()) {
            return;
        }
        try {
            List<Map<String, Object>> points = new ArrayList<>();
            for (int index = 0; index < chunks.size(); index++) {
                VectorDocumentChunk chunk = chunks.get(index);
                List<Double> vector = vectors.get(index);
                Map<String, Object> payload = new HashMap<>();
                payload.put("sourceType", chunk.getSourceType());
                payload.put("sourcePath", chunk.getSourcePath());
                payload.put("topicCode", chunk.getTopicCode());
                payload.put("screenScope", chunk.getScreenScope());
                payload.put("routeScope", chunk.getRouteScope());
                payload.put("phaseScope", chunk.getPhaseScope());
                payload.put("intentScope", chunk.getIntentScope());
                payload.put("journalTypes", chunk.getJournalTypes());
                payload.put("keywords", chunk.getKeywords());
                payload.put("content", chunk.getContent());
                points.add(Map.of(
                        "id", chunk.getId(),
                        "vector", vector,
                        "payload", payload));
            }

            Map<String, Object> body = Map.of("points", points);
            HttpResponse<String> response = send(
                    "PUT",
                    collectionUrl() + "/points?wait=true",
                    objectMapper.writeValueAsString(body));
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                log.warn("Qdrant upsert failed status={} body={}", response.statusCode(), response.body());
            }
        } catch (Exception exception) {
            log.warn("Qdrant upsert failed: {}", exception.getMessage());
        }
    }

    @Override
    public List<VectorSearchResult> search(List<Double> queryVector, int limit) {
        if (queryVector == null || queryVector.isEmpty()) {
            return List.of();
        }
        try {
            Map<String, Object> body = Map.of(
                    "vector", queryVector,
                    "limit", limit,
                    "with_payload", true);
            HttpResponse<String> response = send(
                    "POST",
                    collectionUrl() + "/points/search",
                    objectMapper.writeValueAsString(body));
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                log.warn("Qdrant search failed status={} body={}", response.statusCode(), response.body());
                return List.of();
            }

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode result = root.path("result");
            if (!result.isArray()) {
                return List.of();
            }

            List<VectorSearchResult> results = new ArrayList<>();
            for (JsonNode node : result) {
                VectorDocumentChunk chunk = new VectorDocumentChunk();
                JsonNode payload = node.path("payload");
                chunk.setId(node.path("id").asText(""));
                chunk.setSourceType(payload.path("sourceType").asText(""));
                chunk.setSourcePath(payload.path("sourcePath").asText(""));
                chunk.setTopicCode(payload.path("topicCode").asText(""));
                chunk.setContent(payload.path("content").asText(""));
                chunk.setScreenScope(readStringList(payload.path("screenScope")));
                chunk.setRouteScope(readStringList(payload.path("routeScope")));
                chunk.setPhaseScope(readStringList(payload.path("phaseScope")));
                chunk.setIntentScope(readStringList(payload.path("intentScope")));
                chunk.setJournalTypes(readStringList(payload.path("journalTypes")));
                chunk.setKeywords(readStringList(payload.path("keywords")));

                VectorSearchResult searchResult = new VectorSearchResult();
                searchResult.setChunk(chunk);
                searchResult.setVectorScore(node.path("score").asDouble(0d));
                searchResult.setFinalScore(searchResult.getVectorScore());
                results.add(searchResult);
            }
            return results;
        } catch (Exception exception) {
            log.warn("Qdrant search failed: {}", exception.getMessage());
            return List.of();
        }
    }

    private String collectionUrl() {
        AiProperties.Rag rag = aiProperties.getRag();
        return "http://" + rag.getQdrantHost() + ":" + rag.getQdrantPort() + "/collections/" + rag.getQdrantCollection();
    }

    private HttpResponse<String> send(String method, String url, String body) throws Exception {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(20))
                .header("Content-Type", "application/json");
        String apiKey = aiProperties.getRag().getQdrantApiKey();
        if (apiKey != null && !apiKey.isBlank()) {
            builder.header("api-key", apiKey);
        }
        switch (method) {
            case "GET" -> builder.GET();
            case "PUT" -> builder.PUT(body == null ? HttpRequest.BodyPublishers.noBody() : HttpRequest.BodyPublishers.ofString(body));
            case "POST" -> builder.POST(body == null ? HttpRequest.BodyPublishers.noBody() : HttpRequest.BodyPublishers.ofString(body));
            default -> throw new IllegalArgumentException("Unsupported method " + method);
        }
        return httpClient.send(builder.build(), HttpResponse.BodyHandlers.ofString());
    }

    private List<String> readStringList(JsonNode node) {
        if (!node.isArray()) {
            return List.of();
        }
        List<String> values = new ArrayList<>();
        for (JsonNode item : node) {
            values.add(item.asText(""));
        }
        return values;
    }
}
