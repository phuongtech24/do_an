package com.reconnect.mindhealth.modules.roadmap.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class QuestTemplateSchemaMigrationRunner {

    private static final Logger log = LoggerFactory.getLogger(QuestTemplateSchemaMigrationRunner.class);

    @Bean
    ApplicationRunner ensureQuestTemplateColumns(JdbcTemplate jdbcTemplate) {
        return args -> {
            ensureColumn(jdbcTemplate, "module_code",
                    "ALTER TABLE quest_templates ADD COLUMN module_code VARCHAR(128) NULL");
            ensureColumn(jdbcTemplate, "program_week",
                    "ALTER TABLE quest_templates ADD COLUMN program_week INT NULL");
            ensureColumn(jdbcTemplate, "program_phase_code",
                    "ALTER TABLE quest_templates ADD COLUMN program_phase_code VARCHAR(128) NULL");
            ensureColumn(jdbcTemplate, "intervention_type",
                    "ALTER TABLE quest_templates ADD COLUMN intervention_type VARCHAR(128) NULL");
            ensureColumn(jdbcTemplate, "prerequisite_codes_json",
                    "ALTER TABLE quest_templates ADD COLUMN prerequisite_codes_json JSON NULL");
            ensureColumn(jdbcTemplate, "therapist_only_assignable",
                    "ALTER TABLE quest_templates ADD COLUMN therapist_only_assignable BIT(1) NOT NULL DEFAULT b'0'");
            ensureColumn(jdbcTemplate, "hard_locked",
                    "ALTER TABLE quest_templates ADD COLUMN hard_locked BIT(1) NOT NULL DEFAULT b'0'");
        };
    }

    private void ensureColumn(JdbcTemplate jdbcTemplate, String columnName, String ddl) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                    """
                            SELECT COUNT(*)
                            FROM information_schema.COLUMNS
                            WHERE TABLE_SCHEMA = DATABASE()
                              AND TABLE_NAME = 'quest_templates'
                              AND COLUMN_NAME = ?
                            """,
                    Integer.class,
                    columnName);
            if (count != null && count == 0) {
                jdbcTemplate.execute(ddl);
                log.info("Quest template schema migration: added quest_templates.{}", columnName);
            }
        } catch (Exception e) {
            log.warn("Quest template schema migration skipped for {}: {}", columnName, e.getMessage());
        }
    }
}
