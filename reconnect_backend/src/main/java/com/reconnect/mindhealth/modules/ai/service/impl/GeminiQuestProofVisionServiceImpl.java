package com.reconnect.mindhealth.modules.ai.service.impl;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.dto.QuestProofVisionResultDto;
import com.reconnect.mindhealth.modules.ai.service.IQuestProofVisionService;

@Service
public class GeminiQuestProofVisionServiceImpl implements IQuestProofVisionService {

    private static final Logger log = LoggerFactory.getLogger(GeminiQuestProofVisionServiceImpl.class);

    private final AiProperties aiProperties;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public GeminiQuestProofVisionServiceImpl(AiProperties aiProperties) {
        this.aiProperties = aiProperties;
    }

    @Override
    public QuestProofVisionResultDto verifyQuestProof(String questTitle, String questDescription, byte[] imageBytes,
            String mimeType) {
        // Safe fallback (local dev / no key): auto-accept but still return a structured result.
        if (!aiProperties.isEnabled() || aiProperties.getGemini() == null
                || aiProperties.getGemini().getApiKey() == null
                || aiProperties.getGemini().getApiKey().isBlank()) {
            return new QuestProofVisionResultDto(true, 0.9, 80,
                    "AI Vision đang tắt hoặc thiếu API key; hệ thống tạm chấp nhận minh chứng (MVP/dev mode).",
                    List.of());
        }

        if (imageBytes == null || imageBytes.length == 0) {
            return new QuestProofVisionResultDto(false, 0.0, 0, "Ảnh trống hoặc không hợp lệ.", List.of());
        }

        String prompt = buildPrompt(questTitle, questDescription);
        String raw = generateVisionContent(prompt, imageBytes, mimeType, 256, 0.2);
        QuestProofVisionResultDto parsed = parseResultJson(raw);
        if (parsed.getRelevant() == null) {
            parsed.setRelevant(false);
        }
        if (parsed.getConfidence() == null) {
            parsed.setConfidence(0.0);
        }
        if (parsed.getScore() == null) {
            parsed.setScore(0);
        }
        if (parsed.getReason() == null || parsed.getReason().isBlank()) {
            parsed.setReason("Không thể phân tích ảnh (AI response rỗng).");
        }
        return parsed;
    }

    private String buildPrompt(String questTitle, String questDescription) {
        String t = questTitle == null ? "" : questTitle.trim();
        String d = questDescription == null ? "" : questDescription.trim();

        return """
                Bạn là hệ thống kiểm tra minh chứng ảnh cho nhiệm vụ CBT (Roadmap quest).
                Nhiệm vụ:
                - Title: %s
                - Description: %s

                Hãy đánh giá ảnh minh chứng có LIÊN QUAN tới nhiệm vụ hay không.
                Yêu cầu:
                - Không nhận diện danh tính cá nhân; không suy đoán thông tin riêng tư.
                - Nếu ảnh không rõ, mờ, không có nội dung liên quan => relevant=false, score thấp.
                - Trả về CHỈ MỘT JSON object, không kèm markdown, không giải thích ngoài JSON.

                Schema JSON:
                {
                  "relevant": true|false,
                  "confidence": 0.0-1.0,
                  "score": 0-100,
                  "reason": "một câu ngắn tiếng Việt",
                  "detectedLabels": ["label1","label2"]
                }
                """.formatted(t, d);
    }

    private String generateVisionContent(String prompt, byte[] imageBytes, String mimeType, int maxOutputTokens,
            double temperature) {
        try {
            AiProperties.Gemini gemini = aiProperties.getGemini();
            String url = gemini.getBaseUrl() + "/" + gemini.getApiVersion() + "/models/" + gemini.getModel()
                    + ":generateContent?key=" + gemini.getApiKey();

            String b64 = Base64.getEncoder().encodeToString(imageBytes);

            Map<String, Object> body = Map.of(
                    "contents", List.of(
                            Map.of("parts", List.of(
                                    Map.of("text", prompt),
                                    Map.of("inlineData", Map.of("mimeType", mimeType, "data", b64))))),
                    "generationConfig", Map.of(
                            "temperature", temperature,
                            "maxOutputTokens", maxOutputTokens));

            String json = objectMapper.writeValueAsString(body);

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofMillis(gemini.getTimeoutMs()))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            HttpResponse<String> resp = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() < 200 || resp.statusCode() >= 300) {
                log.warn("Gemini vision call failed status={} body={}", resp.statusCode(), safeSnippet(resp.body()));
                return "";
            }
            return extractTextFromGeminiResponse(resp.body());
        } catch (Exception e) {
            log.warn("Gemini vision call failed, falling back. {}", e.getMessage());
            return "";
        }
    }

    private String extractTextFromGeminiResponse(String rawJson) {
        try {
            JsonNode root = objectMapper.readTree(rawJson);
            JsonNode candidates = root.path("candidates");
            if (candidates.isArray() && candidates.size() > 0) {
                JsonNode parts = candidates.get(0).path("content").path("parts");
                if (parts.isArray() && parts.size() > 0) {
                    String text = parts.get(0).path("text").asText("");
                    return text != null ? text : "";
                }
            }
        } catch (Exception e) {
            // ignore
        }
        return "";
    }

    private QuestProofVisionResultDto parseResultJson(String text) {
        try {
            String json = extractFirstJsonObject(text);
            if (json.isBlank()) {
                return new QuestProofVisionResultDto(false, 0.0, 0, "AI trả về rỗng.", List.of());
            }
            JsonNode node = objectMapper.readTree(json);
            Boolean relevant = node.path("relevant").isBoolean() ? node.path("relevant").asBoolean() : null;
            Double confidence = node.path("confidence").isNumber() ? node.path("confidence").asDouble() : null;
            Integer score = node.path("score").isNumber() ? node.path("score").asInt() : null;
            String reason = node.path("reason").asText(null);

            List<String> labels = new ArrayList<>();
            JsonNode arr = node.path("detectedLabels");
            if (arr.isArray()) {
                for (JsonNode it : arr) {
                    String v = it.asText("").trim();
                    if (!v.isBlank()) {
                        labels.add(v);
                    }
                }
            }
            return new QuestProofVisionResultDto(relevant, confidence, score, reason, labels);
        } catch (Exception e) {
            return new QuestProofVisionResultDto(false, 0.0, 0, "Không parse được kết quả AI.", List.of());
        }
    }

    private String extractFirstJsonObject(String text) {
        if (text == null) {
            return "";
        }
        int start = text.indexOf('{');
        int end = text.lastIndexOf('}');
        if (start >= 0 && end > start) {
            return text.substring(start, end + 1).trim();
        }
        return "";
    }

    private String safeSnippet(String s) {
        if (s == null) {
            return "";
        }
        String t = s.replaceAll("\\s+", " ").trim();
        if (t.length() > 200) {
            return t.substring(0, 200) + "...";
        }
        return t;
    }
}
