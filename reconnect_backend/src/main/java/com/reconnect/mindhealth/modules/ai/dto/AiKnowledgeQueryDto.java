package com.reconnect.mindhealth.modules.ai.dto;

import java.util.ArrayList;
import java.util.List;

public class AiKnowledgeQueryDto {

    private String userMessage;
    private String screenContext;
    private String patientRoute;
    private String programPhaseCode;
    private Integer programWeek;
    private String topicHint;
    private String intent;
    private String journalType;
    private Integer currentRiskScore;
    private List<String> keywords = new ArrayList<>();

    public String getUserMessage() {
        return userMessage;
    }

    public void setUserMessage(String userMessage) {
        this.userMessage = userMessage;
    }

    public String getScreenContext() {
        return screenContext;
    }

    public void setScreenContext(String screenContext) {
        this.screenContext = screenContext;
    }

    public String getPatientRoute() {
        return patientRoute;
    }

    public void setPatientRoute(String patientRoute) {
        this.patientRoute = patientRoute;
    }

    public String getProgramPhaseCode() {
        return programPhaseCode;
    }

    public void setProgramPhaseCode(String programPhaseCode) {
        this.programPhaseCode = programPhaseCode;
    }

    public Integer getProgramWeek() {
        return programWeek;
    }

    public void setProgramWeek(Integer programWeek) {
        this.programWeek = programWeek;
    }

    public String getTopicHint() {
        return topicHint;
    }

    public void setTopicHint(String topicHint) {
        this.topicHint = topicHint;
    }

    public String getIntent() {
        return intent;
    }

    public void setIntent(String intent) {
        this.intent = intent;
    }

    public String getJournalType() {
        return journalType;
    }

    public void setJournalType(String journalType) {
        this.journalType = journalType;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }

    public List<String> getKeywords() {
        return keywords;
    }

    public void setKeywords(List<String> keywords) {
        this.keywords = keywords != null ? keywords : new ArrayList<>();
    }
}
