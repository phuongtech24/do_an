package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.List;
import java.util.UUID;

public class GoalSettingDto {
    private UUID patientId;
    private List<String> goals;

    public GoalSettingDto() {
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public List<String> getGoals() {
        return goals;
    }

    public void setGoals(List<String> goals) {
        this.goals = goals;
    }
}

