package com.reconnect.mindhealth.modules.roadmap.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.roadmap.entity.PatientGoal;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalType;

public class PatientGoalDto {
    private UUID id;
    private UUID patientId;
    private PatientGoalType goalType;
    private String description;
    private PatientGoalStatus status;

    public PatientGoalDto() {
    }

    public PatientGoalDto(PatientGoal entity) {
        this.id = entity.getId();
        this.patientId = entity.getPatientProfile() != null ? entity.getPatientProfile().getId() : null;
        this.goalType = entity.getGoalType();
        this.description = entity.getDescription();
        this.status = entity.getStatus();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public PatientGoalType getGoalType() { return goalType; }
    public void setGoalType(PatientGoalType goalType) { this.goalType = goalType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public PatientGoalStatus getStatus() { return status; }
    public void setStatus(PatientGoalStatus status) { this.status = status; }
}
