package com.reconnect.mindhealth.modules.ai.service;

import java.util.List;

import com.reconnect.mindhealth.modules.ai.model.VectorDocumentChunk;
import com.reconnect.mindhealth.modules.ai.model.VectorSearchResult;

public interface IVectorStoreService {
    boolean ensureCollection();

    void upsert(List<VectorDocumentChunk> chunks, List<List<Double>> vectors);

    List<VectorSearchResult> search(List<Double> queryVector, int limit);
}
