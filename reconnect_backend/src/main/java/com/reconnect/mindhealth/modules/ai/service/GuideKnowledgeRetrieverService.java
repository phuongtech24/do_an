package com.reconnect.mindhealth.modules.ai.service;

import java.io.InputStream;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatRequestDto;
import com.reconnect.mindhealth.modules.ai.model.GuideKnowledgeCard;

@Service
public class GuideKnowledgeRetrieverService {

    private static final Logger log = LoggerFactory.getLogger(GuideKnowledgeRetrieverService.class);
    private static final Set<String> STOP_WORDS = Set.of(
            "toi", "ban", "la", "va", "hay", "cho", "voi", "trong", "tren", "duoc",
            "lam", "gi", "nao", "nay", "kia", "roi", "se", "can", "muon", "minh", "cua");
    private static final List<String> GUIDE_RESOURCE_PATHS = List.of(
            "ai/guide-knowledge-cards.json",
            "ai/guide-cbt-support-cards.json");

    private final AiProperties aiProperties;
    private final ObjectMapper objectMapper;
    private List<GuideKnowledgeCard> guideKnowledgeCards = List.of();

    public GuideKnowledgeRetrieverService(AiProperties aiProperties, ObjectMapper objectMapper) {
        this.aiProperties = aiProperties;
        this.objectMapper = objectMapper;
    }

    @PostConstruct
    void loadGuideKnowledgeCards() {
        List<GuideKnowledgeCard> loadedCards = new ArrayList<>();
        for (String path : GUIDE_RESOURCE_PATHS) {
            try (InputStream input = new ClassPathResource(path).getInputStream()) {
                List<GuideKnowledgeCard> cards = objectMapper.readValue(input, new TypeReference<List<GuideKnowledgeCard>>() {
                });
                loadedCards.addAll(cards);
                log.info("Loaded guide knowledge cards: path={}, count={}", path, cards.size());
            } catch (Exception exception) {
                log.warn("Unable to load guide knowledge cards from {}. {}", path, exception.getMessage());
            }
        }
        guideKnowledgeCards = List.copyOf(loadedCards);
        log.info("Guide retrieval corpus ready: totalCards={}", guideKnowledgeCards.size());
    }

    public List<GuideKnowledgeCard> retrieve(GuideChatRequestDto request) {
        if (!aiProperties.getGuide().isRetrievalEnabled()) {
            return List.of();
        }

        String screenContext = normalizeText(request.getScreenContext());
        String route = normalizeText(request.getPatientRoute());
        String phase = normalizeText(request.getProgramPhaseCode());
        String message = normalizeText(request.getUserMessage());
        Set<String> queryTerms = extractQueryTerms(message);

        return guideKnowledgeCards.stream()
                .map(card -> new ScoredCard(card, scoreCard(card, screenContext, route, phase, message, queryTerms)))
                .filter(scored -> scored.score() >= aiProperties.getGuide().getMinScore())
                .sorted(Comparator.comparingInt(ScoredCard::score).reversed()
                        .thenComparing(scored -> scored.card().getTopicCode(), String.CASE_INSENSITIVE_ORDER))
                .limit(aiProperties.getGuide().getTopK())
                .map(ScoredCard::card)
                .collect(Collectors.toList());
    }

    private int scoreCard(
            GuideKnowledgeCard card,
            String screenContext,
            String route,
            String phase,
            String message,
            Set<String> queryTerms) {
        int score = 0;
        AiProperties.Guide guide = aiProperties.getGuide();

        if (matchesScope(card.getScreenScope(), screenContext)) {
            score += guide.getScreenScopeWeight();
        }
        if (matchesScope(card.getRouteScope(), route)) {
            score += guide.getRouteScopeWeight();
        }
        if (matchesScope(card.getPhaseScope(), phase)) {
            score += guide.getPhaseScopeWeight();
        }
        if (card.getTopicCode() != null && message.contains(normalizeText(card.getTopicCode().replace('_', ' ')))) {
            score += guide.getTopicWeight();
        }
        if (card.getKeywords() != null) {
            for (String keyword : card.getKeywords()) {
                String normalizedKeyword = normalizeText(keyword);
                if (!normalizedKeyword.isBlank() && message.contains(normalizedKeyword)) {
                    score += guide.getKeywordWeight();
                }
            }
        }

        String normalizedContent = normalizeText(card.getContent());
        for (String term : queryTerms) {
            if (normalizedContent.contains(term)) {
                score += guide.getContentTermWeight();
            }
        }
        return score;
    }

    private Set<String> extractQueryTerms(String message) {
        if (message == null || message.isBlank()) {
            return Set.of();
        }
        String[] parts = message.split("[^a-z0-9]+");
        Set<String> terms = new LinkedHashSet<>();
        for (String part : parts) {
            if (part.length() < 3) {
                continue;
            }
            if (STOP_WORDS.contains(part)) {
                continue;
            }
            terms.add(part);
        }
        return terms;
    }

    private boolean matchesScope(List<String> values, String actual) {
        if (values == null || values.isEmpty() || actual == null || actual.isBlank()) {
            return false;
        }
        return values.stream()
                .map(this::normalizeText)
                .anyMatch(actual::equals);
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

    private record ScoredCard(GuideKnowledgeCard card, int score) {
    }
}
