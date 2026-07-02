package com.reconnect.mindhealth.modules.clinical.config;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class PatientProfileSchemaMigrationRunner {

    private static final Logger log = LoggerFactory.getLogger(PatientProfileSchemaMigrationRunner.class);

    @Bean
    ApplicationRunner ensurePatientProfileColumns(JdbcTemplate jdbcTemplate) {
        return args -> {
            dropUniqueNicknameIndexIfPresent(jdbcTemplate);
            ensureColumn(jdbcTemplate, "anonymous_mode_enabled", "ALTER TABLE patient_profiles ADD COLUMN anonymous_mode_enabled BIT(1) NOT NULL DEFAULT b'1'");
            ensureColumn(jdbcTemplate, "real_full_name", "ALTER TABLE patient_profiles ADD COLUMN real_full_name VARCHAR(255) NULL");
            ensureColumn(jdbcTemplate, "date_of_birth", "ALTER TABLE patient_profiles ADD COLUMN date_of_birth DATE NULL");
            ensureColumn(jdbcTemplate, "gender", "ALTER TABLE patient_profiles ADD COLUMN gender VARCHAR(32) NULL");
            ensureColumn(jdbcTemplate, "phone_number", "ALTER TABLE patient_profiles ADD COLUMN phone_number VARCHAR(32) NULL");
            ensureColumn(jdbcTemplate, "emergency_contact_phone", "ALTER TABLE patient_profiles ADD COLUMN emergency_contact_phone VARCHAR(32) NULL");
            ensureColumn(jdbcTemplate, "education_level", "ALTER TABLE patient_profiles ADD COLUMN education_level VARCHAR(255) NULL");
            ensureColumn(jdbcTemplate, "occupation", "ALTER TABLE patient_profiles ADD COLUMN occupation VARCHAR(255) NULL");
            ensureColumn(jdbcTemplate, "relationship_status", "ALTER TABLE patient_profiles ADD COLUMN relationship_status VARCHAR(128) NULL");
            ensureColumn(jdbcTemplate, "medical_history", "ALTER TABLE patient_profiles ADD COLUMN medical_history TEXT NULL");
            ensureColumn(jdbcTemplate, "lsas_demo_completed", "ALTER TABLE patient_profiles ADD COLUMN lsas_demo_completed BIT(1) NOT NULL DEFAULT b'0'");
            ensureColumn(jdbcTemplate, "safety_gate_completed", "ALTER TABLE patient_profiles ADD COLUMN safety_gate_completed BIT(1) NOT NULL DEFAULT b'0'");
            ensureColumn(jdbcTemplate, "medical_profile_completed", "ALTER TABLE patient_profiles ADD COLUMN medical_profile_completed BIT(1) NOT NULL DEFAULT b'0'");
            ensureColumn(jdbcTemplate, "therapy_program_started_at", "ALTER TABLE patient_profiles ADD COLUMN therapy_program_started_at DATETIME NULL");
            ensureColumn(jdbcTemplate, "current_program_week", "ALTER TABLE patient_profiles ADD COLUMN current_program_week INT NULL");
            ensureColumn(jdbcTemplate, "triage_required", "ALTER TABLE patient_profiles ADD COLUMN triage_required BIT(1) NOT NULL DEFAULT b'0'");
            ensureColumn(jdbcTemplate, "triage_status", "ALTER TABLE patient_profiles ADD COLUMN triage_status VARCHAR(32) NULL");
            ensureColumn(jdbcTemplate, "triage_priority", "ALTER TABLE patient_profiles ADD COLUMN triage_priority INT NULL");
            ensureColumn(jdbcTemplate, "triage_triggered_at", "ALTER TABLE patient_profiles ADD COLUMN triage_triggered_at DATETIME NULL");
        };
    }

    private void dropUniqueNicknameIndexIfPresent(JdbcTemplate jdbcTemplate) {
        try {
            List<String> uniqueIndexes = jdbcTemplate.queryForList(
                    """
                            SELECT DISTINCT INDEX_NAME
                            FROM information_schema.STATISTICS
                            WHERE TABLE_SCHEMA = DATABASE()
                              AND TABLE_NAME = 'patient_profiles'
                              AND COLUMN_NAME = 'nickname'
                              AND NON_UNIQUE = 0
                              AND INDEX_NAME <> 'PRIMARY'
                            """,
                    String.class);
            for (String indexName : uniqueIndexes) {
                jdbcTemplate.execute("ALTER TABLE patient_profiles DROP INDEX `" + indexName + "`");
                log.info("Patient profile schema migration: dropped unique nickname index {}", indexName);
            }
        } catch (Exception e) {
            log.warn("Patient profile schema migration skipped for nickname unique index: {}", e.getMessage());
        }
    }

    private void ensureColumn(JdbcTemplate jdbcTemplate, String columnName, String ddl) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                    """
                            SELECT COUNT(*)
                            FROM information_schema.COLUMNS
                            WHERE TABLE_SCHEMA = DATABASE()
                              AND TABLE_NAME = 'patient_profiles'
                              AND COLUMN_NAME = ?
                            """,
                    Integer.class,
                    columnName);
            if (count != null && count == 0) {
                jdbcTemplate.execute(ddl);
                log.info("Patient profile schema migration: added patient_profiles.{}", columnName);
            }
        } catch (Exception e) {
            log.warn("Patient profile schema migration skipped for {}: {}", columnName, e.getMessage());
        }
    }
}
