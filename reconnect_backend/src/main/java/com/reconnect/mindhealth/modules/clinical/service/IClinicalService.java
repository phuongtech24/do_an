package com.reconnect.mindhealth.modules.clinical.service;

import java.util.UUID;

import com.reconnect.mindhealth.modules.clinical.dto.GoalSettingDto;
import com.reconnect.mindhealth.modules.clinical.dto.OnboardingStatusDto;

public interface IClinicalService {
    GoalSettingDto saveGoals(GoalSettingDto dto);
    GoalSettingDto getGoals(UUID patientId);
    void completePsychoeducation(UUID patientId);
    OnboardingStatusDto getOnboardingStatus(UUID patientId);
}
