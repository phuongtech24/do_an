package com.reconnect.mindhealth.modules.roadmap.service;

import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.modules.roadmap.dto.CompleteQuestRequest;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientQuestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramStateDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapSafetyOverlayDto;
import com.reconnect.mindhealth.modules.roadmap.dto.VerifyQuestProofResponseDto;

public interface IRoadmapService {
    List<PatientQuestDto> getDailyQuests(UUID patientId);
    List<PatientQuestDto> getQuestHistory(UUID patientId);
    RoadmapProgramStateDto getProgramState(UUID patientId);
    RoadmapSafetyOverlayDto getSafetyOverlay(UUID patientId);
    PatientQuestDto completeQuest(UUID patientId, UUID patientQuestId, CompleteQuestRequest request);
    VerifyQuestProofResponseDto verifyQuestProof(UUID patientId, UUID patientQuestId, byte[] imageBytes, String mimeType);
}
