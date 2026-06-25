package com.reconnect.mindhealth.modules.ai.service;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.ai.dto.GuideChatFeedbackRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatResponseDto;
import com.reconnect.mindhealth.modules.ai.entity.AiChatFeedback;
import com.reconnect.mindhealth.modules.ai.entity.AiChatMessage;
import com.reconnect.mindhealth.modules.ai.entity.AiChatSession;
import com.reconnect.mindhealth.modules.ai.repository.AiChatFeedbackRepository;
import com.reconnect.mindhealth.modules.ai.repository.AiChatMessageRepository;
import com.reconnect.mindhealth.modules.ai.repository.AiChatSessionRepository;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AiChatHistoryService {

    private static final Logger log = LoggerFactory.getLogger(AiChatHistoryService.class);

    private final PatientProfileRepository patientProfileRepository;
    private final AiChatSessionRepository aiChatSessionRepository;
    private final AiChatMessageRepository aiChatMessageRepository;
    private final AiChatFeedbackRepository aiChatFeedbackRepository;

    public AiChatHistoryService(
            PatientProfileRepository patientProfileRepository,
            AiChatSessionRepository aiChatSessionRepository,
            AiChatMessageRepository aiChatMessageRepository,
            AiChatFeedbackRepository aiChatFeedbackRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.aiChatSessionRepository = aiChatSessionRepository;
        this.aiChatMessageRepository = aiChatMessageRepository;
        this.aiChatFeedbackRepository = aiChatFeedbackRepository;
    }

    public void attachTrackingAndPersist(User currentUser, GuideChatRequestDto request, GuideChatResponseDto response) {
        if (currentUser == null || currentUser.getRole() != Role.PATIENT) {
            return;
        }
        UUID sessionId = UUID.randomUUID();
        UUID assistantMessageId = UUID.randomUUID();
        response.setSessionId(sessionId);
        response.setMessageId(assistantMessageId);
        persistGuideChatAsync(currentUser.getId(), sessionId, UUID.randomUUID(), assistantMessageId, request, response);
    }

    @Async
    @Transactional
    public void persistGuideChatAsync(
            UUID patientId,
            UUID sessionId,
            UUID userMessageId,
            UUID assistantMessageId,
            GuideChatRequestDto request,
            GuideChatResponseDto response) {
        try {
            PatientProfile patient = patientProfileRepository.findById(patientId)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân cho AI chat: " + patientId));

            AiChatSession session = new AiChatSession();
            session.setId(sessionId);
            session.setPatientProfile(patient);
            session.setSessionType("GUIDE_CHAT");
            session.setScreenContext(blankToDefault(request.getScreenContext(), "general"));
            session.setStatus(response.isSafetyEscalation() ? "ESCALATED" : "COMPLETED");
            session.setStartedAt(LocalDateTime.now());
            session.setEndedAt(LocalDateTime.now());
            aiChatSessionRepository.save(session);

            AiChatMessage userMessage = new AiChatMessage();
            userMessage.setId(userMessageId);
            userMessage.setSession(session);
            userMessage.setSenderType("PATIENT");
            userMessage.setMessageText(blankToDefault(request.getUserMessage(), ""));
            userMessage.setUsedFallback(false);
            userMessage.setRelatedTopicCode(blankToDefault(response.getRelatedTopicCode(), "GENERAL_GUIDE"));
            userMessage.setSafetyEscalation(false);
            userMessage.setIntentDetected(detectIntent(request.getUserMessage()));
            aiChatMessageRepository.save(userMessage);

            AiChatMessage assistantMessage = new AiChatMessage();
            assistantMessage.setId(assistantMessageId);
            assistantMessage.setSession(session);
            assistantMessage.setSenderType("ASSISTANT");
            assistantMessage.setMessageText(blankToDefault(response.getAnswer(), ""));
            assistantMessage.setUsedFallback(response.isUsedFallback());
            assistantMessage.setRelatedTopicCode(blankToDefault(response.getRelatedTopicCode(), "GENERAL_GUIDE"));
            assistantMessage.setSafetyEscalation(response.isSafetyEscalation());
            assistantMessage.setIntentDetected(detectIntent(request.getUserMessage()));
            aiChatMessageRepository.save(assistantMessage);
        } catch (Exception exception) {
            log.warn("Skip persisting AI guide chat history: patientId={}, reason={}", patientId, exception.getMessage());
        }
    }

    @Transactional
    public void saveFeedback(User currentUser, GuideChatFeedbackRequestDto request) {
        if (currentUser == null || currentUser.getRole() != Role.PATIENT) {
            throw new SecurityException("Chỉ PATIENT mới được gửi feedback cho AI chat.");
        }
        if (request.getMessageId() == null) {
            throw new IllegalArgumentException("Thiếu messageId.");
        }

        PatientProfile patient = patientProfileRepository.findById(currentUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy hồ sơ bệnh nhân."));
        AiChatMessage message = aiChatMessageRepository.findById(request.getMessageId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy tin nhắn AI cần feedback."));

        AiChatFeedback feedback = new AiChatFeedback();
        feedback.setMessage(message);
        feedback.setPatientProfile(patient);
        feedback.setRating(request.getRating());
        feedback.setFeedbackText(request.getFeedbackText());
        aiChatFeedbackRepository.save(feedback);
    }

    private String blankToDefault(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private String detectIntent(String userMessage) {
        String normalized = normalizeText(userMessage);
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

    private boolean containsAny(String normalized, String... keywords) {
        for (String keyword : keywords) {
            if (normalized.contains(keyword)) {
                return true;
            }
        }
        return false;
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
}
