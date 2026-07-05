package com.reconnect.mindhealth.modules.ai.model;

public class VectorSearchQuery {
    private String text;
    private String screenContext;
    private String patientRoute;
    private String programPhaseCode;
    private String intent;
    private String journalType;
    private String topicHint;
    private int topK;
    private double minScore;

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
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

    public String getTopicHint() {
        return topicHint;
    }

    public void setTopicHint(String topicHint) {
        this.topicHint = topicHint;
    }

    public int getTopK() {
        return topK;
    }

    public void setTopK(int topK) {
        this.topK = topK;
    }

    public double getMinScore() {
        return minScore;
    }

    public void setMinScore(double minScore) {
        this.minScore = minScore;
    }
}
