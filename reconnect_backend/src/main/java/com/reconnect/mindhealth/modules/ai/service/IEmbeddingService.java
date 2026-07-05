package com.reconnect.mindhealth.modules.ai.service;

import java.util.List;

public interface IEmbeddingService {
    List<Double> embed(String text);
}
