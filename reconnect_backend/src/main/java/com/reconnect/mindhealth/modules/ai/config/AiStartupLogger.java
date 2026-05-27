package com.reconnect.mindhealth.modules.ai.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
public class AiStartupLogger implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(AiStartupLogger.class);

    private final AiProperties aiProperties;

    public AiStartupLogger(AiProperties aiProperties) {
        this.aiProperties = aiProperties;
    }

    @Override
    public void run(ApplicationArguments args) {
        AiProperties.Gemini gemini = aiProperties.getGemini();
        String model = gemini != null ? gemini.getModel() : null;
        String apiKey = gemini != null ? gemini.getApiKey() : null;
        boolean apiKeyPresent = apiKey != null && !apiKey.isBlank();

        log.info("AI startup config: enabled={}, geminiModel={}, apiKeyPresent={}",
                aiProperties.isEnabled(), model, apiKeyPresent);
    }
}
