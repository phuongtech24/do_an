package com.reconnect.mindhealth.modules.ai.model;

import java.util.List;

public class VectorDocumentChunk {
    private String id;
    private String sourceType;
    private String sourcePath;
    private String topicCode;
    private List<String> screenScope = List.of();
    private List<String> routeScope = List.of();
    private List<String> phaseScope = List.of();
    private List<String> intentScope = List.of();
    private List<String> journalTypes = List.of();
    private List<String> keywords = List.of();
    private String content;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getSourcePath() {
        return sourcePath;
    }

    public void setSourcePath(String sourcePath) {
        this.sourcePath = sourcePath;
    }

    public String getTopicCode() {
        return topicCode;
    }

    public void setTopicCode(String topicCode) {
        this.topicCode = topicCode;
    }

    public List<String> getScreenScope() {
        return screenScope;
    }

    public void setScreenScope(List<String> screenScope) {
        this.screenScope = screenScope;
    }

    public List<String> getRouteScope() {
        return routeScope;
    }

    public void setRouteScope(List<String> routeScope) {
        this.routeScope = routeScope;
    }

    public List<String> getPhaseScope() {
        return phaseScope;
    }

    public void setPhaseScope(List<String> phaseScope) {
        this.phaseScope = phaseScope;
    }

    public List<String> getIntentScope() {
        return intentScope;
    }

    public void setIntentScope(List<String> intentScope) {
        this.intentScope = intentScope;
    }

    public List<String> getJournalTypes() {
        return journalTypes;
    }

    public void setJournalTypes(List<String> journalTypes) {
        this.journalTypes = journalTypes;
    }

    public List<String> getKeywords() {
        return keywords;
    }

    public void setKeywords(List<String> keywords) {
        this.keywords = keywords;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
