package com.reconnect.mindhealth.modules.risk.service;

import java.util.UUID;

import com.reconnect.mindhealth.modules.risk.dto.RiskCalculationResultDto;

public interface IRiskScoringService {
    RiskCalculationResultDto calculateAndPersist(UUID patientId);
    int calculateAndPersistForAllActivePatients();
}

