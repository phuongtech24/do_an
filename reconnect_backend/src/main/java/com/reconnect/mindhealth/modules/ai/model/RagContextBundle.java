package com.reconnect.mindhealth.modules.ai.model;

import java.util.List;

public class RagContextBundle {
    private boolean vectorUsed;
    private List<VectorSearchResult> results = List.of();
    private String knowledgeBlock = "";

    public boolean isVectorUsed() {
        return vectorUsed;
    }

    public void setVectorUsed(boolean vectorUsed) {
        this.vectorUsed = vectorUsed;
    }

    public List<VectorSearchResult> getResults() {
        return results;
    }

    public void setResults(List<VectorSearchResult> results) {
        this.results = results;
    }

    public String getKnowledgeBlock() {
        return knowledgeBlock;
    }

    public void setKnowledgeBlock(String knowledgeBlock) {
        this.knowledgeBlock = knowledgeBlock;
    }
}
