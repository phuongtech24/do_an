package com.reconnect.mindhealth.modules.ai.service;

import java.text.Normalizer;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.dto.AiKnowledgeQueryDto;
import com.reconnect.mindhealth.modules.ai.model.RagContextBundle;
import com.reconnect.mindhealth.modules.ai.model.VectorSearchQuery;
import com.reconnect.mindhealth.modules.ai.model.VectorSearchResult;

@Service
public class RagRetrievalService {

    private final AiProperties aiProperties;
    private final IEmbeddingService embeddingService;
    private final IVectorStoreService vectorStoreService;

    public RagRetrievalService(
            AiProperties aiProperties,
            IEmbeddingService embeddingService,
            IVectorStoreService vectorStoreService) {
        this.aiProperties = aiProperties;
        this.embeddingService = embeddingService;
        this.vectorStoreService = vectorStoreService;
    }

    public RagContextBundle retrieve(AiKnowledgeQueryDto input) {
        RagContextBundle bundle = new RagContextBundle();
        if (!aiProperties.getRag().isEnabled()) {
            return bundle;
        }

        VectorSearchQuery query = toQuery(input);
        List<Double> vector = embeddingService.embed(query.getText());
        if (vector == null || vector.isEmpty()) {
            return bundle;
        }

        List<VectorSearchResult> raw = vectorStoreService.search(vector, aiProperties.getRag().getCandidateLimit());
        if (raw.isEmpty()) {
            return bundle;
        }

        List<VectorSearchResult> ranked = raw.stream()
                .peek(result -> result.setFinalScore(result.getVectorScore() + metadataBoost(result, query)))
                .filter(result -> result.getVectorScore() >= query.getMinScore())
                .sorted(Comparator.comparingDouble(VectorSearchResult::getFinalScore).reversed())
                .limit(query.getTopK())
                .collect(Collectors.toList());

        if (ranked.isEmpty()) {
            return bundle;
        }

        bundle.setVectorUsed(true);
        bundle.setResults(ranked);
        bundle.setKnowledgeBlock(ranked.stream()
                .map(result -> "- [" + result.getChunk().getSourceType() + "/" + result.getChunk().getTopicCode() + "] "
                        + result.getChunk().getContent())
                .collect(Collectors.joining("\n")));
        return bundle;
    }

    private VectorSearchQuery toQuery(AiKnowledgeQueryDto input) {
        VectorSearchQuery query = new VectorSearchQuery();
        query.setText(String.join("\n",
                safeLine("message", input.getUserMessage()),
                safeLine("screenContext", input.getScreenContext()),
                safeLine("patientRoute", input.getPatientRoute()),
                safeLine("programPhaseCode", input.getProgramPhaseCode()),
                safeLine("intent", input.getIntent()),
                safeLine("journalType", input.getJournalType()),
                safeLine("topicHint", input.getTopicHint())));
        query.setScreenContext(normalize(input.getScreenContext()));
        query.setPatientRoute(normalize(input.getPatientRoute()));
        query.setProgramPhaseCode(normalize(input.getProgramPhaseCode()));
        query.setIntent(normalize(input.getIntent()));
        query.setJournalType(normalize(input.getJournalType()));
        query.setTopicHint(normalize(input.getTopicHint()));
        query.setTopK(aiProperties.getRag().getTopK());
        query.setMinScore(aiProperties.getRag().getMinScore());
        return query;
    }

    private double metadataBoost(VectorSearchResult result, VectorSearchQuery query) {
        double boost = 0d;
        if (matches(result.getChunk().getScreenScope(), query.getScreenContext())) {
            boost += 0.15d;
        }
        if (matches(result.getChunk().getRouteScope(), query.getPatientRoute())) {
            boost += 0.10d;
        }
        if (matches(result.getChunk().getPhaseScope(), query.getProgramPhaseCode())) {
            boost += 0.05d;
        }
        if (matches(result.getChunk().getIntentScope(), query.getIntent())) {
            boost += 0.08d;
        }
        if (matches(result.getChunk().getJournalTypes(), query.getJournalType())) {
            boost += 0.08d;
        }
        if (!query.getTopicHint().isBlank() && query.getTopicHint().equals(normalize(result.getChunk().getTopicCode()))) {
            boost += 0.10d;
        }
        return boost;
    }

    private boolean matches(List<String> values, String actual) {
        if (values == null || values.isEmpty() || actual == null || actual.isBlank()) {
            return false;
        }
        return values.stream().map(this::normalize).anyMatch(actual::equals);
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('\u0111', 'd')
                .replace('\u0110', 'D');
        return normalized.toLowerCase(Locale.ROOT).trim();
    }

    private String safeLine(String label, String value) {
        return label + "=" + (value == null ? "" : value.trim());
    }
}
