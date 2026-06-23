package com.reconnect.mindhealth.modules.roadmap.service;

import java.util.UUID;

import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramStateDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapSafetyOverlayDto;

public interface IRoadmapService {
    RoadmapProgramStateDto getProgramState(UUID patientId);
    RoadmapSafetyOverlayDto getSafetyOverlay(UUID patientId);
}
