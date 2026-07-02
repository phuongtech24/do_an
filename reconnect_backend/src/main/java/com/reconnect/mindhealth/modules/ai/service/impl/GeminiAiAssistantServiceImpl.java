package com.reconnect.mindhealth.modules.ai.service.impl;

import java.time.Duration;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

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
import com.reconnect.mindhealth.modules.ai.dto.GuideChatRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatSuggestedActionDto;
import com.reconnect.mindhealth.modules.ai.dto.JournalAiRiskResultDto;
import com.reconnect.mindhealth.modules.ai.model.GuideActionCard;
import com.reconnect.mindhealth.modules.ai.model.GuideKnowledgeCard;
import com.reconnect.mindhealth.modules.ai.service.GuideKnowledgeRetrieverService;
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
    private final GuideKnowledgeRetrieverService guideKnowledgeRetrieverService;
    private final RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector;
    private final RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final Map<String, GuideChatResponseDto> guideChatCache = new ConcurrentHashMap<>();

    public GeminiAiAssistantServiceImpl(
            AiProperties aiProperties,
            GuideKnowledgeRetrieverService guideKnowledgeRetrieverService,
            RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector,
            RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer) {
        this.aiProperties = aiProperties;
        this.guideKnowledgeRetrieverService = guideKnowledgeRetrieverService;
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
            return new JournalAiRiskResultDto(
                    100,
                    "LIFE_THREAT",
                    List.of(),
                    "Rule-based safety filter detected life-threat keywords.");
        }

        boolean shouldCallAi = aiProperties.isEnabled();
        if (shouldCallAi && aiProperties.getRisk().isCallAiOnlyWhenSuspicious()) {
            int threshold = aiProperties.getRisk().getAiCallThreshold();
            shouldCallAi = ruleScore >= threshold;
        }

        // If AI is disabled or not needed, use rule-based result.
        if (!shouldCallAi) {
            return new JournalAiRiskResultDto(
                    ruleScore >= 70 ? 70 : 0,
                    ruleScore >= 70 ? "CORE_BELIEF" : "NORMAL",
                    List.of(),
                    ruleScore >= 70 ? "Rule-based safety filter detected high-risk hopelessness signals." : "");
        }

        String prompt = buildStandardRiskPrompt(journalType, journalJsonContent);
        String raw = generateContent(prompt, 512, 0.1, riskScoringResponseSchema());

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
            return new JournalAiRiskResultDto(100, "LIFE_THREAT", parsed.getDistortions(), parsed.getReason());
        }
        if (finalScore >= 70) {
            return new JournalAiRiskResultDto(70, "CORE_BELIEF", parsed.getDistortions(), parsed.getReason());
        }
        return new JournalAiRiskResultDto(0, "NORMAL", parsed.getDistortions(), parsed.getReason());
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
        log.info("Detect cognitive distortions start: aiEnabled={}, shouldCallAi={}, ruleMatches={}, situationSnippet={}, thoughtSnippet={}",
                aiProperties.isEnabled(),
                shouldCallAi,
                rule.size(),
                safeSnippet(request.getSituation(), 80),
                safeSnippet(request.getAutomaticThought(), 120));

        if (!shouldCallAi) {
            String hint = rule.isEmpty()
                    ? "Chưa thấy mẫu lỗi tư duy quá rõ từ rule hiện tại; bạn vẫn có thể tự chọn thủ công."
                    : "Gợi ý từ rule-based — bạn có thể giữ hoặc chỉnh lại các nhãn này.";
            log.info("Detect cognitive distortions fallback: source=RULE_ONLY, suggestions={}, hasHint={}",
                    rule.size(), !hint.isBlank());
            return new CognitiveDistortionResponseDto(rule, hint);
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
        if (hint == null || hint.isBlank()) {
            hint = out.isEmpty()
                    ? "AI chưa thấy đủ tín hiệu rõ; bạn vẫn có thể tự chọn thủ công."
                    : "Gợi ý từ AI/rule — bạn chọn 1-3 lỗi tư duy phù hợp nhất.";
        }
        if (hint != null && (hint.contains("Ã") || hint.contains("á»"))) {
            hint = out.isEmpty()
                    ? "AI chưa thấy đủ tín hiệu rõ; bạn vẫn có thể tự chọn thủ công."
                    : "Gợi ý từ AI/rule — bạn chọn 1-3 lỗi tư duy phù hợp nhất.";
        }
        log.info("Detect cognitive distortions completed: source={}, suggestions={}, hasHint={}",
                raw == null || raw.isBlank() ? "RULE_FALLBACK_AFTER_AI" : "AI_OR_MERGED",
                out.size(),
                hint != null && !hint.isBlank());
        return new CognitiveDistortionResponseDto(out, hint);
    }

    @Override
    public GuideChatResponseDto guideChat(GuideChatRequestDto request) {
        if (shouldEscalateSafety(request)) {
            return buildSafetyGuideResponse(request);
        }

        String intent = detectGuideIntent(request);
        List<GuideKnowledgeCard> matchedCards = guideKnowledgeRetrieverService.retrieve(request);
        GuideKnowledgeCard primaryCard = matchedCards.isEmpty() ? null : matchedCards.get(0);
        String cacheKey = buildGuideCacheKey(request, intent, primaryCard);
        GuideChatResponseDto cached = guideChatCache.get(cacheKey);
        if (cached != null) {
            return cached;
        }

        boolean useFallbackOnly = shouldUseFallbackOnly(request, matchedCards);
        GuideChatResponseDto response = useFallbackOnly
                ? buildGuideFallbackResponse(request, intent, primaryCard)
                : buildGeminiGuideResponse(request, intent, matchedCards, primaryCard);

        guideChatCache.put(cacheKey, response);
        return response;
    }

    private boolean shouldEscalateSafety(GuideChatRequestDto request) {
        int riskScore = request.getCurrentRiskScore() != null ? request.getCurrentRiskScore() : 0;
        return request.isRedFlagActive() || riskScore >= 70;
    }

    private GuideChatResponseDto buildSafetyGuideResponse(GuideChatRequestDto request) {
        return new GuideChatResponseDto(
                "Mình sẽ ưu tiên an toàn cho bạn trước. Hiện hệ thống đang thấy mức rủi ro cao hoặc có cờ đỏ, nên mình không tiếp tục hỗ trợ trị liệu mở ở đây. Nếu được, bạn hãy mở hỗ trợ an toàn hoặc xem ngay mục tham vấn từ xa để kết nối với chuyên gia phù hợp.",
                List.of(
                        new GuideChatSuggestedActionDto("Mở hỗ trợ an toàn", "/safety-support"),
                        new GuideChatSuggestedActionDto("Xem tham vấn từ xa", "/telehealth")),
                "SAFETY_ESCALATION",
                true,
                true,
                true);
    }

    private String detectGuideIntent(GuideChatRequestDto request) {
        String normalized = normalizeText(request.getUserMessage());
        if (containsAny(normalized, "khong an toan", "cap cuu", "khan cap", "nguy hiem", "co do")) {
            return "SAFETY_ESCALATION";
        }
        if (containsAny(normalized, "lam gi tiep", "tiep theo", "bat dau tu dau", "nen lam gi")) {
            return "NEXT_STEP";
        }
        if (containsAny(normalized, "giai thich", "tai sao", "y nghia", "co che")) {
            return "FEATURE_EXPLAINER";
        }
        if (containsAny(normalized, "toi dang lo", "toi lo", "ho tro nhe", "tran an", "binh tinh")) {
            return "CBT_SUPPORT_LIGHT";
        }
        return "APP_GUIDE";
    }

    private boolean shouldUseFallbackOnly(GuideChatRequestDto request, List<GuideKnowledgeCard> matchedCards) {
        if (!aiProperties.isEnabled()) {
            return true;
        }
        String normalized = normalizeText(request.getUserMessage());
        boolean quickFaq = containsAny(
                normalized,
                "man nay la gi",
                "dung de lam gi",
                "toi nen lam gi tiep",
                "giai thich bai tap nay",
                "bat dau tu dau");
        return quickFaq;
    }

    private GuideChatResponseDto buildGuideFallbackResponse(
            GuideChatRequestDto request,
            String intent,
            GuideKnowledgeCard primaryCard) {
        List<GuideChatSuggestedActionDto> actions = buildSuggestedActions(primaryCard, request.getScreenContext());
        String topicCode = primaryCard != null ? primaryCard.getTopicCode() : "GENERAL_GUIDE";
        String answer;

        if (primaryCard == null) {
            answer = "Mình là trợ lý đồng hành giúp bạn hiểu màn hiện tại, biết nên làm gì tiếp theo và giải thích các công cụ CBT mức nhẹ. Nếu bạn muốn, hãy thử hỏi theo kiểu: màn này dùng để làm gì, tôi nên làm gì tiếp theo, hoặc giải thích bài tập này.";
        } else if ("NEXT_STEP".equals(intent)) {
            answer = primaryCard.getContent() + " Bước tiếp theo phù hợp nhất lúc này là chọn một thao tác nhỏ, rõ ràng thay vì cố làm mọi thứ cùng lúc.";
        } else if ("CBT_SUPPORT_LIGHT".equals(intent)) {
            answer = primaryCard.getContent() + " Nếu đang thấy lo, bạn chỉ cần bắt đầu bằng một bước ngắn và trung thực với cảm xúc hiện tại của mình.";
        } else {
            answer = primaryCard.getContent();
        }

        return new GuideChatResponseDto(
                answer,
                actions,
                topicCode,
                true,
                false,
                false);
    }

    private GuideChatResponseDto buildGeminiGuideResponse(
            GuideChatRequestDto request,
            String intent,
            List<GuideKnowledgeCard> matchedCards,
            GuideKnowledgeCard primaryCard) {
        String prompt = buildGuideChatPrompt(request, intent, matchedCards);
        String raw = generateContent(prompt, 512, 0.2, guideChatResponseSchema());
        GuideChatResponseDto parsed = parseGuideChatJson(raw);

        if (parsed.getAnswer() == null || parsed.getAnswer().isBlank()) {
            return buildGuideFallbackResponse(request, intent, primaryCard);
        }

        if (parsed.getSuggestedActions() == null || parsed.getSuggestedActions().isEmpty()) {
            parsed.setSuggestedActions(buildSuggestedActions(primaryCard, request.getScreenContext()));
        }
        if (parsed.getRelatedTopicCode() == null || parsed.getRelatedTopicCode().isBlank()) {
            parsed.setRelatedTopicCode(primaryCard != null ? primaryCard.getTopicCode() : "GENERAL_GUIDE");
        }
        parsed.setUsedFallback(false);
        return parsed;
    }

    private String buildGuideChatPrompt(
            GuideChatRequestDto request,
            String intent,
            List<GuideKnowledgeCard> matchedCards) {
        String knowledgeBlock = matchedCards.isEmpty()
                ? "Không có tri thức khớp hoàn toàn. Chỉ trả lời ở mức hướng dẫn sử dụng app và CBT nhẹ."
                : matchedCards.stream()
                        .limit(aiProperties.getGuide().getTopK())
                        .map(card -> "- " + card.getTopicCode() + ": " + card.getContent())
                        .collect(Collectors.joining("\n"));

        String route = request.getPatientRoute() != null ? request.getPatientRoute() : "";
        String phase = request.getProgramPhaseCode() != null ? request.getProgramPhaseCode() : "";
        String week = request.getProgramWeek() != null ? String.valueOf(request.getProgramWeek()) : "";

        return ""
                + "Bạn là AI Bạn Đồng Hành của ứng dụng ReConnect MindHealth.\n"
                + "Vai trò: hướng dẫn sử dụng app, giải thích CBT ở mức nhẹ, gợi ý bước tiếp theo cho người có lo âu xã hội.\n"
                + "Không chẩn đoán. Không kê thuốc. Không thay thế bác sĩ hay nhà trị liệu. Không nói sang trầm cảm như một bệnh lý chính.\n"
                + "Chỉ trả lời dựa trên tri thức nội bộ bên dưới và bối cảnh màn hình hiện tại.\n"
                + "Câu trả lời dài khoảng 80-180 từ. Tối đa 2 gợi ý hành động.\n"
                + "Trả về DUY NHẤT một JSON object hợp lệ theo schema.\n"
                + "Tri thức nội bộ:\n"
                + knowledgeBlock + "\n\n"
                + "Ngữ cảnh:\n"
                + "- screenContext: " + request.getScreenContext() + "\n"
                + "- patientRoute: " + route + "\n"
                + "- programWeek: " + week + "\n"
                + "- programPhaseCode: " + phase + "\n"
                + "- intent: " + intent + "\n"
                + "Câu hỏi người dùng: " + request.getUserMessage();
    }

    private Map<String, Object> guideChatResponseSchema() {
        return Map.of(
                "type", "OBJECT",
                "properties", Map.of(
                        "answer", Map.of("type", "STRING"),
                        "relatedTopicCode", Map.of("type", "STRING"),
                        "suggestedActions", Map.of(
                                "type", "ARRAY",
                                "items", Map.of(
                                        "type", "OBJECT",
                                        "properties", Map.of(
                                                "label", Map.of("type", "STRING"),
                                                "route", Map.of("type", "STRING")),
                                        "required", List.of("label", "route")))),
                "required", List.of("answer", "relatedTopicCode", "suggestedActions"));
    }

    private GuideChatResponseDto parseGuideChatJson(String text) {
        try {
            String json = extractFirstJsonObject(text);
            if (json.isBlank()) {
                return new GuideChatResponseDto();
            }
            JsonNode node = objectMapper.readTree(json);
            String answer = node.path("answer").asText("");
            String relatedTopicCode = node.path("relatedTopicCode").asText("");
            List<GuideChatSuggestedActionDto> actions = new ArrayList<>();
            JsonNode array = node.path("suggestedActions");
            if (array.isArray()) {
                for (JsonNode item : array) {
                    String label = item.path("label").asText("").trim();
                    String route = item.path("route").asText("").trim();
                    if (!label.isBlank() && !route.isBlank()) {
                        actions.add(new GuideChatSuggestedActionDto(label, route));
                    }
                }
            }
            return new GuideChatResponseDto(answer, actions, relatedTopicCode, false, false, false);
        } catch (Exception exception) {
            return new GuideChatResponseDto();
        }
    }

    private List<GuideChatSuggestedActionDto> buildSuggestedActions(GuideKnowledgeCard primaryCard, String screenContext) {
        if (primaryCard != null && primaryCard.getSuggestedActions() != null && !primaryCard.getSuggestedActions().isEmpty()) {
            return primaryCard.getSuggestedActions().stream()
                    .limit(2)
                    .map(action -> new GuideChatSuggestedActionDto(action.getLabel(), action.getRoute()))
                    .collect(Collectors.toList());
        }

        String normalizedScreen = normalizeText(screenContext);
        if ("roadmap".equals(normalizedScreen)) {
            return List.of(
                    new GuideChatSuggestedActionDto("Xem lộ trình", "/roadmap"),
                    new GuideChatSuggestedActionDto("Viết nhật ký suy nghĩ", "/thought-record"));
        }
        if ("thought-record".equals(normalizedScreen) || "journal".equals(normalizedScreen)) {
            return List.of(
                    new GuideChatSuggestedActionDto("Mở nhật ký suy nghĩ", "/thought-record"),
                    new GuideChatSuggestedActionDto("Quay lại nhật ký", "/journal"));
        }
        return List.of(
                new GuideChatSuggestedActionDto("Mở trang chủ", "/home"),
                new GuideChatSuggestedActionDto("Xem lộ trình", "/roadmap"));
    }

    private String buildGuideCacheKey(GuideChatRequestDto request, String intent, GuideKnowledgeCard card) {
        return String.join("|",
                normalizeText(request.getScreenContext()),
                normalizeText(request.getPatientRoute()),
                normalizeText(intent),
                normalizeText(card != null ? card.getTopicCode() : "general"),
                normalizeText(request.getUserMessage()));
    }

    private String normalizeText(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D');
        return normalized.toLowerCase(Locale.ROOT).trim();
    }

    private boolean containsAny(String normalized, String... keywords) {
        for (String keyword : keywords) {
            if (normalized.contains(keyword)) {
                return true;
            }
        }
        return false;
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

    private String cognitiveDistortionDefinitionsPrompt() {
        return ""
                + "Cơ sở phân loại 12 Cognitive Distortions. Chỉ chọn code trong danh sách này nếu nội dung thật sự phù hợp:\n"
                + "- ALL_OR_NOTHING: Tư duy trắng-đen; nhìn tình huống theo hai thái cực thay vì một dải liên tục.\n"
                + "- CATASTROPHIZING: Thảm họa hóa/dự đoán tương lai tiêu cực mà bỏ qua kết quả thực tế hơn.\n"
                + "- DISQUALIFYING_POSITIVE: Bác bỏ hoặc đánh giá thấp trải nghiệm, hành động, phẩm chất tích cực.\n"
                + "- EMOTIONAL_REASONING: Cho rằng điều gì đó đúng chỉ vì cảm thấy/tin rất mạnh như vậy.\n"
                + "- LABELING: Gắn nhãn tiêu cực, cố định, toàn diện cho bản thân hoặc người khác.\n"
                + "- MAGNIFICATION_MINIMIZATION: Phóng đại điều tiêu cực hoặc thu nhỏ điều tích cực một cách vô lý.\n"
                + "- MENTAL_FILTER: Chỉ chú ý một chi tiết tiêu cực thay vì nhìn toàn bộ bức tranh.\n"
                + "- MIND_READING: Tin chắc mình biết người khác đang nghĩ gì mà không xét khả năng khác.\n"
                + "- OVERGENERALIZATION: Rút ra kết luận tiêu cực bao quát vượt xa tình huống hiện tại.\n"
                + "- PERSONALIZATION: Tự đổ lỗi cho phản ứng/hành vi tiêu cực của người khác mà bỏ qua giải thích hợp lý hơn.\n"
                + "- SHOULD_MUST: Câu lệnh phải/nên cứng nhắc về cách bản thân hoặc người khác phải hành xử.\n"
                + "- TUNNEL_VISION: Chỉ nhìn thấy các khía cạnh tiêu cực của một tình huống.\n";
    }

    private String buildStandardRiskPrompt(JournalType journalType, String journalJsonContent) {
        return ""
                + "Bạn là chuyên gia phân tích tâm lý theo Liệu pháp Nhận thức Hành vi (CBT).\n"
                + "Nhiệm vụ: phân tích đoạn Nhật ký suy nghĩ (Thought Record) của bệnh nhân theo risk và lỗi tư duy, rồi trả về DUY NHẤT một JSON object hợp lệ.\n"
                + "Không markdown, không code fence, không giải thích ngoài JSON.\n\n"
                + "Schema bắt buộc:\n"
                + "{\n"
                + "  \"aiRiskScore\": 0 | 70 | 100,\n"
                + "  \"severityLevel\": \"NORMAL\" | \"CORE_BELIEF\" | \"LIFE_THREAT\",\n"
                + "  \"distortions\": [\"CODE\"],\n"
                + "  \"reason\": \"Giải thích ngắn nếu aiRiskScore là 70 hoặc 100; nếu 0 để chuỗi rỗng. Không trích nguyên văn nhật ký.\"\n"
                + "}\n\n"
                + "Tiêu chí chấm điểm rủi ro:\n"
                + "- 0 / NORMAL: suy nghĩ tiêu cực, buồn bã, chán nản thông thường; không có nguy cơ đe dọa tính mạng.\n"
                + "- 70 / CORE_BELIEF: tuyệt vọng sâu sắc, bế tắc tột cùng, buông xuôi mờ nhạt như \"tôi muốn biến mất\", \"không còn hy vọng\".\n"
                + "- 100 / LIFE_THREAT: có ý định tự sát rõ ràng, kế hoạch tự hại, nhắc tới cái chết hoặc hành vi tự hại.\n\n"
                + cognitiveDistortionDefinitionsPrompt()
                + "\n"
                + "Lưu ý an toàn: nếu nội dung có dấu hiệu trực tiếp về tự sát/tự hại, chọn 100.\n"
                + "reason phải ngắn gọn, không trích nguyên văn thông tin nhạy cảm của bệnh nhân.\n"
                + "journalType=" + journalType.name() + "\n"
                + "journalJson=" + journalJsonContent;
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
                + cognitiveDistortionDefinitionsPrompt()
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

    private Map<String, Object> riskScoringResponseSchema() {
        return Map.of(
                "type", "OBJECT",
                "properties", Map.of(
                        "aiRiskScore", Map.of("type", "INTEGER"),
                        "severityLevel", Map.of("type", "STRING"),
                        "distortions", Map.of(
                                "type", "ARRAY",
                                "items", Map.of("type", "STRING")),
                        "reason", Map.of("type", "STRING")),
                "required", List.of("aiRiskScore", "severityLevel", "distortions", "reason"));
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
            Integer score = node.path("aiRiskScore").isNumber()
                    ? node.path("aiRiskScore").asInt()
                    : (node.path("score").isNumber() ? node.path("score").asInt() : 0);
            String severity = node.path("severityLevel").asText("");
            if (severity.isBlank()) {
                severity = switch (score) {
                    case 100 -> "LIFE_THREAT";
                    case 70 -> "CORE_BELIEF";
                    default -> "NORMAL";
                };
            }
            List<String> distortions = new ArrayList<>();
            JsonNode arr = node.path("distortions");
            if (arr.isArray()) {
                for (JsonNode it : arr) {
                    String code = it.asText("").trim();
                    if (!code.isBlank()) {
                        distortions.add(code);
                    }
                }
            }
            String reason = node.path("reason").asText("");
            return new JournalAiRiskResultDto(score, severity, distortions, reason);
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
