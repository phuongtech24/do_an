package com.reconnect.mindhealth.modules.roadmap.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class BehavioralExperimentSchemaMigrationRunner {

    private static final Logger log = LoggerFactory.getLogger(BehavioralExperimentSchemaMigrationRunner.class);

    @Bean
    ApplicationRunner ensureBehavioralExperimentColumns(JdbcTemplate jdbcTemplate) {
        return args -> {
            ensureColumn(jdbcTemplate, "prediction_belief_before",
                    "ALTER TABLE behavioral_experiments ADD COLUMN prediction_belief_before INT NULL");
            ensureColumn(jdbcTemplate, "prediction_belief_after",
                    "ALTER TABLE behavioral_experiments ADD COLUMN prediction_belief_after INT NULL");
            ensureColumn(jdbcTemplate, "outcome",
                    "ALTER TABLE behavioral_experiments ADD COLUMN outcome TEXT NULL");
            ensureColumn(jdbcTemplate, "learning",
                    "ALTER TABLE behavioral_experiments ADD COLUMN learning TEXT NULL");
            ensureColumn(jdbcTemplate, "setup_completed_at",
                    "ALTER TABLE behavioral_experiments ADD COLUMN setup_completed_at DATETIME NULL");
            ensureColumn(jdbcTemplate, "started_at",
                    "ALTER TABLE behavioral_experiments ADD COLUMN started_at DATETIME NULL");
            ensureColumn(jdbcTemplate, "focus_reminder_shown",
                    "ALTER TABLE behavioral_experiments ADD COLUMN focus_reminder_shown BIT(1) NOT NULL DEFAULT b'0'");
        };
    }

    private void ensureColumn(JdbcTemplate jdbcTemplate, String columnName, String ddl) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                    """
                            SELECT COUNT(*)
                            FROM information_schema.COLUMNS
                            WHERE TABLE_SCHEMA = DATABASE()
                              AND TABLE_NAME = 'behavioral_experiments'
                              AND COLUMN_NAME = ?
                            """,
                    Integer.class,
                    columnName);
            if (count != null && count == 0) {
                jdbcTemplate.execute(ddl);
                log.info("Behavioral experiment schema migration: added behavioral_experiments.{}", columnName);
            }
        } catch (Exception e) {
            log.warn("Behavioral experiment schema migration skipped for {}: {}", columnName, e.getMessage());
        }
    }
}
