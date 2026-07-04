package com.reconnect.mindhealth.modules.ai.service.impl;

import java.time.Duration;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
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
import com.reconnect.mindhealth.modules.ai.dto.AiKnowledgeQueryDto;
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
import com.reconnect.mindhealth.modules.ai.model.RagContextBundle;
import com.reconnect.mindhealth.modules.ai.service.GuideKnowledgeRetrieverService;
import com.reconnect.mindhealth.modules.ai.service.IAiAssistantService;
import com.reconnect.mindhealth.modules.ai.service.RagRetrievalService;
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
    private final RagRetrievalService ragRetrievalService;
    private final RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector;
    private final RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final Map<String, GuideChatResponseDto> guideChatCache = new ConcurrentHashMap<>();
    private static final Charset WINDOWS_1252 = Charset.forName("Windows-1252");

    public GeminiAiAssistantServiceImpl(
            AiProperties aiProperties,
            GuideKnowledgeRetrieverService guideKnowledgeRetrieverService,
            RagRetrievalService ragRetrievalService,
            RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector,
            RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer) {
        this.aiProperties = aiProperties;
        this.guideKnowledgeRetrieverService = guideKnowledgeRetrieverService;
        this.ragRetrievalService = ragRetrievalService;
        this.ruleBasedCognitiveDistortionDetector = ruleBasedCognitiveDistortionDetector;
        this.ruleBasedJournalRiskScorer = ruleBasedJournalRiskScorer;
    }

    @Override
    public GuidedDiscoveryResponseDto guidedDiscovery(GuidedDiscoveryRequestDto request) {
        if (!aiProperties.isEnabled()) {
            return new GuidedDiscoveryResponseDto(List.of(
                    "Ã„ÂiÃ¡Â»Âu gÃƒÂ¬ khiÃ¡ÂºÂ¿n bÃ¡ÂºÂ¡n tin rÃ¡ÂºÂ±ng suy nghÃ„Â© Ã„â€˜ÃƒÂ³ chÃ¡ÂºÂ¯c chÃ¡ÂºÂ¯n lÃƒÂ  Ã„â€˜ÃƒÂºng?",
                    "NÃ¡ÂºÂ¿u mÃ¡Â»â„¢t ngÃ†Â°Ã¡Â»Âi bÃ¡ÂºÂ¡n thÃƒÂ¢n Ã¡Â»Å¸ trong tÃƒÂ¬nh huÃ¡Â»â€˜ng nÃƒÂ y, bÃ¡ÂºÂ¡n sÃ¡ÂºÂ½ nÃƒÂ³i gÃƒÂ¬ Ã„â€˜Ã¡Â»Æ’ giÃƒÂºp hÃ¡Â»Â nhÃƒÂ¬n khÃƒÂ¡c Ã„â€˜i?"));
        }

        List<GuideKnowledgeCard> matchedCards = retrieveThoughtRecordKnowledge(
                request.getSituation(),
                request.getAutomaticThought(),
                request.getEmotion(),
                null,
                "GUIDED_DISCOVERY");
        String prompt = buildGuidedDiscoveryPrompt(
                request,
                resolveKnowledgeBlock(
                        buildThoughtRecordKnowledgeQuery(
                                request.getSituation(),
                                request.getAutomaticThought(),
                                request.getEmotion(),
                                null,
                                "GUIDED_DISCOVERY"),
                        matchedCards,
                        "KhÃ´ng cÃ³ tri thá»©c retrieve khá»›p rÃµ. HÃ£y Ä‘áº·t cÃ¢u há»i CBT an toÃ n, ngáº¯n vÃ  trung tÃ­nh."));
        String raw = generateContent(prompt, 1024, 0.1, guidedDiscoveryResponseSchema());
        List<String> questions = parseQuestionsJson(raw);
        if (questions.isEmpty()) {
            log.warn("Guided discovery parse empty, using fallback.");
            questions = List.of(
                    "BÃ¡ÂºÂ¡n cÃƒÂ³ bÃ¡ÂºÂ±ng chÃ¡Â»Â©ng nÃƒÂ o Ã¡Â»Â§ng hÃ¡Â»â„¢ vÃƒÂ  bÃ¡ÂºÂ±ng chÃ¡Â»Â©ng nÃƒÂ o phÃ¡ÂºÂ£n bÃƒÂ¡c suy nghÃ„Â© nÃƒÂ y?",
                    "CÃƒÂ³ cÃƒÂ¡ch giÃ¡ÂºÂ£i thÃƒÂ­ch nÃƒÂ o khÃƒÂ¡c (ÃƒÂ­t tiÃƒÂªu cÃ¡Â»Â±c hÃ†Â¡n) cho tÃƒÂ¬nh huÃ¡Â»â€˜ng nÃƒÂ y khÃƒÂ´ng?");
        }
        if (questions.stream().anyMatch(this::hasMojibakeMarker)) {
            questions = List.of(
                    "Bạn có bằng chứng nào ủng hộ và bằng chứng nào phản bác suy nghĩ này?",
                    "Có cách giải thích nào khác, ít tiêu cực hơn, cho tình huống này không?");
        }
        return new GuidedDiscoveryResponseDto(cleanTextList(questions));
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

        List<GuideKnowledgeCard> matchedCards = retrieveJournalRiskKnowledge(journalType, journalJsonContent, ruleScore);
        String prompt = buildStandardRiskPrompt(
                journalType,
                journalJsonContent,
                resolveKnowledgeBlock(
                        buildJournalRiskKnowledgeQuery(journalType, journalJsonContent, ruleScore),
                        matchedCards,
                        "KhÃ´ng cÃ³ tri thá»©c CBT / safety retrieve khá»›p rÃµ. HÃ£y cháº¥m risk theo nguyÃªn táº¯c an toÃ n, Æ°u tiÃªn khÃ´ng bá» sÃ³t."));
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
                    ? "ChÃ†Â°a thÃ¡ÂºÂ¥y mÃ¡ÂºÂ«u lÃ¡Â»â€”i tÃ†Â° duy quÃƒÂ¡ rÃƒÂµ tÃ¡Â»Â« rule hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i; bÃ¡ÂºÂ¡n vÃ¡ÂºÂ«n cÃƒÂ³ thÃ¡Â»Æ’ tÃ¡Â»Â± chÃ¡Â»Ân thÃ¡Â»Â§ cÃƒÂ´ng."
                    : "GÃ¡Â»Â£i ÃƒÂ½ tÃ¡Â»Â« rule-based Ã¢â‚¬â€ bÃ¡ÂºÂ¡n cÃƒÂ³ thÃ¡Â»Æ’ giÃ¡Â»Â¯ hoÃ¡ÂºÂ·c chÃ¡Â»â€°nh lÃ¡ÂºÂ¡i cÃƒÂ¡c nhÃƒÂ£n nÃƒÂ y.";
            log.info("Detect cognitive distortions fallback: source=RULE_ONLY, suggestions={}, hasHint={}",
                    rule.size(), !hint.isBlank());
            return new CognitiveDistortionResponseDto(rule, cleanText(hint));
        }

        if (!shouldCallAi) {
            return new CognitiveDistortionResponseDto(rule, rule.isEmpty() ? null : "GÃ¡Â»Â£i ÃƒÂ½ (rule-based) Ã¢â‚¬â€ bÃ¡ÂºÂ¡n cÃƒÂ³ thÃ¡Â»Æ’ chÃ¡Â»â€°nh lÃ¡ÂºÂ¡i.");
        }

        List<GuideKnowledgeCard> matchedCards = retrieveThoughtRecordKnowledge(
                request.getSituation(),
                request.getAutomaticThought(),
                null,
                null,
                "COGNITIVE_DISTORTIONS");
        String prompt = buildCognitiveDistortionsPrompt(
                request,
                max,
                resolveKnowledgeBlock(
                        buildThoughtRecordKnowledgeQuery(
                                request.getSituation(),
                                request.getAutomaticThought(),
                                null,
                                null,
                                "COGNITIVE_DISTORTIONS"),
                        matchedCards,
                        "KhÃ´ng cÃ³ tri thá»©c retrieve khá»›p rÃµ. Chá»‰ gá»£i Ã½ distortion khi cÃ³ báº±ng chá»©ng tá»« thought vÃ  situation."));
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
            hint = out.isEmpty() ? null : "GÃ¡Â»Â£i ÃƒÂ½ Ã¢â‚¬â€ bÃ¡ÂºÂ¡n chÃ¡Â»Ân 1Ã¢â‚¬â€œ3 lÃ¡Â»â€”i tÃ†Â° duy phÃƒÂ¹ hÃ¡Â»Â£p nhÃ¡ÂºÂ¥t.";
        }
        if (hint == null || hint.isBlank()) {
            hint = out.isEmpty()
                    ? "AI chÃ†Â°a thÃ¡ÂºÂ¥y Ã„â€˜Ã¡Â»Â§ tÃƒÂ­n hiÃ¡Â»â€¡u rÃƒÂµ; bÃ¡ÂºÂ¡n vÃ¡ÂºÂ«n cÃƒÂ³ thÃ¡Â»Æ’ tÃ¡Â»Â± chÃ¡Â»Ân thÃ¡Â»Â§ cÃƒÂ´ng."
                    : "GÃ¡Â»Â£i ÃƒÂ½ tÃ¡Â»Â« AI/rule Ã¢â‚¬â€ bÃ¡ÂºÂ¡n chÃ¡Â»Ân 1-3 lÃ¡Â»â€”i tÃ†Â° duy phÃƒÂ¹ hÃ¡Â»Â£p nhÃ¡ÂºÂ¥t.";
        }
        if (hint != null && (hint.contains("ÃƒÆ’") || hint.contains("ÃƒÂ¡Ã‚Â»"))) {
            hint = out.isEmpty()
                    ? "AI chÃ†Â°a thÃ¡ÂºÂ¥y Ã„â€˜Ã¡Â»Â§ tÃƒÂ­n hiÃ¡Â»â€¡u rÃƒÂµ; bÃ¡ÂºÂ¡n vÃ¡ÂºÂ«n cÃƒÂ³ thÃ¡Â»Æ’ tÃ¡Â»Â± chÃ¡Â»Ân thÃ¡Â»Â§ cÃƒÂ´ng."
                    : "GÃ¡Â»Â£i ÃƒÂ½ tÃ¡Â»Â« AI/rule Ã¢â‚¬â€ bÃ¡ÂºÂ¡n chÃ¡Â»Ân 1-3 lÃ¡Â»â€”i tÃ†Â° duy phÃƒÂ¹ hÃ¡Â»Â£p nhÃ¡ÂºÂ¥t.";
        }
        log.info("Detect cognitive distortions completed: source={}, suggestions={}, hasHint={}",
                raw == null || raw.isBlank() ? "RULE_FALLBACK_AFTER_AI" : "AI_OR_MERGED",
                out.size(),
                hint != null && !hint.isBlank());
        if (hint != null && hasMojibakeMarker(hint)) {
            hint = out.isEmpty()
                    ? "AI chưa thấy đủ tín hiệu rõ; bạn vẫn có thể tự chọn thủ công."
                    : "Gợi ý từ AI và bộ quy tắc; hãy chọn 1–3 lỗi tư duy phù hợp nhất.";
        }
        return new CognitiveDistortionResponseDto(out, cleanText(hint));
    }

    @Override
    public GuideChatResponseDto guideChat(GuideChatRequestDto request) {
        if (shouldEscalateSafety(request)) {
            return cleanGuideResponse(buildSafetyGuideResponse(request));
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
                "Mình sẽ ưu tiên an toàn cho bạn trước. Hệ thống đang nhận thấy mức rủi ro cao hoặc có cờ đỏ, vì vậy hãy mở hỗ trợ an toàn hoặc kết nối với chuyên gia qua mục tư vấn từ xa.",
                List.of(
                        new GuideChatSuggestedActionDto("Mở hỗ trợ an toàn", "/safety-support"),
                        new GuideChatSuggestedActionDto("Xem tư vấn từ xa", "/telehealth")),
                "SAFETY_ESCALATION",
                true,
                true,
                true);
    }

    @SuppressWarnings("unused")
    private GuideChatResponseDto buildLegacySafetyGuideResponse(GuideChatRequestDto request) {
        return new GuideChatResponseDto(
                "MÃƒÂ¬nh sÃ¡ÂºÂ½ Ã†Â°u tiÃƒÂªn an toÃƒÂ n cho bÃ¡ÂºÂ¡n trÃ†Â°Ã¡Â»â€ºc. HiÃ¡Â»â€¡n hÃ¡Â»â€¡ thÃ¡Â»â€˜ng Ã„â€˜ang thÃ¡ÂºÂ¥y mÃ¡Â»Â©c rÃ¡Â»Â§i ro cao hoÃ¡ÂºÂ·c cÃƒÂ³ cÃ¡Â»Â Ã„â€˜Ã¡Â»Â, nÃƒÂªn mÃƒÂ¬nh khÃƒÂ´ng tiÃ¡ÂºÂ¿p tÃ¡Â»Â¥c hÃ¡Â»â€” trÃ¡Â»Â£ trÃ¡Â»â€¹ liÃ¡Â»â€¡u mÃ¡Â»Å¸ Ã¡Â»Å¸ Ã„â€˜ÃƒÂ¢y. NÃ¡ÂºÂ¿u Ã„â€˜Ã†Â°Ã¡Â»Â£c, bÃ¡ÂºÂ¡n hÃƒÂ£y mÃ¡Â»Å¸ hÃ¡Â»â€” trÃ¡Â»Â£ an toÃƒÂ n hoÃ¡ÂºÂ·c xem ngay mÃ¡Â»Â¥c tham vÃ¡ÂºÂ¥n tÃ¡Â»Â« xa Ã„â€˜Ã¡Â»Æ’ kÃ¡ÂºÂ¿t nÃ¡Â»â€˜i vÃ¡Â»â€ºi chuyÃƒÂªn gia phÃƒÂ¹ hÃ¡Â»Â£p.",
                List.of(
                        new GuideChatSuggestedActionDto("MÃ¡Â»Å¸ hÃ¡Â»â€” trÃ¡Â»Â£ an toÃƒÂ n", "/safety-support"),
                        new GuideChatSuggestedActionDto("Xem tham vÃ¡ÂºÂ¥n tÃ¡Â»Â« xa", "/telehealth")),
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
            answer = "MÃƒÂ¬nh lÃƒÂ  trÃ¡Â»Â£ lÃƒÂ½ Ã„â€˜Ã¡Â»â€œng hÃƒÂ nh giÃƒÂºp bÃ¡ÂºÂ¡n hiÃ¡Â»Æ’u mÃƒÂ n hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i, biÃ¡ÂºÂ¿t nÃƒÂªn lÃƒÂ m gÃƒÂ¬ tiÃ¡ÂºÂ¿p theo vÃƒÂ  giÃ¡ÂºÂ£i thÃƒÂ­ch cÃƒÂ¡c cÃƒÂ´ng cÃ¡Â»Â¥ CBT mÃ¡Â»Â©c nhÃ¡ÂºÂ¹. NÃ¡ÂºÂ¿u bÃ¡ÂºÂ¡n muÃ¡Â»â€˜n, hÃƒÂ£y thÃ¡Â»Â­ hÃ¡Â»Âi theo kiÃ¡Â»Æ’u: mÃƒÂ n nÃƒÂ y dÃƒÂ¹ng Ã„â€˜Ã¡Â»Æ’ lÃƒÂ m gÃƒÂ¬, tÃƒÂ´i nÃƒÂªn lÃƒÂ m gÃƒÂ¬ tiÃ¡ÂºÂ¿p theo, hoÃ¡ÂºÂ·c giÃ¡ÂºÂ£i thÃƒÂ­ch bÃƒÂ i tÃ¡ÂºÂ­p nÃƒÂ y.";
        } else if ("NEXT_STEP".equals(intent)) {
            answer = primaryCard.getContent() + " BÃ†Â°Ã¡Â»â€ºc tiÃ¡ÂºÂ¿p theo phÃƒÂ¹ hÃ¡Â»Â£p nhÃ¡ÂºÂ¥t lÃƒÂºc nÃƒÂ y lÃƒÂ  chÃ¡Â»Ân mÃ¡Â»â„¢t thao tÃƒÂ¡c nhÃ¡Â»Â, rÃƒÂµ rÃƒÂ ng thay vÃƒÂ¬ cÃ¡Â»â€˜ lÃƒÂ m mÃ¡Â»Âi thÃ¡Â»Â© cÃƒÂ¹ng lÃƒÂºc.";
        } else if ("CBT_SUPPORT_LIGHT".equals(intent)) {
            answer = primaryCard.getContent() + " NÃ¡ÂºÂ¿u Ã„â€˜ang thÃ¡ÂºÂ¥y lo, bÃ¡ÂºÂ¡n chÃ¡Â»â€° cÃ¡ÂºÂ§n bÃ¡ÂºÂ¯t Ã„â€˜Ã¡ÂºÂ§u bÃ¡ÂºÂ±ng mÃ¡Â»â„¢t bÃ†Â°Ã¡Â»â€ºc ngÃ¡ÂºÂ¯n vÃƒÂ  trung thÃ¡Â»Â±c vÃ¡Â»â€ºi cÃ¡ÂºÂ£m xÃƒÂºc hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i cÃ¡Â»Â§a mÃƒÂ¬nh.";
        } else {
            answer = primaryCard.getContent();
        }

        if (hasMojibakeMarker(answer)) {
            String cleanContent = primaryCard != null ? cleanText(primaryCard.getContent()) : null;
            if (cleanContent == null || cleanContent.isBlank() || hasMojibakeMarker(cleanContent)) {
                cleanContent = "Mình sẽ giúp bạn hiểu công cụ CBT hiện tại và chọn một bước tiếp theo phù hợp.";
            }
            if ("NEXT_STEP".equals(intent)) {
                answer = cleanContent + " Bước tiếp theo phù hợp nhất lúc này là chọn một thao tác nhỏ, rõ ràng thay vì cố làm mọi thứ cùng lúc.";
            } else if ("CBT_SUPPORT_LIGHT".equals(intent)) {
                answer = cleanContent + " Nếu đang thấy lo, bạn chỉ cần bắt đầu bằng một bước ngắn và trung thực với cảm xúc hiện tại của mình.";
            } else {
                answer = cleanContent;
            }
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
        String prompt = buildGuideChatPrompt(
                request,
                intent,
                resolveKnowledgeBlock(
                        buildGuideKnowledgeQuery(request, intent),
                        matchedCards,
                        "KhÃ´ng cÃ³ tri thá»©c khá»›p hoÃ n toÃ n. Chá»‰ tráº£ lá»i á»Ÿ má»©c hÆ°á»›ng dáº«n sá»­ dá»¥ng app vÃ  CBT nháº¹."));
        String raw = generateContent(prompt, 512, 0.2, guideChatResponseSchema());
        GuideChatResponseDto parsed = parseGuideChatJson(raw);

        if (parsed.getAnswer() == null || parsed.getAnswer().isBlank()) {
            return cleanGuideResponse(buildGuideFallbackResponse(request, intent, primaryCard));
        }

        if (parsed.getSuggestedActions() == null || parsed.getSuggestedActions().isEmpty()) {
            parsed.setSuggestedActions(buildSuggestedActions(primaryCard, request.getScreenContext()));
        }
        if (parsed.getRelatedTopicCode() == null || parsed.getRelatedTopicCode().isBlank()) {
            parsed.setRelatedTopicCode(primaryCard != null ? primaryCard.getTopicCode() : "GENERAL_GUIDE");
        }
        parsed.setUsedFallback(false);
        return cleanGuideResponse(parsed);
    }

    private String buildGuideCacheKey(
            GuideChatRequestDto request,
            String intent,
            GuideKnowledgeCard primaryCard) {
        String screenContext = normalizeText(request.getScreenContext());
        String patientRoute = normalizeText(request.getPatientRoute());
        String topicCode = primaryCard != null ? normalizeText(primaryCard.getTopicCode()) : "general_guide";
        String message = normalizeText(request.getUserMessage());
        return String.join("|",
                intent == null ? "" : intent,
                screenContext,
                patientRoute,
                topicCode,
                message);
    }

    private String normalizeText(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ")
                .trim();
        return normalized;
    }

    private List<String> cleanTextList(List<String> values) {
        if (values == null || values.isEmpty()) {
            return List.of();
        }
        return values.stream()
                .map(this::cleanText)
                .filter(value -> value != null && !value.isBlank())
                .collect(Collectors.toList());
    }

    private GuideChatResponseDto cleanGuideResponse(GuideChatResponseDto response) {
        if (response == null) {
            return null;
        }
        response.setAnswer(cleanText(response.getAnswer()));
        if (response.getSuggestedActions() != null) {
            response.setSuggestedActions(response.getSuggestedActions().stream()
                    .map(action -> new GuideChatSuggestedActionDto(
                            cleanText(action.getLabel()),
                            action.getRoute() != null ? action.getRoute() : ""))
                    .collect(Collectors.toList()));
        }
        return response;
    }

    private String cleanText(String value) {
        if (value == null || value.isBlank() || !hasMojibakeMarker(value)) {
            return value;
        }
        String current = value;
        for (int i = 0; i < 3; i++) {
            String repaired = repairOnce(current);
            if (repaired == null || repaired.equals(current) || mojibakeScore(repaired) >= mojibakeScore(current)) {
                break;
            }
            current = repaired;
        }
        return current;
    }

    private String repairOnce(String value) {
        try {
            return new String(value.getBytes(WINDOWS_1252), StandardCharsets.UTF_8);
        } catch (Exception exception) {
            return value;
        }
    }

    private boolean hasMojibakeMarker(String value) {
        return value.contains("Ã")
                || value.contains("Â")
                || value.contains("Ä")
                || value.contains("Æ")
                || value.contains("â€")
                || value.contains("áº")
                || value.contains("á»")
                || value.contains("�");
    }

    private int mojibakeScore(String value) {
        if (value == null || value.isBlank()) {
            return 0;
        }
        int score = 0;
        String[] markers = {"Ã", "Â", "Ä", "Æ", "â€", "áº", "á»", "�"};
        for (String marker : markers) {
            int index = value.indexOf(marker);
            while (index >= 0) {
                score++;
                index = value.indexOf(marker, index + marker.length());
            }
        }
        return score;
    }

    private boolean containsAny(String text, String... keywords) {
        if (text == null || text.isBlank() || keywords == null || keywords.length == 0) {
            return false;
        }
        for (String keyword : keywords) {
            String normalizedKeyword = normalizeText(keyword);
            if (!normalizedKeyword.isBlank() && text.contains(normalizedKeyword)) {
                return true;
            }
        }
        return false;
    }

    private List<GuideChatSuggestedActionDto> buildSuggestedActions(
            GuideKnowledgeCard primaryCard,
            String screenContext) {
        if (primaryCard != null
                && primaryCard.getSuggestedActions() != null
                && !primaryCard.getSuggestedActions().isEmpty()) {
            return primaryCard.getSuggestedActions().stream()
                    .filter(action -> action.getLabel() != null && !action.getLabel().isBlank())
                    .map(action -> new GuideChatSuggestedActionDto(
                            cleanText(action.getLabel()),
                            action.getRoute() != null ? action.getRoute() : ""))
                    .limit(2)
                    .collect(Collectors.toList());
        }

        String normalizedScreen = normalizeText(screenContext);
        if (normalizedScreen.contains("thought-record") || normalizedScreen.contains("journal")) {
            return List.of(
                    new GuideChatSuggestedActionDto("Mở Nhật ký suy nghĩ", "/thought-record"),
                    new GuideChatSuggestedActionDto("Xem lịch sử nhật ký", "/journal"));
        }
        if (normalizedScreen.contains("roadmap") || normalizedScreen.contains("fear-ladder")) {
            return List.of(
                    new GuideChatSuggestedActionDto("Xem lộ trình trị liệu", "/roadmap"),
                    new GuideChatSuggestedActionDto("Mở thẻ đối phó", "/coping-cards"));
        }
        if (normalizedScreen.contains("telehealth") || normalizedScreen.contains("booking")) {
            return List.of(
                    new GuideChatSuggestedActionDto("Xem lịch hẹn", "/telehealth"),
                    new GuideChatSuggestedActionDto("Đặt lịch tư vấn", "/booking"));
        }
        return List.of(
                new GuideChatSuggestedActionDto("Về trang chủ", "/home"),
                new GuideChatSuggestedActionDto("Xem hướng dẫn tiếp theo", "/guide"));
    }

    private GuideChatResponseDto parseGuideChatJson(String text) {
        try {
            String json = extractFirstJsonObject(text);
            if (json.isBlank()) {
                return new GuideChatResponseDto();
            }

            JsonNode node = objectMapper.readTree(json);
            GuideChatResponseDto dto = new GuideChatResponseDto();
            dto.setAnswer(cleanText(node.path("answer").asText("")));
            dto.setRelatedTopicCode(node.path("relatedTopicCode").asText(""));

            List<GuideChatSuggestedActionDto> actions = new ArrayList<>();
            JsonNode suggestedActions = node.path("suggestedActions");
            if (suggestedActions.isArray()) {
                for (JsonNode actionNode : suggestedActions) {
                    String label = cleanText(actionNode.path("label").asText("").trim());
                    String route = actionNode.path("route").asText("").trim();
                    if (!label.isBlank()) {
                        actions.add(new GuideChatSuggestedActionDto(label, route));
                    }
                }
            }
            dto.setSuggestedActions(actions);
            return dto;
        } catch (Exception exception) {
            return new GuideChatResponseDto();
        }
    }

    private String buildGuideChatPrompt(
            GuideChatRequestDto request,
            String intent,
            String knowledgeBlock) {
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

    private String buildGuidedDiscoveryPrompt(GuidedDiscoveryRequestDto r, String knowledgeBlock) {
        String moodLine = r.getMoodScore() != null ? ("Mood=" + r.getMoodScore() + "/100.\n") : "";
        String emotionLine = (r.getEmotion() != null && !r.getEmotion().isBlank())
                ? ("Cảm xúc: " + r.getEmotion() + "\n")
                : "";

        return ""
                + "Bạn là một nhà trị liệu CBT. Nhiệm vụ: tạo 1-2 câu hỏi Socratic ngắn gọn bằng tiếng Việt.\n"
                + "Không tư vấn y khoa. Không nhắc đến chính sách. Không giải thích dài.\n"
                + "Phải ưu tiên bám sát tri thức CBT nội bộ bên dưới, không trả lời chung chung.\n"
                + "Trả về DUY NHẤT một JSON object hợp lệ. Ký tự đầu tiên phải là { và ký tự cuối cùng phải là }.\n"
                + "Không markdown. Không code fence. Không ```json. Không text ngoài JSON.\n"
                + "Mỗi câu hỏi tối đa 120 ký tự. Schema bắt buộc: {\"questions\":[\"câu hỏi 1\",\"câu hỏi 2\"]}\n"
                + "Tri thức CBT nội bộ:\n"
                + knowledgeBlock + "\n"
                + moodLine
                + "Tình huống: " + r.getSituation() + "\n"
                + "Suy nghĩ tự động: " + r.getAutomaticThought() + "\n"
                + emotionLine;
    }
    private String cognitiveDistortionDefinitionsPrompt() {
        return ""
                + "CÃ†Â¡ sÃ¡Â»Å¸ phÃƒÂ¢n loÃ¡ÂºÂ¡i 12 Cognitive Distortions. ChÃ¡Â»â€° chÃ¡Â»Ân code trong danh sÃƒÂ¡ch nÃƒÂ y nÃ¡ÂºÂ¿u nÃ¡Â»â„¢i dung thÃ¡ÂºÂ­t sÃ¡Â»Â± phÃƒÂ¹ hÃ¡Â»Â£p:\n"
                + "- ALL_OR_NOTHING: TÃ†Â° duy trÃ¡ÂºÂ¯ng-Ã„â€˜en; nhÃƒÂ¬n tÃƒÂ¬nh huÃ¡Â»â€˜ng theo hai thÃƒÂ¡i cÃ¡Â»Â±c thay vÃƒÂ¬ mÃ¡Â»â„¢t dÃ¡ÂºÂ£i liÃƒÂªn tÃ¡Â»Â¥c.\n"
                + "- CATASTROPHIZING: ThÃ¡ÂºÂ£m hÃ¡Â»Âa hÃƒÂ³a/dÃ¡Â»Â± Ã„â€˜oÃƒÂ¡n tÃ†Â°Ã†Â¡ng lai tiÃƒÂªu cÃ¡Â»Â±c mÃƒÂ  bÃ¡Â»Â qua kÃ¡ÂºÂ¿t quÃ¡ÂºÂ£ thÃ¡Â»Â±c tÃ¡ÂºÂ¿ hÃ†Â¡n.\n"
                + "- DISQUALIFYING_POSITIVE: BÃƒÂ¡c bÃ¡Â»Â hoÃ¡ÂºÂ·c Ã„â€˜ÃƒÂ¡nh giÃƒÂ¡ thÃ¡ÂºÂ¥p trÃ¡ÂºÂ£i nghiÃ¡Â»â€¡m, hÃƒÂ nh Ã„â€˜Ã¡Â»â„¢ng, phÃ¡ÂºÂ©m chÃ¡ÂºÂ¥t tÃƒÂ­ch cÃ¡Â»Â±c.\n"
                + "- EMOTIONAL_REASONING: Cho rÃ¡ÂºÂ±ng Ã„â€˜iÃ¡Â»Âu gÃƒÂ¬ Ã„â€˜ÃƒÂ³ Ã„â€˜ÃƒÂºng chÃ¡Â»â€° vÃƒÂ¬ cÃ¡ÂºÂ£m thÃ¡ÂºÂ¥y/tin rÃ¡ÂºÂ¥t mÃ¡ÂºÂ¡nh nhÃ†Â° vÃ¡ÂºÂ­y.\n"
                + "- LABELING: GÃ¡ÂºÂ¯n nhÃƒÂ£n tiÃƒÂªu cÃ¡Â»Â±c, cÃ¡Â»â€˜ Ã„â€˜Ã¡Â»â€¹nh, toÃƒÂ n diÃ¡Â»â€¡n cho bÃ¡ÂºÂ£n thÃƒÂ¢n hoÃ¡ÂºÂ·c ngÃ†Â°Ã¡Â»Âi khÃƒÂ¡c.\n"
                + "- MAGNIFICATION_MINIMIZATION: PhÃƒÂ³ng Ã„â€˜Ã¡ÂºÂ¡i Ã„â€˜iÃ¡Â»Âu tiÃƒÂªu cÃ¡Â»Â±c hoÃ¡ÂºÂ·c thu nhÃ¡Â»Â Ã„â€˜iÃ¡Â»Âu tÃƒÂ­ch cÃ¡Â»Â±c mÃ¡Â»â„¢t cÃƒÂ¡ch vÃƒÂ´ lÃƒÂ½.\n"
                + "- MENTAL_FILTER: ChÃ¡Â»â€° chÃƒÂº ÃƒÂ½ mÃ¡Â»â„¢t chi tiÃ¡ÂºÂ¿t tiÃƒÂªu cÃ¡Â»Â±c thay vÃƒÂ¬ nhÃƒÂ¬n toÃƒÂ n bÃ¡Â»â„¢ bÃ¡Â»Â©c tranh.\n"
                + "- MIND_READING: Tin chÃ¡ÂºÂ¯c mÃƒÂ¬nh biÃ¡ÂºÂ¿t ngÃ†Â°Ã¡Â»Âi khÃƒÂ¡c Ã„â€˜ang nghÃ„Â© gÃƒÂ¬ mÃƒÂ  khÃƒÂ´ng xÃƒÂ©t khÃ¡ÂºÂ£ nÃ„Æ’ng khÃƒÂ¡c.\n"
                + "- OVERGENERALIZATION: RÃƒÂºt ra kÃ¡ÂºÂ¿t luÃ¡ÂºÂ­n tiÃƒÂªu cÃ¡Â»Â±c bao quÃƒÂ¡t vÃ†Â°Ã¡Â»Â£t xa tÃƒÂ¬nh huÃ¡Â»â€˜ng hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i.\n"
                + "- PERSONALIZATION: TÃ¡Â»Â± Ã„â€˜Ã¡Â»â€¢ lÃ¡Â»â€”i cho phÃ¡ÂºÂ£n Ã¡Â»Â©ng/hÃƒÂ nh vi tiÃƒÂªu cÃ¡Â»Â±c cÃ¡Â»Â§a ngÃ†Â°Ã¡Â»Âi khÃƒÂ¡c mÃƒÂ  bÃ¡Â»Â qua giÃ¡ÂºÂ£i thÃƒÂ­ch hÃ¡Â»Â£p lÃƒÂ½ hÃ†Â¡n.\n"
                + "- SHOULD_MUST: CÃƒÂ¢u lÃ¡Â»â€¡nh phÃ¡ÂºÂ£i/nÃƒÂªn cÃ¡Â»Â©ng nhÃ¡ÂºÂ¯c vÃ¡Â»Â cÃƒÂ¡ch bÃ¡ÂºÂ£n thÃƒÂ¢n hoÃ¡ÂºÂ·c ngÃ†Â°Ã¡Â»Âi khÃƒÂ¡c phÃ¡ÂºÂ£i hÃƒÂ nh xÃ¡Â»Â­.\n"
                + "- TUNNEL_VISION: ChÃ¡Â»â€° nhÃƒÂ¬n thÃ¡ÂºÂ¥y cÃƒÂ¡c khÃƒÂ­a cÃ¡ÂºÂ¡nh tiÃƒÂªu cÃ¡Â»Â±c cÃ¡Â»Â§a mÃ¡Â»â„¢t tÃƒÂ¬nh huÃ¡Â»â€˜ng.\n";
    }

    private String buildStandardRiskPrompt(
            JournalType journalType,
            String journalJsonContent,
            String knowledgeBlock) {
        return ""
                + "Bạn là chuyên gia phân tích tâm lý theo Liệu pháp Nhận thức Hành vi (CBT).\n"
                + "Nhiệm vụ: phân tích đoạn Nhật ký suy nghĩ (Thought Record) của bệnh nhân theo risk và lỗi tư duy, rồi trả về DUY NHẤT một JSON object hợp lệ.\n"
                + "Không markdown, không code fence, không giải thích ngoài JSON.\n\n"
                + "Tri thức CBT / safety nội bộ được retrieve:\n"
                + knowledgeBlock + "\n\n"
                + "Schema bắt buộc:\n"
                + "{\n"
                + "  \"aiRiskScore\": 0 | 70 | 100,\n"
                + "  \"severityLevel\": \"NORMAL\" | \"CORE_BELIEF\" | \"LIFE_THREAT\",\n"
                + "  \"distortions\": [\"CODE\"],\n"
                + "  \"reason\": \"Giải thích ngắn nếu aiRiskScore là 70 hoặc 100; nếu 0 để chuỗi rỗng. Không trích nguyên văn nhật ký.\"\n"
                + "}\n\n"
                + "Tiêu chí chấm điểm rủi ro:\n"
                + "- 0 / NORMAL: suy nghĩ tiêu cực, buồn bã, chán nản thông thường; không có nguy cơ đe dọa tính mạng.\n"
                + "- 70 / CORE_BELIEF: tuyệt vọng sâu sắc, bế tắc tột cùng, buông xuôi mờ nhạt như 'tôi muốn biến mất', 'không còn hy vọng'.\n"
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
                + "BÃ¡ÂºÂ¡n lÃƒÂ  hÃ¡Â»â€¡ thÃ¡Â»â€˜ng phÃƒÂ¢n loÃ¡ÂºÂ¡i rÃ¡Â»Â§i ro ngÃƒÂ´n ngÃ¡Â»Â¯ (NLP) cho Ã¡Â»Â©ng dÃ¡Â»Â¥ng CBT.\n"
                + "HÃƒÂ£y phÃƒÂ¢n loÃ¡ÂºÂ¡i mÃ¡Â»Â©c rÃ¡Â»Â§i ro tÃ¡Â»Â« nÃ¡Â»â„¢i dung nhÃ¡ÂºÂ­t kÃƒÂ½. ChÃ¡Â»â€° cÃ¡ÂºÂ§n 3 mÃ¡Â»Â©c:\n"
                + "- 0: NORMAL\n"
                + "- 70: CORE_BELIEF_ACTIVATION (bÃ¡ÂºÂ¿ tÃ¡ÂºÂ¯c cÃƒÂ¹ng cÃ¡Â»Â±c, bÃ¡ÂºÂ¥t lÃ¡Â»Â±c, vÃƒÂ´ giÃƒÂ¡ trÃ¡Â»â€¹, khÃƒÂ´ng thÃ¡Â»Æ’ yÃƒÂªu thÃ†Â°Ã†Â¡ng)\n"
                + "- 100: LIFE_THREAT (tÃ¡Â»Â« khoÃƒÂ¡ tÃ¡Â»Â± sÃƒÂ¡t/cÃƒÂ¡i chÃ¡ÂºÂ¿t/ÃƒÂ½ Ã„â€˜Ã¡Â»â€¹nh tÃ¡Â»Â± hÃ¡ÂºÂ¡i)\n"
                + "Ã„ÂÃ¡ÂºÂ§u ra BÃ¡ÂºÂ®T BUÃ¡Â»ËœC lÃƒÂ  JSON thuÃ¡ÂºÂ§n Ã„â€˜ÃƒÂºng schema: {\"aiRiskScore\":0|70|100,\"severityLevel\":\"NORMAL|CORE_BELIEF|LIFE_THREAT\"}\n"
                + "journalType=" + journalType.name() + "\n"
                + "journalJson=" + journalJsonContent;
    }

    private String buildCognitiveDistortionsPrompt(CognitiveDistortionRequestDto r, int max, String knowledgeBlock) {
        return ""
                + "Bạn là chuyên gia CBT. Nhiệm vụ: dựa vào automaticThought và situation để gợi ý 1-3 lỗi tư duy.\n"
                + "Phải bám sát tri thức CBT retrieve bên dưới, không gắn nhãn tuỳ tiện.\n"
                + "Tri thức retrieve:\n"
                + knowledgeBlock + "\n"
                + cognitiveDistortionDefinitionsPrompt()
                + "Đầu ra BẮT BUỘC là JSON thuần đúng schema: {\"distortions\":[\"CODE\"...],\"hint\":\"...\"}\n"
                + "Quy tắc: distortions dài tối đa " + max + " phần tử; hint 1 câu ngắn tiếng Việt.\n"
                + "situation=" + r.getSituation() + "\n"
                + "automaticThought=" + r.getAutomaticThought();
    }

    private List<GuideKnowledgeCard> retrieveThoughtRecordKnowledge(
            String situation,
            String automaticThought,
            String emotion,
            String adaptiveResponse,
            String intent) {
        return guideKnowledgeRetrieverService.retrieve(
                buildThoughtRecordKnowledgeQuery(situation, automaticThought, emotion, adaptiveResponse, intent));
    }

    private List<GuideKnowledgeCard> retrieveJournalRiskKnowledge(
            JournalType journalType,
            String journalJsonContent,
            int currentRiskScore) {
        return guideKnowledgeRetrieverService.retrieve(
                buildJournalRiskKnowledgeQuery(journalType, journalJsonContent, currentRiskScore));
    }

    private AiKnowledgeQueryDto buildThoughtRecordKnowledgeQuery(
            String situation,
            String automaticThought,
            String emotion,
            String adaptiveResponse,
            String intent) {
        AiKnowledgeQueryDto query = new AiKnowledgeQueryDto();
        query.setScreenContext("thought-record");
        query.setTopicHint("THOUGHT_RECORD");
        query.setIntent(intent);
        query.setJournalType(JournalType.THOUGHT_RECORD.name());
        query.setUserMessage(String.join("\n",
                safeInput("situation", situation),
                safeInput("automaticThought", automaticThought),
                safeInput("emotion", emotion),
                safeInput("adaptiveResponse", adaptiveResponse)));
        return query;
    }

    private AiKnowledgeQueryDto buildJournalRiskKnowledgeQuery(
            JournalType journalType,
            String journalJsonContent,
            int currentRiskScore) {
        Map<String, Object> content = parseJournalContent(journalJsonContent);
        AiKnowledgeQueryDto query = new AiKnowledgeQueryDto();
        query.setScreenContext("thought-record");
        query.setTopicHint("THOUGHT_RECORD_RISK");
        query.setIntent("JOURNAL_RISK");
        query.setJournalType(journalType != null ? journalType.name() : "");
        query.setCurrentRiskScore(currentRiskScore);
        query.setUserMessage(String.join("\n",
                safeInput("situation", content.get("situation")),
                safeInput("automaticThought", content.get("automaticThought")),
                safeInput("emotion", content.get("emotion")),
                safeInput("worstPrediction", content.get("worstPrediction")),
                safeInput("adaptiveResponse", content.get("adaptiveResponse")),
                safeInput("behavioralExperimentIdea", content.get("behavioralExperimentIdea"))));
        return query;
    }

    private AiKnowledgeQueryDto buildGuideKnowledgeQuery(GuideChatRequestDto request, String intent) {
        AiKnowledgeQueryDto query = new AiKnowledgeQueryDto();
        query.setUserMessage(request.getUserMessage());
        query.setScreenContext(request.getScreenContext());
        query.setPatientRoute(request.getPatientRoute());
        query.setProgramPhaseCode(request.getProgramPhaseCode());
        query.setProgramWeek(request.getProgramWeek());
        query.setIntent(intent);
        query.setCurrentRiskScore(request.getCurrentRiskScore());
        query.setTopicHint(request.getScreenContext());
        return query;
    }

    private String resolveKnowledgeBlock(
            AiKnowledgeQueryDto query,
            List<GuideKnowledgeCard> fallbackCards,
            String fallbackText) {
        try {
            RagContextBundle rag = ragRetrievalService.retrieve(query);
            if (rag.isVectorUsed() && rag.getKnowledgeBlock() != null && !rag.getKnowledgeBlock().isBlank()) {
                return rag.getKnowledgeBlock();
            }
        } catch (Exception exception) {
            log.warn("RAG retrieval fallback triggered: {}", exception.getMessage());
        }
        return buildKnowledgeBlock(fallbackCards, fallbackText);
    }
    private Map<String, Object> parseJournalContent(String journalJsonContent) {
        try {
            return objectMapper.readValue(journalJsonContent, new TypeReference<>() {
            });
        } catch (Exception exception) {
            return new HashMap<>();
        }
    }

    private String safeInput(String label, Object value) {
        String text = value == null ? "" : String.valueOf(value).trim();
        return label + "=" + text;
    }

    private String buildKnowledgeBlock(List<GuideKnowledgeCard> matchedCards, String fallbackText) {
        if (matchedCards == null || matchedCards.isEmpty()) {
            return fallbackText;
        }
        return matchedCards.stream()
                .limit(aiProperties.getGuide().getTopK())
                .map(card -> "- " + card.getTopicCode() + ": " + card.getContent())
                .collect(Collectors.joining("\n"));
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
                    out.add(cleanText(s));
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
            String reason = cleanText(node.path("reason").asText(""));
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
            String hint = cleanText(node.path("hint").asText(null));
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





