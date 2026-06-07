package com.reconnect.mindhealth.modules.booster.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class AppointmentSchemaMigrationRunner {

    private static final Logger log = LoggerFactory.getLogger(AppointmentSchemaMigrationRunner.class);

    @Bean
    ApplicationRunner ensureAppointmentPurposeColumn(JdbcTemplate jdbcTemplate) {
        return args -> {
            try {
                String dataType = jdbcTemplate.queryForObject(
                        """
                                SELECT DATA_TYPE
                                FROM information_schema.COLUMNS
                                WHERE TABLE_SCHEMA = DATABASE()
                                  AND TABLE_NAME = 'appointments'
                                  AND COLUMN_NAME = 'purpose'
                                """,
                        String.class);

                if (dataType != null && !"varchar".equalsIgnoreCase(dataType)) {
                    jdbcTemplate.execute("ALTER TABLE appointments MODIFY COLUMN purpose VARCHAR(64) NOT NULL");
                    log.info("Appointment schema migration: converted appointments.purpose to VARCHAR(64)");
                }

                Integer clinicalPurposeCodeColumn = jdbcTemplate.queryForObject(
                        """
                                SELECT COUNT(*)
                                FROM information_schema.COLUMNS
                                WHERE TABLE_SCHEMA = DATABASE()
                                  AND TABLE_NAME = 'appointments'
                                  AND COLUMN_NAME = 'clinical_purpose_code'
                                """,
                        Integer.class);
                if (clinicalPurposeCodeColumn != null && clinicalPurposeCodeColumn == 0) {
                    jdbcTemplate.execute("ALTER TABLE appointments ADD COLUMN clinical_purpose_code VARCHAR(64) NULL");
                    log.info("Appointment schema migration: added appointments.clinical_purpose_code");
                }

                Integer carePhaseCodeColumn = jdbcTemplate.queryForObject(
                        """
                                SELECT COUNT(*)
                                FROM information_schema.COLUMNS
                                WHERE TABLE_SCHEMA = DATABASE()
                                  AND TABLE_NAME = 'appointments'
                                  AND COLUMN_NAME = 'care_phase_code'
                                """,
                        Integer.class);
                if (carePhaseCodeColumn != null && carePhaseCodeColumn == 0) {
                    jdbcTemplate.execute("ALTER TABLE appointments ADD COLUMN care_phase_code VARCHAR(64) NULL");
                    log.info("Appointment schema migration: added appointments.care_phase_code");
                }
            } catch (Exception e) {
                log.warn("Appointment schema migration skipped or failed: {}", e.getMessage());
            }
        };
    }
}
