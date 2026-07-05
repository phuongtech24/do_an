package com.reconnect.mindhealth.modules.ai.model;

import java.util.List;

public class GuideKnowledgeCard {
    private String topicCode;
    private List<String> topicAliases = List.of();
    private List<String> screenScope = List.of();
    private List<String> routeScope = List.of();
    private List<String> phaseScope = List.of();
    private List<String> intentScope = List.of();
    private List<String> journalTypes = List.of();
    private List<String> keywords = List.of();
    private String content;
    private List<GuideActionCard> suggestedActions = List.of();

    public String getTopicCode() {
        return topicCode;
    }

    public void setTopicCode(String topicCode) {
        this.topicCode = topicCode;
    }

    public List<String> getTopicAliases() {
        return topicAliases;
    }

    public void setTopicAliases(List<String> topicAliases) {
        this.topicAliases = topicAliases;
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

    public List<GuideActionCard> getSuggestedActions() {
        return suggestedActions;
    }

    public void setSuggestedActions(List<GuideActionCard> suggestedActions) {
        this.suggestedActions = suggestedActions;
    }
}
