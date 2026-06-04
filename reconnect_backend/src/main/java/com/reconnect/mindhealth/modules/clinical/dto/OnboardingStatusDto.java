package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class OnboardingStatusDto {
    private UUID patientId;
    private boolean hasBaselineLsas;
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

    public boolean isHasBaselineLsas() {
        return hasBaselineLsas;
    }

    public void setHasBaselineLsas(boolean hasBaselineLsas) {
        this.hasBaselineLsas = hasBaselineLsas;
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
