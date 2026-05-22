package com.reconnect.mindhealth.modules.ai.service;

import com.reconnect.mindhealth.modules.ai.dto.QuestProofVisionResultDto;

public interface IQuestProofVisionService {
    QuestProofVisionResultDto verifyQuestProof(String questTitle, String questDescription, byte[] imageBytes,
            String mimeType);
}

