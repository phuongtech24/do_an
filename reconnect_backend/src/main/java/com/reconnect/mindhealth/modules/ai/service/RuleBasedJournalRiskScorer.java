package com.reconnect.mindhealth.modules.ai.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.dto.JournalAiRiskResultDto;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;

@Component
public class RuleBasedJournalRiskScorer {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Very lightweight heuristic scorer (offline), used to reduce AI calls.
     * Returns one of: 0 / 70 / 100.
     */
    public JournalAiRiskResultDto score(JournalType journalType, String journalJsonContent) {
        if (journalType == null || journalJsonContent == null || journalJsonContent.isBlank()) {
            return new JournalAiRiskResultDto(0, "NORMAL");
        }

        String normalized = normalize(extractAllText(journalJsonContent));
        if (normalized.isBlank()) {
            return new JournalAiRiskResultDto(0, "NORMAL");
        }

        // LIFE_THREAT signals => 100 (never downgrade by rule)
        if (containsAny(normalized, lifeThreatKeywords())) {
            return new JournalAiRiskResultDto(100, "LIFE_THREAT");
        }

        // CORE_BELIEF activation signals => 70
        if (containsAny(normalized, coreBeliefKeywords())) {
            return new JournalAiRiskResultDto(70, "CORE_BELIEF");
        }

        return new JournalAiRiskResultDto(0, "NORMAL");
    }

    private String extractAllText(String journalJsonContent) {
        try {
            Map<String, Object> parsed = objectMapper.readValue(journalJsonContent, new TypeReference<>() {
            });
            StringBuilder sb = new StringBuilder();
            for (Object v : parsed.values()) {
                if (v == null) {
                    continue;
                }
                if (v instanceof String s) {
                    if (!s.isBlank()) {
                        sb.append(' ').append(s);
                    }
                } else {
                    sb.append(' ').append(String.valueOf(v));
                }
            }
            return sb.toString().trim();
        } catch (Exception e) {
            // Fallback: treat raw JSON as text.
            return journalJsonContent;
        }
    }

    private String normalize(String text) {
        if (text == null) {
            return "";
        }
        String lower = text.toLowerCase(Locale.ROOT).trim();
        String decomposed = Normalizer.normalize(lower, Normalizer.Form.NFD);
        // Remove diacritics
        String noMarks = decomposed.replaceAll("\\p{M}+", "");
        // Keep letters/numbers/spaces only for simple matching
        return noMarks.replaceAll("[^a-z0-9\\s]", " ").replaceAll("\\s+", " ").trim();
    }

    private boolean containsAny(String haystack, List<String> needles) {
        for (String n : needles) {
            if (n != null && !n.isBlank() && haystack.contains(n)) {
                return true;
            }
        }
        return false;
    }

    private List<String> lifeThreatKeywords() {
        List<String> k = new ArrayList<>();
        k.add("tu tu");
        k.add("tu sat");
        k.add("muon chet");
        k.add("toi muon chet");
        k.add("cai chet");
        k.add("ket lieu");
        k.add("tu hai");
        k.add("tu lam hai minh");
        k.add("chet di");
        return k;
    }

    private List<String> coreBeliefKeywords() {
        List<String> k = new ArrayList<>();
        k.add("be tac");
        k.add("khong con loi thoat");
        k.add("bat luc");
        k.add("vo gia tri");
        k.add("khong the duoc yeu thuong");
        k.add("khong ai yeu");
        k.add("khong ai can toi");
        k.add("toi that bai");
        k.add("toi vo dung");
        return k;
    }
}

