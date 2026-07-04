package com.reconnect.mindhealth.modules.ai.model;

public class VectorSearchResult {
    private VectorDocumentChunk chunk;
    private double vectorScore;
    private double finalScore;

    public VectorDocumentChunk getChunk() {
        return chunk;
    }

    public void setChunk(VectorDocumentChunk chunk) {
        this.chunk = chunk;
    }

    public double getVectorScore() {
        return vectorScore;
    }

    public void setVectorScore(double vectorScore) {
        this.vectorScore = vectorScore;
    }

    public double getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(double finalScore) {
        this.finalScore = finalScore;
    }
}
