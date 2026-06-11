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

            ensureColumn(jdbcTemplate, "reset_password_token",
                    "ALTER TABLE users ADD COLUMN reset_password_token VARCHAR(128) NULL");
            ensureColumn(jdbcTemplate, "reset_password_expires_at",
                    "ALTER TABLE users ADD COLUMN reset_password_expires_at DATETIME NULL");
        };
    }

    private void ensureColumn(JdbcTemplate jdbcTemplate, String columnName, String ddl) {
        try {
            Integer count = jdbcTemplate.queryForObject(
                    """
                            SELECT COUNT(*)
                            FROM information_schema.COLUMNS
                            WHERE TABLE_SCHEMA = DATABASE()
                              AND TABLE_NAME = 'users'
                              AND COLUMN_NAME = ?
                            """,
                    Integer.class,
                    columnName);
            if (count != null && count == 0) {
                jdbcTemplate.execute(ddl);
                log.info("User schema migration: added users.{}", columnName);
            }
        } catch (Exception e) {
            log.warn("User schema migration skipped for {}: {}", columnName, e.getMessage());
        }
    }
}
