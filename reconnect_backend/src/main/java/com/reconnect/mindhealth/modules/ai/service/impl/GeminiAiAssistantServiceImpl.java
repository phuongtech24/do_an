package com.reconnect.mindhealth.modules.ai.service.impl;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.JournalAiRiskResultDto;
import com.reconnect.mindhealth.modules.ai.service.IAiAssistantService;
import com.reconnect.mindhealth.modules.ai.service.RuleBasedCognitiveDistortionDetector;
import com.reconnect.mindhealth.modules.ai.service.RuleBasedJournalRiskScorer;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
public class GeminiAiAssistantServiceImpl implements IAiAssistantService {

    private static final Logger log = LoggerFactory.getLogger(GeminiAiAssistantServiceImpl.class);

    private final AiProperties aiProperties;
    private final RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector;
    private final RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public GeminiAiAssistantServiceImpl(
            AiProperties aiProperties,
            RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector,
            RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer) {
        this.aiProperties = aiProperties;
        this.ruleBasedCognitiveDistortionDetector = ruleBasedCognitiveDistortionDetector;
        this.ruleBasedJournalRiskScorer = ruleBasedJournalRiskScorer;
    }

    @Override
    public GuidedDiscoveryResponseDto guidedDiscovery(GuidedDiscoveryRequestDto request) {
        if (!aiProperties.isEnabled()) {
            return new GuidedDiscoveryResponseDto(List.of(
                    "Điều gì khiến bạn tin rằng suy nghĩ đó chắc chắn là đúng?",
                    "Nếu một người bạn thân ở trong tình huống này, bạn sẽ nói gì để giúp họ nhìn khác đi?"));
        }

        String prompt = buildGuidedDiscoveryPrompt(request);
        String raw = generateContent(prompt, 1024, 0.1, guidedDiscoveryResponseSchema());
        List<String> questions = parseQuestionsJson(raw);
        if (questions.isEmpty()) {
            log.warn("Guided discovery parse empty, using fallback.");
            questions = List.of(
                    "Bạn có bằng chứng nào ủng hộ và bằng chứng nào phản bác suy nghĩ này?",
                    "Có cách giải thích nào khác (ít tiêu cực hơn) cho tình huống này không?");
        }
        return new GuidedDiscoveryResponseDto(questions);
    }

    @Override
    public JournalAiRiskResultDto scoreJournalRisk(JournalType journalType, String journalJsonContent) {
        if (journalType == null || journalJsonContent == null || journalJsonContent.isBlank()) {
            return new JournalAiRiskResultDto(0, "NORMAL");
        }

        JournalAiRiskResultDto rule = ruleBasedJournalRiskScorer.score(journalType, journalJsonContent);
        int ruleScore = rule.getAiRiskScore() != null ? rule.getAiRiskScore() : 0;

        // Safety: if rule detects life-threat, short-circuit without calling AI (saves quota and avoids latency).
        if (ruleScore >= 100) {
            return new JournalAiRiskResultDto(100, "LIFE_THREAT");
        }

        boolean shouldCallAi = aiProperties.isEnabled();
        if (shouldCallAi && aiProperties.getRisk().isCallAiOnlyWhenSuspicious()) {
            int threshold = aiProperties.getRisk().getAiCallThreshold();
            shouldCallAi = ruleScore >= threshold;
        }

        // If AI is disabled or not needed, use rule-based result.
        if (!shouldCallAi) {
            return new JournalAiRiskResultDto(ruleScore >= 70 ? 70 : 0, ruleScore >= 70 ? "CORE_BELIEF" : "NORMAL");
        }

        String prompt = buildRiskPrompt(journalType, journalJsonContent);
        String raw = generateContent(prompt, 256, 0.2);

        JournalAiRiskResultDto parsed = parseRiskJson(raw);
        if (parsed.getAiRiskScore() == null) {
            parsed.setAiRiskScore(0);
        }
        if (parsed.getSeverityLevel() == null || parsed.getSeverityLevel().isBlank()) {
            parsed.setSeverityLevel("NORMAL");
        }
        // Conservative merge: never downgrade below rule-based score (safety-first).
        int aiScore = parsed.getAiRiskScore();
        int finalScore = Math.max(ruleScore, aiScore);

        // Hard safety clamp to expected set.
        if (finalScore >= 100) {
            return new JournalAiRiskResultDto(100, "LIFE_THREAT");
        }
        if (finalScore >= 70) {
            return new JournalAiRiskResultDto(70, "CORE_BELIEF");
        }
        return new JournalAiRiskResultDto(0, "NORMAL");
    }

    @Override
    public CognitiveDistortionResponseDto detectCognitiveDistortions(CognitiveDistortionRequestDto request) {
        int max = aiProperties.getDistortions().getMaxSuggestions();
        List<String> rule = ruleBasedCognitiveDistortionDetector.detect(
                request.getSituation(),
                request.getAutomaticThought(),
                max);

        boolean shouldCallAi = aiProperties.isEnabled();
        if (shouldCallAi && aiProperties.getDistortions().isCallAiOnlyWhenSuspicious()) {
            shouldCallAi = !rule.isEmpty();
        }

        if (!shouldCallAi) {
            return new CognitiveDistortionResponseDto(rule, rule.isEmpty() ? null : "Gợi ý (rule-based) — bạn có thể chỉnh lại.");
        }

        String prompt = buildCognitiveDistortionsPrompt(request, max);
        String raw = generateContent(prompt, 256, 0.2);
        CognitiveDistortionResponseDto parsed = parseDistortionsJson(raw);

        List<String> out = parsed.getDistortions() != null ? parsed.getDistortions() : List.of();
        if (out.isEmpty() && !rule.isEmpty()) {
            out = rule;
        }
        if (out.size() > max) {
            out = out.subList(0, max);
        }

        String hint = parsed.getHint();
        if (hint == null || hint.isBlank()) {
            hint = out.isEmpty() ? null : "Gợi ý — bạn chọn 1–3 lỗi tư duy phù hợp nhất.";
        }
        return new CognitiveDistortionResponseDto(out, hint);
    }

    private String buildGuidedDiscoveryPrompt(GuidedDiscoveryRequestDto r) {
        String moodLine = r.getMoodScore() != null ? ("Mood=" + r.getMoodScore() + "/100.\n") : "";
        String emotionLine = (r.getEmotion() != null && !r.getEmotion().isBlank())
                ? ("Cảm xúc: " + r.getEmotion() + "\n")
                : "";

        return ""
                + "Bạn là một nhà trị liệu CBT. Nhiệm vụ: tạo 1-2 câu hỏi Socratic ngắn gọn bằng tiếng Việt.\n"
                + "Không tư vấn y khoa. Không nhắc đến chính sách. Không giải thích dài.\n"
                + "Trả về DUY NHẤT một JSON object hợp lệ. Ký tự đầu tiên phải là { và ký tự cuối cùng phải là }.\n"
                + "Không markdown. Không code fence. Không ```json. Không text ngoài JSON.\n"
                + "Mỗi câu hỏi tối đa 120 ký tự. Schema bắt buộc: {\"questions\":[\"câu hỏi 1\",\"câu hỏi 2\"]}\n"
                + moodLine
                + "Tình huống: " + r.getSituation() + "\n"
                + "Suy nghĩ tự động: " + r.getAutomaticThought() + "\n"
                + emotionLine;
    }

    private String buildRiskPrompt(JournalType journalType, String journalJsonContent) {
        return ""
                + "Bạn là hệ thống phân loại rủi ro ngôn ngữ (NLP) cho ứng dụng CBT.\n"
                + "Hãy phân loại mức rủi ro từ nội dung nhật ký. Chỉ cần 3 mức:\n"
                + "- 0: NORMAL\n"
                + "- 70: CORE_BELIEF_ACTIVATION (bế tắc cùng cực, bất lực, vô giá trị, không thể yêu thương)\n"
                + "- 100: LIFE_THREAT (từ khoá tự sát/cái chết/ý định tự hại)\n"
                + "Đầu ra BẮT BUỘC là JSON thuần đúng schema: {\"aiRiskScore\":0|70|100,\"severityLevel\":\"NORMAL|CORE_BELIEF|LIFE_THREAT\"}\n"
                + "journalType=" + journalType.name() + "\n"
                + "journalJson=" + journalJsonContent;
    }

    private String buildCognitiveDistortionsPrompt(CognitiveDistortionRequestDto r, int max) {
        return ""
                + "Bạn là chuyên gia CBT. Nhiệm vụ: dựa vào 'automaticThought' và 'situation' để gợi ý 1-3 lỗi tư duy.\n"
                + "Chỉ được chọn trong danh sách code sau:\n"
                + "- CATASTROPHIZING\n"
                + "- MIND_READING\n"
                + "- ALL_OR_NOTHING\n"
                + "- OVERGENERALIZATION\n"
                + "- EMOTIONAL_REASONING\n"
                + "- LABELING\n"
                + "Đầu ra BẮT BUỘC là JSON thuần đúng schema: {\"distortions\":[\"CODE\"...],\"hint\":\"...\"}\n"
                + "Quy tắc: distortions dài tối đa " + max + " phần tử; hint 1 câu ngắn tiếng Việt.\n"
                + "situation=" + r.getSituation() + "\n"
                + "automaticThought=" + r.getAutomaticThought();
    }

    private String generateContent(String prompt, int maxOutputTokens, double temperature) {
        return generateContent(prompt, maxOutputTokens, temperature, null);
    }

    private String generateContent(
            String prompt,
            int maxOutputTokens,
            double temperature,
            Map<String, Object> responseSchema) {
        try {
            AiProperties.Gemini gemini = aiProperties.getGemini();
            if (gemini.getApiKey() == null || gemini.getApiKey().isBlank()) {
                log.warn("AI enabled but Gemini apiKey is missing. Falling back.");
                return "";
            }

            String url = String.format("%s/%s/models/%s:generateContent?key=%s",
                    gemini.getBaseUrl(),
                    gemini.getApiVersion(),
                    gemini.getModel(),
                    gemini.getApiKey());

            Map<String, Object> generationConfig = responseSchema == null
                    ? Map.of(
                            "temperature", temperature,
                            "maxOutputTokens", maxOutputTokens)
                    : Map.of(
                            "temperature", temperature,
                            "maxOutputTokens", maxOutputTokens,
                            "responseMimeType", "application/json",
                            "responseSchema", responseSchema);

            Map<String, Object> body = Map.of(
                    "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))),
                    "generationConfig", generationConfig);

            String json = objectMapper.writeValueAsString(body);

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofMillis(gemini.getTimeoutMs()))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(json))
                    .build();

            log.info("Gemini call start model={}, apiVersion={}, maxOutputTokens={}",
                    gemini.getModel(), gemini.getApiVersion(), maxOutputTokens);

            HttpResponse<String> resp = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() < 200 || resp.statusCode() >= 300) {
                log.warn("Gemini call failed status={} body={}", resp.statusCode(), safeSnippet(resp.body()));
                return "";
            }

            log.info("Gemini raw response snippet={}", safeSnippet(resp.body(), 500));
            String text = extractTextFromGeminiResponse(resp.body());
            log.info("Gemini call success model={}, responseChars={}",
                    gemini.getModel(), text != null ? text.length() : 0);
            if (text == null || text.isBlank()) {
                log.warn("Gemini response text empty, falling back.");
                return "";
            }
            log.info("Gemini response snippet={}", safeSnippet(text, 500));
            return text;
        } catch (Exception e) {
            log.warn("Gemini call failed, falling back. {}", e.getMessage());
            return "";
        }
    }

    private Map<String, Object> guidedDiscoveryResponseSchema() {
        return Map.of(
                "type", "OBJECT",
                "properties", Map.of(
                        "questions", Map.of(
                                "type", "ARRAY",
                                "items", Map.of("type", "STRING"))),
                "required", List.of("questions"));
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

    private List<String> parseQuestionsJson(String text) {
        try {
            String json = extractFirstJsonObject(text);
            if (json.isBlank()) {
                return List.of();
            }
            Map<String, Object> parsed = objectMapper.readValue(json, new TypeReference<>() {
            });
            Object q = parsed.get("questions");
            if (q instanceof List<?> list) {
                return normalizeQuestions(list);
            }
        } catch (Exception e) {
            // ignore
        }
        return List.of();
    }

    private List<String> normalizeQuestions(List<?> list) {
        List<String> out = new ArrayList<>();
        for (Object item : list) {
            if (item != null) {
                String s = String.valueOf(item).trim();
                if (!s.isBlank()) {
                    out.add(s);
                }
            }
        }
        return out;
    }

    private JournalAiRiskResultDto parseRiskJson(String text) {
        try {
            String json = extractFirstJsonObject(text);
            if (json.isBlank()) {
                return new JournalAiRiskResultDto(0, "NORMAL");
            }
            JsonNode node = objectMapper.readTree(json);
            Integer score = node.path("aiRiskScore").isNumber() ? node.path("aiRiskScore").asInt() : 0;
            String severity = node.path("severityLevel").asText("NORMAL");
            return new JournalAiRiskResultDto(score, severity);
        } catch (Exception e) {
            return new JournalAiRiskResultDto(0, "NORMAL");
        }
    }

    private CognitiveDistortionResponseDto parseDistortionsJson(String text) {
        try {
            String json = extractFirstJsonObject(text);
            if (json.isBlank()) {
                return new CognitiveDistortionResponseDto(List.of(), null);
            }
            JsonNode node = objectMapper.readTree(json);
            List<String> list = new ArrayList<>();
            JsonNode arr = node.path("distortions");
            if (arr.isArray()) {
                for (JsonNode it : arr) {
                    String v = it.asText("").trim();
                    if (!v.isBlank()) {
                        list.add(v);
                    }
                }
            }
            String hint = node.path("hint").asText(null);
            return new CognitiveDistortionResponseDto(list, hint);
        } catch (Exception e) {
            return new CognitiveDistortionResponseDto(List.of(), null);
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
        return safeSnippet(s, 200);
    }

    private String safeSnippet(String s, int maxLength) {
        if (s == null) {
            return "";
        }
        String t = s.replaceAll("\\s+", " ").trim();
        if (t.length() > maxLength) {
            return t.substring(0, maxLength) + "...";
        }
        return t;
    }
}
