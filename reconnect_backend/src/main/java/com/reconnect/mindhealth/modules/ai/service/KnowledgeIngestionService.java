package com.reconnect.mindhealth.modules.ai.service;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import jakarta.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.model.GuideKnowledgeCard;
import com.reconnect.mindhealth.modules.ai.model.VectorDocumentChunk;

@Service
public class KnowledgeIngestionService {

    private static final Logger log = LoggerFactory.getLogger(KnowledgeIngestionService.class);
    private static final List<String> JSON_CARD_PATHS = List.of(
            "ai/guide-knowledge-cards.json",
            "ai/guide-cbt-support-cards.json",
            "ai/thought-record-rag-cards.json");
    private static final List<String> CLINICAL_DOC_PATHS = List.of(
            "ai/clinical-rag/cbt_thought_record_foundations.md",
            "ai/clinical-rag/social_anxiety_maintenance_model.md",
            "ai/clinical-rag/behavioral_experiment_and_safety.md",
            "ai/clinical-rag/lsas_and_clinical_routing.md");

    private final AiProperties aiProperties;
    private final IEmbeddingService embeddingService;
    private final IVectorStoreService vectorStoreService;
    private final ObjectMapper objectMapper;

    public KnowledgeIngestionService(
            AiProperties aiProperties,
            IEmbeddingService embeddingService,
            IVectorStoreService vectorStoreService,
            ObjectMapper objectMapper) {
        this.aiProperties = aiProperties;
        this.embeddingService = embeddingService;
        this.vectorStoreService = vectorStoreService;
        this.objectMapper = objectMapper;
    }

    @PostConstruct
    void autoIngest() {
        if (aiProperties.getRag().isEnabled() && aiProperties.getRag().isAutoIngestOnStartup()) {
            try {
                reindexAll();
            } catch (Exception exception) {
                log.warn("RAG auto ingest skipped: {}", exception.getMessage());
            }
        }
    }

    public int reindexAll() {
        if (!aiProperties.getRag().isEnabled()) {
            return 0;
        }
        if (!vectorStoreService.ensureCollection()) {
            return 0;
        }

        List<VectorDocumentChunk> chunks = new ArrayList<>();
        chunks.addAll(loadCardChunks());
        chunks.addAll(loadClinicalDocChunks());

        List<VectorDocumentChunk> indexed = new ArrayList<>();
        List<List<Double>> vectors = new ArrayList<>();
        for (VectorDocumentChunk chunk : chunks) {
            List<Double> vector = embeddingService.embed(chunk.getContent());
            if (vector == null || vector.isEmpty()) {
                continue;
            }
            indexed.add(chunk);
            vectors.add(vector);
        }

        vectorStoreService.upsert(indexed, vectors);
        log.info("RAG knowledge reindex completed chunksIndexed={}", indexed.size());
        return indexed.size();
    }

    private List<VectorDocumentChunk> loadCardChunks() {
        List<VectorDocumentChunk> chunks = new ArrayList<>();
        for (String path : JSON_CARD_PATHS) {
            try (InputStream input = new ClassPathResource(path).getInputStream()) {
                List<GuideKnowledgeCard> cards = objectMapper.readValue(input, new TypeReference<List<GuideKnowledgeCard>>() {
                });
                for (GuideKnowledgeCard card : cards) {
                    VectorDocumentChunk chunk = new VectorDocumentChunk();
                    chunk.setId(deterministicId(path + "|" + card.getTopicCode()));
                    chunk.setSourceType("AI_CARD");
                    chunk.setSourcePath(path);
                    chunk.setTopicCode(card.getTopicCode());
                    chunk.setScreenScope(card.getScreenScope());
                    chunk.setRouteScope(card.getRouteScope());
                    chunk.setPhaseScope(card.getPhaseScope());
                    chunk.setIntentScope(card.getIntentScope());
                    chunk.setJournalTypes(card.getJournalTypes());
                    chunk.setKeywords(card.getKeywords());
                    chunk.setContent(card.getContent());
                    chunks.add(chunk);
                }
            } catch (Exception exception) {
                log.warn("Skip card ingestion path={} reason={}", path, exception.getMessage());
            }
        }
        return chunks;
    }

    private List<VectorDocumentChunk> loadClinicalDocChunks() {
        List<VectorDocumentChunk> chunks = new ArrayList<>();
        for (String path : CLINICAL_DOC_PATHS) {
            try (InputStream input = new ClassPathResource(path).getInputStream()) {
                String text = new String(input.readAllBytes(), StandardCharsets.UTF_8);
                int counter = 0;
                for (String piece : splitIntoChunks(text)) {
                    VectorDocumentChunk chunk = new VectorDocumentChunk();
                    chunk.setId(deterministicId(path + "|" + counter++));
                    chunk.setSourceType("CLINICAL_DOC");
                    chunk.setSourcePath(path);
                    chunk.setTopicCode(topicCodeFromPath(path));
                    chunk.setContent(piece);
                    chunk.setKeywords(extractKeywords(path));
                    chunk.setScreenScope(inferScreenScope(path));
                    chunk.setIntentScope(inferIntentScope(path));
                    chunk.setJournalTypes(inferJournalTypes(path));
                    chunks.add(chunk);
                }
            } catch (Exception exception) {
                log.warn("Skip clinical doc ingestion path={} reason={}", path, exception.getMessage());
            }
        }
        return chunks;
    }

    private List<String> splitIntoChunks(String text) {
        String normalized = text == null ? "" : text.replace("\r", "").trim();
        if (normalized.isBlank()) {
            return List.of();
        }
        List<String> paragraphs = List.of(normalized.split("\n\\s*\n"));
        List<String> chunks = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        int chunkSize = aiProperties.getRag().getChunkSize();
        int overlap = aiProperties.getRag().getChunkOverlap();

        for (String paragraph : paragraphs) {
            String p = paragraph.trim();
            if (p.isBlank()) {
                continue;
            }
            if (current.length() == 0) {
                current.append(p);
                continue;
            }
            if (current.length() + p.length() + 2 <= chunkSize) {
                current.append("\n\n").append(p);
            } else {
                chunks.add(current.toString());
                String previous = current.toString();
                String tail = previous.length() <= overlap ? previous : previous.substring(previous.length() - overlap);
                current = new StringBuilder(tail).append("\n\n").append(p);
            }
        }
        if (current.length() > 0) {
            chunks.add(current.toString());
        }
        return chunks;
    }

    private String deterministicId(String raw) {
        return UUID.nameUUIDFromBytes(raw.getBytes(StandardCharsets.UTF_8)).toString();
    }

    private String topicCodeFromPath(String path) {
        String base = path.substring(path.lastIndexOf('/') + 1).replace(".md", "");
        return base.toUpperCase();
    }

    private List<String> extractKeywords(String path) {
        return switch (topicCodeFromPath(path)) {
            case "CBT_THOUGHT_RECORD_FOUNDATIONS" -> List.of("thought record", "automatic thought", "adaptive response", "cognitive restructuring");
            case "SOCIAL_ANXIETY_MAINTENANCE_MODEL" -> List.of("social anxiety", "anticipatory anxiety", "rumination", "safety behaviors");
            case "BEHAVIORAL_EXPERIMENT_AND_SAFETY" -> List.of("behavioral experiment", "prediction", "outcome", "learning", "safety");
            case "LSAS_AND_CLINICAL_ROUTING" -> List.of("lsas", "clinical routing", "red flag", "severity");
            default -> List.of();
        };
    }

    private List<String> inferScreenScope(String path) {
        return switch (topicCodeFromPath(path)) {
            case "CBT_THOUGHT_RECORD_FOUNDATIONS" -> List.of("thought-record", "journal");
            case "SOCIAL_ANXIETY_MAINTENANCE_MODEL" -> List.of("thought-record", "daily-checkin", "roadmap");
            case "BEHAVIORAL_EXPERIMENT_AND_SAFETY" -> List.of("roadmap", "behavioral-experiment");
            case "LSAS_AND_CLINICAL_ROUTING" -> List.of("lsas", "home");
            default -> List.of();
        };
    }

    private List<String> inferIntentScope(String path) {
        return switch (topicCodeFromPath(path)) {
            case "CBT_THOUGHT_RECORD_FOUNDATIONS" -> List.of("GUIDED_DISCOVERY", "COGNITIVE_DISTORTIONS", "JOURNAL_RISK");
            case "SOCIAL_ANXIETY_MAINTENANCE_MODEL" -> List.of("GUIDED_DISCOVERY", "JOURNAL_RISK", "APP_GUIDE");
            case "BEHAVIORAL_EXPERIMENT_AND_SAFETY" -> List.of("FEATURE_EXPLAINER", "NEXT_STEP");
            case "LSAS_AND_CLINICAL_ROUTING" -> List.of("FEATURE_EXPLAINER", "NEXT_STEP", "APP_GUIDE");
            default -> List.of();
        };
    }

    private List<String> inferJournalTypes(String path) {
        return "CBT_THOUGHT_RECORD_FOUNDATIONS".equals(topicCodeFromPath(path))
                || "SOCIAL_ANXIETY_MAINTENANCE_MODEL".equals(topicCodeFromPath(path))
                        ? List.of("THOUGHT_RECORD")
                        : List.of();
    }
}
