package com.reconnect.mindhealth.modules.ai.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryResponseDto;
import com.reconnect.mindhealth.modules.ai.service.IAiAssistantService;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    private final IAiAssistantService aiAssistantService;

    public AiController(IAiAssistantService aiAssistantService) {
        this.aiAssistantService = aiAssistantService;
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
        CognitiveDistortionResponseDto result = aiAssistantService.detectCognitiveDistortions(request);
        return ResponseEntity.ok(ApiResponse.success("OK", result));
    }
}
