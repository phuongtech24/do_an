package com.reconnect.mindhealth.modules.ai.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatFeedbackRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatResponseDto;
import com.reconnect.mindhealth.modules.ai.service.AiChatHistoryService;
import com.reconnect.mindhealth.modules.ai.service.IAiAssistantService;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    private static final Logger log = LoggerFactory.getLogger(AiController.class);

    private final IAiAssistantService aiAssistantService;
    private final AuthContextService authContextService;
    private final AiChatHistoryService aiChatHistoryService;

    public AiController(
            IAiAssistantService aiAssistantService,
            AuthContextService authContextService,
            AiChatHistoryService aiChatHistoryService) {
        this.aiAssistantService = aiAssistantService;
        this.authContextService = authContextService;
        this.aiChatHistoryService = aiChatHistoryService;
    }

    /**
     * POST /api/ai/guided-discovery
     * Returns 1-2 Socratic questions (CBT) for the user's Thought Record flow.
     */
    @PostMapping("/guided-discovery")
    public ResponseEntity<ApiResponse<GuidedDiscoveryResponseDto>> guidedDiscovery(
            @Validated @RequestBody GuidedDiscoveryRequestDto request) {
        GuidedDiscoveryResponseDto result = aiAssistantService.guidedDiscovery(request);
        return ResponseEntity.ok(ApiResponse.success("OK", result));
    }

    /**
     * POST /api/ai/cognitive-distortions
     * Returns 1-3 suggested cognitive distortion labels (codes) for Step 4.
     */
    @PostMapping("/cognitive-distortions")
    public ResponseEntity<ApiResponse<CognitiveDistortionResponseDto>> cognitiveDistortions(
            @Validated @RequestBody CognitiveDistortionRequestDto request) {
        log.info("AI cognitive distortions request: situationChars={}, thoughtChars={}",
                request.getSituation() != null ? request.getSituation().trim().length() : 0,
                request.getAutomaticThought() != null ? request.getAutomaticThought().trim().length() : 0);
        CognitiveDistortionResponseDto result = aiAssistantService.detectCognitiveDistortions(request);
        log.info("AI cognitive distortions response: suggestions={}, hasHint={}",
                result.getDistortions() != null ? result.getDistortions().size() : 0,
                result.getHint() != null && !result.getHint().isBlank());
        return ResponseEntity.ok(ApiResponse.success("OK", result));
    }

    @PostMapping("/guide-chat")
    public ResponseEntity<ApiResponse<GuideChatResponseDto>> guideChat(
            @Validated @RequestBody GuideChatRequestDto request) {
        GuideChatResponseDto result = aiAssistantService.guideChat(request);
        try {
            User currentUser = authContextService.requireCurrentUser();
            aiChatHistoryService.attachTrackingAndPersist(currentUser, request, result);
        } catch (Exception exception) {
            log.debug("Skip AI chat history persistence bootstrap: {}", exception.getMessage());
        }
        return ResponseEntity.ok(ApiResponse.success("OK", result));
    }

    @PostMapping("/guide-chat/feedback")
    public ResponseEntity<ApiResponse<Void>> submitGuideChatFeedback(
            @Validated @RequestBody GuideChatFeedbackRequestDto request) {
        User currentUser = authContextService.requireCurrentUser();
        aiChatHistoryService.saveFeedback(currentUser, request);
        return ResponseEntity.ok(ApiResponse.success("OK", null));
    }
}
