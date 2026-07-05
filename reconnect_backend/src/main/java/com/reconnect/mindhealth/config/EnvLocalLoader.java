package com.reconnect.mindhealth.config;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class EnvLocalLoader {

    private static final Logger log = LoggerFactory.getLogger(EnvLocalLoader.class);

    private EnvLocalLoader() {
    }

    public static void loadIntoSystemProperties() {
        Path envFile = resolveEnvLocalPath();
        if (envFile == null) {
            log.info(".env.local not found, skip local env autoload");
            return;
        }

        try {
            List<String> lines = Files.readAllLines(envFile, StandardCharsets.UTF_8);
            int loaded = 0;
            for (String rawLine : lines) {
                String line = rawLine == null ? "" : rawLine.trim();
                if (line.isBlank() || line.startsWith("#")) {
                    continue;
                }

                int separator = line.indexOf('=');
                if (separator <= 0) {
                    continue;
                }

                String key = line.substring(0, separator).trim();
                String value = line.substring(separator + 1).trim();
                value = stripWrappingQuotes(value);

                if (System.getProperty(key) == null || System.getProperty(key).isBlank()) {
                    System.setProperty(key, value);
                    loaded++;
                }
            }
            log.info("Loaded {} entries from {}", loaded, envFile.toAbsolutePath());
        } catch (IOException exception) {
            log.warn("Failed to load {}: {}", envFile.toAbsolutePath(), exception.getMessage());
        }
    }

    private static Path resolveEnvLocalPath() {
        Set<Path> candidates = new LinkedHashSet<>();

        String userDir = System.getProperty("user.dir");
        if (userDir != null && !userDir.isBlank()) {
            Path cwd = Paths.get(userDir).toAbsolutePath().normalize();
            candidates.add(cwd.resolve(".env.local"));
            if (cwd.getParent() != null) {
                candidates.add(cwd.getParent().resolve(".env.local"));
            }
        }

        Path projectRoot = Paths.get("").toAbsolutePath().normalize();
        candidates.add(projectRoot.resolve(".env.local"));
        if (projectRoot.getParent() != null) {
            candidates.add(projectRoot.getParent().resolve(".env.local"));
        }

        for (Path candidate : candidates) {
            if (Files.exists(candidate) && Files.isRegularFile(candidate)) {
                return candidate;
            }
        }
        return null;
    }

    private static String stripWrappingQuotes(String value) {
        if (value == null || value.length() < 2) {
            return value;
        }
        if ((value.startsWith("\"") && value.endsWith("\""))
                || (value.startsWith("'") && value.endsWith("'"))) {
            return value.substring(1, value.length() - 1);
        }
        return value;
    }
}
