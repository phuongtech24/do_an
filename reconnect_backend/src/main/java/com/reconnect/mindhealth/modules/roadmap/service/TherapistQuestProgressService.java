package com.reconnect.mindhealth.modules.roadmap.service;

import java.util.UUID;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.roadmap.dto.TherapistPatientQuestProgressDto;

public interface TherapistQuestProgressService {

    TherapistPatientQuestProgressDto getProgress(User therapistUser, UUID patientId);
}
