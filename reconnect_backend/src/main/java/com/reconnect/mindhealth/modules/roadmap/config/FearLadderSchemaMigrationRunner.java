package com.reconnect.mindhealth.modules.roadmap.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class FearLadderSchemaMigrationRunner {

    private static final Logger log = LoggerFactory.getLogger(FearLadderSchemaMigrationRunner.class);

    @Bean
    ApplicationRunner ensureFearLadderBucketColumn(JdbcTemplate jdbcTemplate) {
        return args -> {
            try {
                String dataType = jdbcTemplate.queryForObject(
                        """
                                SELECT DATA_TYPE
                                FROM information_schema.COLUMNS
                                WHERE TABLE_SCHEMA = DATABASE()
                                  AND TABLE_NAME = 'fear_ladder_items'
                                  AND COLUMN_NAME = 'bucket'
                                """,
                        String.class);

                Integer maxLength = jdbcTemplate.queryForObject(
                        """
                                SELECT CHARACTER_MAXIMUM_LENGTH
                                FROM information_schema.COLUMNS
                                WHERE TABLE_SCHEMA = DATABASE()
                                  AND TABLE_NAME = 'fear_ladder_items'
                                  AND COLUMN_NAME = 'bucket'
                                """,
                        Integer.class);

                if (dataType != null
                        && (!"varchar".equalsIgnoreCase(dataType)
                        || maxLength == null
                        || maxLength < 16)) {
                    jdbcTemplate.execute("ALTER TABLE fear_ladder_items MODIFY COLUMN bucket VARCHAR(32) NOT NULL");
                    log.info("Fear ladder schema migration: converted fear_ladder_items.bucket to VARCHAR(32)");
                }
            } catch (Exception e) {
                log.warn("Fear ladder schema migration skipped or failed for fear_ladder_items.bucket: {}", e.getMessage());
            }
        };
    }
}
