package com.reconnect.mindhealth.modules.risk.service;

import java.util.UUID;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.risk.dto.TherapistPatientRiskAnalyticsDto;

public interface TherapistRiskAnalyticsService {

    TherapistPatientRiskAnalyticsDto getPatientRiskAnalytics(User therapistUser, UUID patientId, int days);
}
