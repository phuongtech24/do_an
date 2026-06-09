package com.reconnect.mindhealth.modules.auth.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class UserSchemaMigrationRunner {

    private static final Logger log = LoggerFactory.getLogger(UserSchemaMigrationRunner.class);

    @Bean
    ApplicationRunner ensureUserRoleColumnSupportsGuest(JdbcTemplate jdbcTemplate) {
        return args -> {
            try {
                String dataType = jdbcTemplate.queryForObject(
                        """
                                SELECT DATA_TYPE
                                FROM information_schema.COLUMNS
                                WHERE TABLE_SCHEMA = DATABASE()
                                  AND TABLE_NAME = 'users'
                                  AND COLUMN_NAME = 'role'
                                """,
                        String.class);

                if (dataType != null && !"varchar".equalsIgnoreCase(dataType)) {
                    jdbcTemplate.execute("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL");
                    log.info("User schema migration: converted users.role to VARCHAR(32)");
                }
            } catch (Exception e) {
                log.warn("User schema migration skipped or failed for users.role: {}", e.getMessage());
            }
        };
    }
}
