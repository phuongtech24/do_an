package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class OnboardingStatusDto {
    private UUID patientId;
    private boolean hasBaselinePhq9;
    private boolean hasGoals;
    private boolean hasCompletedPsychoeducation;

    public OnboardingStatusDto() {
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public boolean isHasBaselinePhq9() {
        return hasBaselinePhq9;
    }

    public void setHasBaselinePhq9(boolean hasBaselinePhq9) {
        this.hasBaselinePhq9 = hasBaselinePhq9;
    }

    public boolean isHasGoals() {
        return hasGoals;
    }

    public void setHasGoals(boolean hasGoals) {
        this.hasGoals = hasGoals;
    }

    public boolean isHasCompletedPsychoeducation() {
        return hasCompletedPsychoeducation;
    }

    public void setHasCompletedPsychoeducation(boolean hasCompletedPsychoeducation) {
        this.hasCompletedPsychoeducation = hasCompletedPsychoeducation;
    }
}

