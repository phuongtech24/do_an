package com.reconnect.mindhealth.modules.ai.service;

import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuidedDiscoveryResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.JournalAiRiskResultDto;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.CognitiveDistortionResponseDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatRequestDto;
import com.reconnect.mindhealth.modules.ai.dto.GuideChatResponseDto;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;

public interface IAiAssistantService {
    GuidedDiscoveryResponseDto guidedDiscovery(GuidedDiscoveryRequestDto request);

    JournalAiRiskResultDto scoreJournalRisk(JournalType journalType, String journalJsonContent);

    CognitiveDistortionResponseDto detectCognitiveDistortions(CognitiveDistortionRequestDto request);

    GuideChatResponseDto guideChat(GuideChatRequestDto request);
}
