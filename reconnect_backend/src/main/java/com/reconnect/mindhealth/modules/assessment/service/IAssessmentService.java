package com.reconnect.mindhealth.modules.assessment.service;

import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.modules.assessment.dto.LsasSituationDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;

public interface IAssessmentService {
    List<LsasSituationDto> getLsasSituations();

    LsasSubmissionDto submitLsas(LsasSubmissionDto dto);

    boolean isLsasOnCoolDown(UUID patientId);

    List<LsasSubmissionDto> getLsasHistory(UUID patientId);

    UserMoodDto saveUserMood(UserMoodDto dto);
}
