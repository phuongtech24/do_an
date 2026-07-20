package com.reconnect.mindhealth.modules.ai.service;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
            "ai/clinical-rag/cognitive_distortions_explainer.md",
            "ai/clinical-rag/daily_checkin_and_safety_gate.md",
            "ai/clinical-rag/fear_ladder_and_behavioral_experiment.md",
            "ai/clinical-rag/onboarding_and_goal_setting.md",
            "ai/clinical-rag/telehealth_booking_and_conflict.md",
            "ai/clinical-rag/thought_record_6_steps.md",
            "ai/clinical-rag/cbt_thought_record_foundations.md",
            "ai/clinical-rag/social_anxiety_maintenance_model.md",
            "ai/clinical-rag/behavioral_experiment_and_safety.md",
            "ai/clinical-rag/lsas_and_clinical_routing.md");
    private static final List<String> STRUCTURED_DOC_PATHS = List.of(
            "ai/clinical-rag/cbt_structured_knowledge.md");
    // Regex bóc tách khối JSON metadata ở cuối mỗi chunk: ```json ... ```
    private static final Pattern JSON_BLOCK_PATTERN = Pattern.compile("```json\\s*([\\s\\S]*?)\\s*```");

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
        chunks.addAll(loadStructuredDocChunks());

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

    /**
     * Phân tích file Structured Markdown với định dạng:
     * - Các chunk được ngăn cách bởi `---`
     * - Mỗi chunk kết thúc bằng khối ```json { metadata } ```
     * - Metadata JSON chứa: source_document, chapter_number, clinical_category, safety_level, target_feature
     */
    private List<VectorDocumentChunk> loadStructuredDocChunks() {
        List<VectorDocumentChunk> chunks = new ArrayList<>();
        for (String path : STRUCTURED_DOC_PATHS) {
            try (InputStream input = new ClassPathResource(path).getInputStream()) {
                String text = new String(input.readAllBytes(), StandardCharsets.UTF_8);
                String normalized = text.replace("\r", "").trim();

                // Tách từng chunk theo dấu phân cách ---
                String[] rawChunks = normalized.split("(?m)^---\\s*$");
                int counter = 0;
                for (String rawChunk : rawChunks) {
                    String piece = rawChunk.trim();
                    if (piece.isBlank()) {
                        continue;
                    }

                    // Bóc tách khối JSON metadata
                    Matcher matcher = JSON_BLOCK_PATTERN.matcher(piece);
                    Map<String, String> meta = Map.of();
                    String contentOnly = piece;
                    if (matcher.find()) {
                        String jsonText = matcher.group(1).trim();
                        try {
                            meta = objectMapper.readValue(jsonText, new TypeReference<Map<String, String>>() {});
                        } catch (Exception parseEx) {
                            log.warn("Structured chunk JSON parse failed path={} chunk={} reason={}", path, counter, parseEx.getMessage());
                        }
                        // Loại bỏ khối JSON ra khỏi nội dung để tránh nhiễu embedding
                        contentOnly = piece.substring(0, matcher.start()).trim();
                    }

                    if (contentOnly.isBlank()) {
                        counter++;
                        continue;
                    }

                    // Ánh xạ metadata sang VectorDocumentChunk
                    String targetFeature = meta.getOrDefault("target_feature", "");
                    String clinicalCategory = meta.getOrDefault("clinical_category", "");
                    String safetyLevel = meta.getOrDefault("safety_level", "PATIENT_SAFE");
                    String sourceDoc = meta.getOrDefault("source_document", "");
                    String chapterNum = meta.getOrDefault("chapter_number", "");

                    VectorDocumentChunk chunk = new VectorDocumentChunk();
                    chunk.setId(deterministicId(path + "|" + counter++));
                    chunk.setSourceType("STRUCTURED_DOC");
                    chunk.setSourcePath(path);
                    // topicCode = target_feature (ví dụ THOUGHT_RECORD, COPING_CARDS, DAILY_CHECKIN)
                    chunk.setTopicCode(targetFeature.isBlank() ? topicCodeFromPath(path) : targetFeature);
                    chunk.setContent(contentOnly);
                    // intentScope = clinical_category (ví dụ COGNITIVE_RESTRUCTURING, EMOTIONAL_SOOTHING)
                    chunk.setIntentScope(clinicalCategory.isBlank() ? List.of() : List.of(clinicalCategory));
                    // keywords bao gồm cả safety level và nguồn tài liệu để tăng precision khi search
                    List<String> keywords = new ArrayList<>();
                    if (!safetyLevel.isBlank()) keywords.add(safetyLevel);
                    if (!sourceDoc.isBlank()) keywords.add(sourceDoc);
                    if (!chapterNum.isBlank()) keywords.add("chapter_" + chapterNum);
                    if (!clinicalCategory.isBlank()) keywords.add(clinicalCategory.toLowerCase());
                    chunk.setKeywords(keywords);
                    // screenScope suy ra từ target_feature
                    chunk.setScreenScope(inferScreenScopeFromFeature(targetFeature));
                    chunk.setJournalTypes(inferJournalTypesFromFeature(targetFeature));
                    chunks.add(chunk);
                }
                log.info("Structured doc ingested path={} chunksLoaded={}", path, chunks.size());
            } catch (Exception exception) {
                log.warn("Skip structured doc ingestion path={} reason={}", path, exception.getMessage());
            }
        }
        return chunks;
    }

    private List<String> inferScreenScopeFromFeature(String targetFeature) {
        if (targetFeature == null) return List.of();
        return switch (targetFeature.toUpperCase()) {
            case "THOUGHT_RECORD" -> List.of("thought-record", "journal");
            case "COPING_CARDS" -> List.of("coping-cards", "home");
            case "DAILY_CHECKIN" -> List.of("daily-checkin", "journal");
            default -> List.of();
        };
    }

    private List<String> inferJournalTypesFromFeature(String targetFeature) {
        if (targetFeature == null) return List.of();
        return switch (targetFeature.toUpperCase()) {
            case "THOUGHT_RECORD" -> List.of("THOUGHT_RECORD");
            case "DAILY_CHECKIN" -> List.of("DAILY_CHECKIN");
            default -> List.of();
        };
    }

    private List<String> splitIntoChunks(String text) {
        String normalized = text == null ? "" : text.replace("\r", "").trim();
        if (normalized.isBlank()) {
            return List.of();
        }
        List<String> chunks = new ArrayList<>();
        int chunkSize = aiProperties.getRag().getChunkSize();
        int overlap = aiProperties.getRag().getChunkOverlap();

        List<String> sections = List.of(normalized.split("(?m)(?=^#{1,3}\\s+)"));
        for (String section : sections) {
            List<String> paragraphs = List.of(section.trim().split("\n\\s*\n"));
            StringBuilder current = new StringBuilder();
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
            case "COGNITIVE_DISTORTIONS_EXPLAINER" -> List.of("cognitive distortions", "mind reading", "catastrophizing", "thought record");
            case "DAILY_CHECKIN_AND_SAFETY_GATE" -> List.of("daily check-in", "safety gate", "mood", "red flag", "thought record", "fear ladder");
            case "FEAR_LADDER_AND_BEHAVIORAL_EXPERIMENT" -> List.of("fear ladder", "behavioral experiment", "exposure", "prediction", "outcome", "learning");
            case "ONBOARDING_AND_GOAL_SETTING" -> List.of("onboarding", "goal setting", "social", "behavioral", "emotional", "personalization");
            case "TELEHEALTH_BOOKING_AND_CONFLICT" -> List.of("telehealth", "booking", "appointment", "conflict", "transaction", "unique constraint");
            case "THOUGHT_RECORD_6_STEPS" -> List.of("thought record", "6 steps", "automatic thought", "adaptive response", "emotion", "outcome");
            case "CBT_THOUGHT_RECORD_FOUNDATIONS" -> List.of("thought record", "automatic thought", "adaptive response", "cognitive restructuring");
            case "SOCIAL_ANXIETY_MAINTENANCE_MODEL" -> List.of("social anxiety", "anticipatory anxiety", "rumination", "safety behaviors");
            case "BEHAVIORAL_EXPERIMENT_AND_SAFETY" -> List.of("behavioral experiment", "prediction", "outcome", "learning", "safety");
            case "LSAS_AND_CLINICAL_ROUTING" -> List.of("lsas", "clinical routing", "red flag", "severity");
            default -> List.of();
        };
    }

    private List<String> inferScreenScope(String path) {
        return switch (topicCodeFromPath(path)) {
            case "COGNITIVE_DISTORTIONS_EXPLAINER" -> List.of("thought-record", "journal", "guide-chat");
            case "DAILY_CHECKIN_AND_SAFETY_GATE" -> List.of("daily-checkin", "home", "journal");
            case "FEAR_LADDER_AND_BEHAVIORAL_EXPERIMENT" -> List.of("roadmap", "fear-ladder", "behavioral-experiment");
            case "ONBOARDING_AND_GOAL_SETTING" -> List.of("goal-setting", "onboarding", "home");
            case "TELEHEALTH_BOOKING_AND_CONFLICT" -> List.of("telehealth", "booking", "appointments");
            case "THOUGHT_RECORD_6_STEPS" -> List.of("thought-record", "journal");
            case "CBT_THOUGHT_RECORD_FOUNDATIONS" -> List.of("thought-record", "journal");
            case "SOCIAL_ANXIETY_MAINTENANCE_MODEL" -> List.of("thought-record", "daily-checkin", "roadmap");
            case "BEHAVIORAL_EXPERIMENT_AND_SAFETY" -> List.of("roadmap", "behavioral-experiment");
            case "LSAS_AND_CLINICAL_ROUTING" -> List.of("lsas", "home");
            default -> List.of();
        };
    }

    private List<String> inferIntentScope(String path) {
        return switch (topicCodeFromPath(path)) {
            case "COGNITIVE_DISTORTIONS_EXPLAINER" -> List.of("COGNITIVE_DISTORTIONS", "GUIDED_DISCOVERY", "FEATURE_EXPLAINER");
            case "DAILY_CHECKIN_AND_SAFETY_GATE" -> List.of("FEATURE_EXPLAINER", "NEXT_STEP", "APP_GUIDE", "JOURNAL_RISK");
            case "FEAR_LADDER_AND_BEHAVIORAL_EXPERIMENT" -> List.of("FEATURE_EXPLAINER", "NEXT_STEP", "APP_GUIDE");
            case "ONBOARDING_AND_GOAL_SETTING" -> List.of("FEATURE_EXPLAINER", "APP_GUIDE", "NEXT_STEP");
            case "TELEHEALTH_BOOKING_AND_CONFLICT" -> List.of("FEATURE_EXPLAINER", "APP_GUIDE", "NEXT_STEP");
            case "THOUGHT_RECORD_6_STEPS" -> List.of("GUIDED_DISCOVERY", "COGNITIVE_DISTORTIONS", "FEATURE_EXPLAINER", "JOURNAL_RISK");
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
                || "THOUGHT_RECORD_6_STEPS".equals(topicCodeFromPath(path))
                        ? List.of("THOUGHT_RECORD")
                        : List.of();
    }
}
