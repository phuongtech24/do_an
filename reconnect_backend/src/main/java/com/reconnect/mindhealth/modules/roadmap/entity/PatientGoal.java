package com.reconnect.mindhealth.modules.roadmap.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalType;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "patient_goals")
public class PatientGoal extends BaseObject {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private PatientProfile patientProfile;

    @Enumerated(EnumType.STRING)
    @Column(name = "goal_type", nullable = false)
    private PatientGoalType goalType = PatientGoalType.GENERAL;

    @Column(name = "description", nullable = false, columnDefinition = "text")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private PatientGoalStatus status = PatientGoalStatus.ACTIVE;

    public PatientProfile getPatientProfile() { return patientProfile; }
    public void setPatientProfile(PatientProfile patientProfile) { this.patientProfile = patientProfile; }
    public PatientGoalType getGoalType() { return goalType; }
    public void setGoalType(PatientGoalType goalType) { this.goalType = goalType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public PatientGoalStatus getStatus() { return status; }
    public void setStatus(PatientGoalStatus status) { this.status = status; }
}
