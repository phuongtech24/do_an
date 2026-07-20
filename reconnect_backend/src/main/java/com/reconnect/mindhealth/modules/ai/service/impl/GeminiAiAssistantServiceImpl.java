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
import com.reconnect.mindhealth.modules.ai.service.GuideChatRoutingService;
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
    private final GuideChatRoutingService guideChatRoutingService;
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
            GuideChatRoutingService guideChatRoutingService,
            RagRetrievalService ragRetrievalService,
            RuleBasedCognitiveDistortionDetector ruleBasedCognitiveDistortionDetector,
            RuleBasedJournalRiskScorer ruleBasedJournalRiskScorer) {
        this.aiProperties = aiProperties;
        this.guideKnowledgeRetrieverService = guideKnowledgeRetrieverService;
        this.guideChatRoutingService = guideChatRoutingService;
        this.ragRetrievalService = ragRetrievalService;
        this.ruleBasedCognitiveDistortionDetector = ruleBasedCognitiveDistortionDetector;
        this.ruleBasedJournalRiskScorer = ruleBasedJournalRiskScorer;
    }

    @Override
    public GuidedDiscoveryResponseDto guidedDiscovery(GuidedDiscoveryRequestDto request) {
        List<String> fallbackQuestions = List.of(
                "Bang chung nao dang ung ho suy nghi nay, va bang chung nao dang phan bien lai no?",
                "Co cach giai thich nao khac, can bang hon va it tieu cuc hon, cho tinh huong nay khong?");
        if (!aiProperties.isEnabled()) {
            return new GuidedDiscoveryResponseDto(fallbackQuestions);
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
                        "Khong co tri thuc retrieve khop ro. Hay dat cau hoi CBT ngan, an toan va trung tinh."));
        String raw = generateContent(prompt, 1024, 0.1, guidedDiscoveryResponseSchema());
        List<String> questions = parseQuestionsJson(raw);
        if (questions.isEmpty() || questions.stream().anyMatch(this::hasMojibakeMarker)) {
            log.warn("Guided discovery parse empty or mojibake, using fallback.");
            questions = fallbackQuestions;
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
                        "Khong co tri thuc CBT hoac safety retrieve khop ro. Hay cham risk theo nguyen tac an toan, uu tien khong bo sot."));
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
                    ? "Chua thay mau loi tu duy qua ro tu bo quy tac hien tai; ban van co the tu chon thu cong."
                    : "Day la goi y tu bo quy tac; ban co the giu lai hoac chinh lai cac nhan nay.";
            log.info("Detect cognitive distortions fallback: source=RULE_ONLY, suggestions={}, hasHint={}",
                    rule.size(), !hint.isBlank());
            return new CognitiveDistortionResponseDto(rule, cleanText(hint));
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
                        "Khong co tri thuc retrieve khop ro. Chi goi y distortion khi co bang chung tu thought va situation."));
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
            hint = out.isEmpty()
                    ? "AI chua thay du tin hieu ro; ban van co the tu chon thu cong."
                    : "Day la goi y tu AI va bo quy tac; hay chon 1-3 loi tu duy phu hop nhat.";
        }
        if (hint == null || hint.isBlank()) {
            hint = out.isEmpty()
                    ? "AI chua thay du tin hieu ro; ban van co the tu chon thu cong."
                    : "Day la goi y tu AI va bo quy tac; hay chon 1-3 loi tu duy phu hop nhat.";
        }
        log.info("Detect cognitive distortions completed: source={}, suggestions={}, hasHint={}",
                raw == null || raw.isBlank() ? "RULE_FALLBACK_AFTER_AI" : "AI_OR_MERGED",
                out.size(),
                hint != null && !hint.isBlank());
        if (hint != null && hasMojibakeMarker(hint)) {
            hint = out.isEmpty()
                    ? "AI chua thay du tin hieu ro; ban van co the tu chon thu cong."
                    : "Day la goi y tu AI va bo quy tac; hay chon 1-3 loi tu duy phu hop nhat.";
        }
        return new CognitiveDistortionResponseDto(out, cleanText(hint));
    }

    @Override
    public GuideChatResponseDto guideChat(GuideChatRequestDto request) {
        if (shouldEscalateSafety(request)) {
            return cleanGuideResponse(buildSafetyGuideResponse(request));
        }

        String intent = guideChatRoutingService.detectIntent(request.getUserMessage());
        AiKnowledgeQueryDto knowledgeQuery = buildGuideKnowledgeQuery(request, intent);
        List<GuideKnowledgeCard> matchedCards = guideKnowledgeRetrieverService.retrieve(knowledgeQuery);
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
                "Minh se uu tien an toan cho ban truoc. He thong dang nhan thay muc rui ro cao hoac co co do, vi vay hay mo ho tro an toan hoac ket noi voi chuyen gia qua muc tu van tu xa.",
                List.of(
                        new GuideChatSuggestedActionDto("Mo ho tro an toan", "/safety-support"),
                        new GuideChatSuggestedActionDto("Xem tu van tu xa", "/telehealth")),
                "SAFETY_ESCALATION",
                true,
                true,
                true);
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
            answer = "Minh la tro ly dong hanh, giup ban hieu man hien tai, biet nen lam gi tiep theo va giai thich cac cong cu CBT o muc nhe. Neu muon, ban co the hoi: man nay dung de lam gi, toi nen lam gi tiep theo, hoac giai thich bai tap nay.";
        } else if ("NEXT_STEP".equals(intent)) {
            answer = primaryCard.getContent() + " Buoc tiep theo phu hop nhat luc nay la chon mot thao tac nho, ro rang thay vi co lam moi thu cung luc.";
        } else if ("CBT_SUPPORT_LIGHT".equals(intent)) {
            answer = primaryCard.getContent() + " Neu dang thay lo, ban chi can bat dau bang mot buoc ngan va trung thuc voi cam xuc hien tai cua minh.";
        } else {
            answer = primaryCard.getContent();
        }
        if (hasMojibakeMarker(answer)) {
            String cleanContent = primaryCard != null ? cleanText(primaryCard.getContent()) : null;
            if (cleanContent == null || cleanContent.isBlank() || hasMojibakeMarker(cleanContent)) {
                cleanContent = "Minh se giup ban hieu cong cu CBT hien tai va chon mot buoc tiep theo phu hop.";
            }
            if ("NEXT_STEP".equals(intent)) {
                answer = cleanContent + " Buoc tiep theo phu hop nhat luc nay la chon mot thao tac nho, ro rang thay vi co lam moi thu cung luc.";
            } else if ("CBT_SUPPORT_LIGHT".equals(intent)) {
                answer = cleanContent + " Neu dang thay lo, ban chi can bat dau bang mot buoc ngan va trung thuc voi cam xuc hien tai cua minh.";
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
                        "Khong co tri thuc khop hoan toan. Chi tra loi o muc huong dan su dung app va CBT nhe."));
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

        return """
                Ban la tro ly AI cua ung dung ReConnect MindHealth.
                Vai tro: giai thich chuc nang cua app, giai thich CBT o muc de hieu va goi y buoc tiep theo phu hop.
                Khong chan doan, khong ke thuoc, khong thay the bac si hay nha tri lieu.
                Neu noi ve AI, phai nhan manh AI chi ho tro va khong thay bac si.
                Chi tra loi dua tren tri thuc noi bo retrieve duoc va boi canh man hinh hien tai.
                Khong bia flow khong co trong he thong. Khong chuyen sang chu de khac neu tri thuc retrieve khong lien quan.
                Tra loi theo 3 y ngan: (1) giai thich khai niem/chuc nang, (2) he thong hien tai xu ly ra sao, (3) neu phu hop thi goi y buoc tiep theo.
                Cau tra loi dai khoang 80-180 tu. Toi da 2 goi y hanh dong.
                Tra ve DUY NHAT mot JSON object hop le theo schema.

                Tri thuc noi bo:
                %s

                Ngu canh:
                - screenContext: %s
                - patientRoute: %s
                - programWeek: %s
                - programPhaseCode: %s
                - intent: %s
                Cau hoi nguoi dung: %s
                """.formatted(
                knowledgeBlock,
                request.getScreenContext(),
                route,
                week,
                phase,
                intent,
                request.getUserMessage());
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
                ? ("Cam xuc: " + r.getEmotion() + "\n")
                : "";

        return """
                Ban la mot nha tri lieu CBT. Nhiem vu: tao 1-2 cau hoi Socratic ngan gon bang tieng Viet.
                Khong tu van y khoa. Khong nhac den chinh sach. Khong giai thich dai.
                Phai bam sat tri thuc CBT noi bo retrieve ben duoi, khong tra loi chung chung.
                Tra ve DUY NHAT mot JSON object hop le. Ky tu dau tien phai la { va ky tu cuoi cung phai la }.
                Khong markdown, khong code fence, khong text ngoai JSON.
                Moi cau hoi toi da 120 ky tu.
                Schema bat buoc: {"questions":["cau hoi 1","cau hoi 2"]}

                Tri thuc CBT noi bo:
                %s
                %sTinh huong: %s
                Suy nghi tu dong: %s
                %s
                """.formatted(
                knowledgeBlock,
                moodLine,
                r.getSituation(),
                r.getAutomaticThought(),
                emotionLine);
    }

    private String cognitiveDistortionDefinitionsPrompt() {
        return """
                Co so phan loai 12 cognitive distortions. Chi chon code khi that su phu hop voi noi dung:
                - ALL_OR_NOTHING: Tu duy trang-den, chi nhin hai cuc.
                - CATASTROPHIZING: Tham hoa hoa, du doan ket cuc xau nhat.
                - DISQUALIFYING_POSITIVE: Bac bo trai nghiem hoac diem tich cuc.
                - EMOTIONAL_REASONING: Tin dieu gi do dung chi vi minh cam thay rat manh.
                - LABELING: Gan nhan tieu cuc, co dinh cho ban than hoac nguoi khac.
                - MAGNIFICATION_MINIMIZATION: Phong dai dieu xau, thu nho dieu tot.
                - MENTAL_FILTER: Chi nhin mot chi tiet tieu cuc va bo qua toan canh.
                - MIND_READING: Cho rang minh biet nguoi khac nghi gi ma khong co bang chung.
                - OVERGENERALIZATION: Rut ra ket luan tieu cuc qua muc tu mot tinh huong.
                - PERSONALIZATION: Tu do loi cho minh qua muc khi xay ra van de.
                - SHOULD_MUST: Tu duy cung nhac voi cac cau phai/nen.
                - TUNNEL_VISION: Chi nhin thay mat xau cua tinh huong.
                """;
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
        return """
                Ban la he thong phan loai rui ro ngon ngu cho ung dung CBT.
                Hay phan loai muc rui ro tu noi dung nhat ky. Chi co 3 muc:
                - 0: NORMAL
                - 70: CORE_BELIEF_ACTIVATION (be tac, vo gia tri, buong xuoi mo nhat)
                - 100: LIFE_THREAT (y dinh tu sat, tu hai, nhac truc tiep den cai chet)
                Dau ra BAT BUOC la JSON thuan dung schema:
                {"aiRiskScore":0,"severityLevel":"NORMAL"}
                journalType=%s
                journalJson=%s
                """.formatted(journalType.name(), journalJsonContent);
    }

    private String buildCognitiveDistortionsPrompt(CognitiveDistortionRequestDto r, int max, String knowledgeBlock) {
        return """
                Ban la chuyen gia CBT. Nhiem vu: dua vao automaticThought va situation de goi y 1-3 loi tu duy.
                Phai bam sat tri thuc CBT retrieve ben duoi, khong gan nhan tuy tien.

                Tri thuc retrieve:
                %s

                %s
                Dau ra BAT BUOC la JSON thuan dung schema:
                {"distortions":["CODE"],"hint":"goi y ngan"}
                Quy tac: distortions toi da %d phan tu; hint la 1 cau ngan bang tieng Viet.
                situation=%s
                automaticThought=%s
                """.formatted(
                knowledgeBlock,
                cognitiveDistortionDefinitionsPrompt(),
                max,
                r.getSituation(),
                r.getAutomaticThought());
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
        query.setTopicHint(guideChatRoutingService.detectTopicHint(
                request.getUserMessage(),
                request.getScreenContext(),
                intent));
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
                    return text != null ? cleanText(text) : "";
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







