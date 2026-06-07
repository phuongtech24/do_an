package com.reconnect.mindhealth.modules.clinical.dto;

import java.util.UUID;

public class TherapistAssignmentStatusDto {
    private UUID patientId;
    private boolean assigned;
    private UUID therapistId;
    private String therapistName;
    private String message;
    private String carePhaseCode;
    private String carePhaseLabel;
    private String recommendedFrequencyLabel;
    private String recommendedPlanSummary;
    private String durationGuidance;
    private String recommendedPurposeCode;
    private boolean allowOverride;

    public TherapistAssignmentStatusDto() {
    }

    public TherapistAssignmentStatusDto(UUID patientId, boolean assigned, UUID therapistId, String therapistName, String message) {
        this.patientId = patientId;
        this.assigned = assigned;
        this.therapistId = therapistId;
        this.therapistName = therapistName;
        this.message = message;
    }

    public TherapistAssignmentStatusDto(UUID patientId, boolean assigned, UUID therapistId, String therapistName,
            String message, String carePhaseCode, String carePhaseLabel, String recommendedFrequencyLabel,
            String recommendedPlanSummary, String durationGuidance, String recommendedPurposeCode, boolean allowOverride) {
        this.patientId = patientId;
        this.assigned = assigned;
        this.therapistId = therapistId;
        this.therapistName = therapistName;
        this.message = message;
        this.carePhaseCode = carePhaseCode;
        this.carePhaseLabel = carePhaseLabel;
        this.recommendedFrequencyLabel = recommendedFrequencyLabel;
        this.recommendedPlanSummary = recommendedPlanSummary;
        this.durationGuidance = durationGuidance;
        this.recommendedPurposeCode = recommendedPurposeCode;
        this.allowOverride = allowOverride;
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public boolean isAssigned() {
        return assigned;
    }

    public void setAssigned(boolean assigned) {
        this.assigned = assigned;
    }

    public UUID getTherapistId() {
        return therapistId;
    }

    public void setTherapistId(UUID therapistId) {
        this.therapistId = therapistId;
    }

    public String getTherapistName() {
        return therapistName;
    }

    public void setTherapistName(String therapistName) {
        this.therapistName = therapistName;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getCarePhaseCode() {
        return carePhaseCode;
    }

    public void setCarePhaseCode(String carePhaseCode) {
        this.carePhaseCode = carePhaseCode;
    }

    public String getCarePhaseLabel() {
        return carePhaseLabel;
    }

    public void setCarePhaseLabel(String carePhaseLabel) {
        this.carePhaseLabel = carePhaseLabel;
    }

    public String getRecommendedFrequencyLabel() {
        return recommendedFrequencyLabel;
    }

    public void setRecommendedFrequencyLabel(String recommendedFrequencyLabel) {
        this.recommendedFrequencyLabel = recommendedFrequencyLabel;
    }

    public String getRecommendedPlanSummary() {
        return recommendedPlanSummary;
    }

    public void setRecommendedPlanSummary(String recommendedPlanSummary) {
        this.recommendedPlanSummary = recommendedPlanSummary;
    }

    public String getDurationGuidance() {
        return durationGuidance;
    }

    public void setDurationGuidance(String durationGuidance) {
        this.durationGuidance = durationGuidance;
    }

    public String getRecommendedPurposeCode() {
        return recommendedPurposeCode;
    }

    public void setRecommendedPurposeCode(String recommendedPurposeCode) {
        this.recommendedPurposeCode = recommendedPurposeCode;
    }

    public boolean isAllowOverride() {
        return allowOverride;
    }

    public void setAllowOverride(boolean allowOverride) {
        this.allowOverride = allowOverride;
    }
}
