package com.reconnect.mindhealth.modules.journal.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.common.util.EncryptionUtil;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.journal.dto.JournalDto;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;
import com.reconnect.mindhealth.modules.journal.repository.JournalRepository;
import com.reconnect.mindhealth.modules.journal.service.IJournalService;
import com.reconnect.mindhealth.modules.ai.dto.JournalAiRiskResultDto;
import com.reconnect.mindhealth.modules.ai.service.IAiAssistantService;

import jakarta.persistence.EntityNotFoundException;

/**
 * Service implementation for CBT Journal business logic operations.
 */
@Service
@Transactional
public class JournalServiceImpl implements IJournalService {

    private static final Logger log = LoggerFactory.getLogger(JournalServiceImpl.class);

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private IAiAssistantService aiAssistantService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public JournalDto saveJournal(JournalDto dto, UUID loggedInPatientId) {
        log.info("Saving journal for patient: {} with type: {}", loggedInPatientId, dto.getJournalType());

        PatientProfile patientProfile = patientProfileRepository.findById(loggedInPatientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại..."));

        try {
            // 1. Pack fields into map according to Journal Type
            Map<String, Object> contentMap = new HashMap<>();
            if (dto.getJournalType() == JournalType.THOUGHT_RECORD) {
                contentMap.put("situation", dto.getSituation());
                contentMap.put("automaticThought", dto.getAutomaticThought());
                contentMap.put("emotion", dto.getEmotion());
                contentMap.put("emotionScore", dto.getEmotionScore());
                contentMap.put("distortions", dto.getDistortions());
                contentMap.put("adaptiveResponse", dto.getAdaptiveResponse());
                contentMap.put("reRatedScore", dto.getReRatedScore());
            } else if (dto.getJournalType() == JournalType.CREDIT_LIST) {
                contentMap.put("content", dto.getContent());
            }

            // 2. Serialize to JSON string
            String jsonContent = objectMapper.writeValueAsString(contentMap);

            // 3. Encrypt JSON string
            String encryptedContent = EncryptionUtil.encrypt(jsonContent);

            // 4. Map to Entity
            Journal journal = new Journal();
            journal.setPatientProfile(patientProfile);
            journal.setJournalType(dto.getJournalType());
            journal.setContentEncrypted(encryptedContent);

            // 4.1 AI risk scoring (server-side). Falls back to safe defaults when AI disabled/unconfigured.
            JournalAiRiskResultDto ai = aiAssistantService.scoreJournalRisk(dto.getJournalType(), jsonContent);
            journal.setAiRiskScore(ai.getAiRiskScore() != null ? ai.getAiRiskScore() : 0);
            journal.setSeverityLevel(ai.getSeverityLevel() != null ? ai.getSeverityLevel() : "NORMAL");
            journal.setAiRiskDistortionsJson(objectMapper.writeValueAsString(
                    ai.getDistortions() != null ? ai.getDistortions() : List.of()));
            journal.setAiRiskReason(ai.getReason());

            // 5. Save in Database
            Journal savedJournal = journalRepository.save(journal);

            return convertToDto(savedJournal);

        } catch (Exception e) {
            log.error("Error saving journal", e);
            throw new RuntimeException("Lỗi lưu nhật ký: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<JournalDto> getJournalsByPatient(UUID patientId) {
        log.info("Retrieving journals list for patient: {}", patientId);
        List<Journal> journals = journalRepository.findJournalsByPatientId(patientId);
        List<JournalDto> dtos = new ArrayList<>();
        for (Journal j : journals) {
            dtos.add(convertToDto(j));
        }
        return dtos;
    }

    @Override
    @Transactional(readOnly = true)
    public JournalDto getJournalById(UUID id, UUID patientId) {
        log.info("Retrieving journal: {} for patient: {}", id, patientId);
        Journal journal = journalRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Nhật ký không tồn tại..."));

        // Security check: ensure this journal belongs to the requesting patient
        if (!journal.getPatientProfile().getId().equals(patientId)) {
            throw new SecurityException("Bạn không có quyền truy cập nhật ký này.");
        }

        return convertToDto(journal);
    }

    /**
     * Map entity to DTO and deserialize/decrypt content_encrypted fields dynamically.
     */
    @SuppressWarnings("unchecked")
    private JournalDto convertToDto(Journal entity) {
        JournalDto dto = new JournalDto(entity);
        if (entity.getAiRiskDistortionsJson() != null && !entity.getAiRiskDistortionsJson().isBlank()) {
            try {
                List<String> aiDistortions = objectMapper.readValue(
                        entity.getAiRiskDistortionsJson(),
                        objectMapper.getTypeFactory().constructCollectionType(List.class, String.class));
                dto.setAiRiskDistortions(aiDistortions);
            } catch (Exception e) {
                log.warn("Error parsing AI risk distortions for journal id: {}", entity.getId(), e);
            }
        }
        if (entity.getContentEncrypted() != null) {
            try {
                // 1. Decrypt AES-128
                String decryptedJson = EncryptionUtil.decrypt(entity.getContentEncrypted());

                // 2. Deserialize JSON to Map
                Map<String, Object> contentMap = objectMapper.readValue(decryptedJson, Map.class);
                if (contentMap != null) {
                    if (entity.getJournalType() == JournalType.THOUGHT_RECORD) {
                        dto.setSituation((String) contentMap.get("situation"));
                        dto.setAutomaticThought((String) contentMap.get("automaticThought"));
                        dto.setEmotion((String) contentMap.get("emotion"));
                        dto.setEmotionScore((Integer) contentMap.get("emotionScore"));
                        Object distortions = contentMap.get("distortions");
                        if (distortions instanceof List<?> list) {
                            List<String> codes = new ArrayList<>();
                            for (Object it : list) {
                                if (it != null) {
                                    String s = String.valueOf(it).trim();
                                    if (!s.isBlank()) {
                                        codes.add(s);
                                    }
                                }
                            }
                            dto.setDistortions(codes);
                        }
                        dto.setAdaptiveResponse((String) contentMap.get("adaptiveResponse"));
                        dto.setReRatedScore((Integer) contentMap.get("reRatedScore"));
                    } else if (entity.getJournalType() == JournalType.CREDIT_LIST) {
                        dto.setContent((String) contentMap.get("content"));
                    }
                }
            } catch (Exception e) {
                log.error("Error decrypting/parsing journal contents for id: {}", entity.getId(), e);
            }
        }
        return dto;
    }
}
