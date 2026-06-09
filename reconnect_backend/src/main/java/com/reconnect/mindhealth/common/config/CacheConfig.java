package com.reconnect.mindhealth.common.config;

import java.time.Duration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.cache.support.NoOpCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import com.fasterxml.jackson.databind.ObjectMapper;

@Configuration
@EnableCaching
@EnableConfigurationProperties(AppCacheProperties.class)
public class CacheConfig {

    private static final Logger log = LoggerFactory.getLogger(CacheConfig.class);

    @Bean
    public CacheManager cacheManager(
            ObjectProvider<RedisConnectionFactory> redisConnectionFactoryProvider,
            AppCacheProperties cacheProperties,
            ObjectMapper objectMapper) {
        RedisConnectionFactory redisConnectionFactory = redisConnectionFactoryProvider.getIfAvailable();
        if (!cacheProperties.isEnabled() || redisConnectionFactory == null) {
            log.info("Cache disabled or Redis unavailable. Falling back to NoOp cache manager.");
            return new NoOpCacheManager();
        }

        GenericJackson2JsonRedisSerializer serializer = new GenericJackson2JsonRedisSerializer(objectMapper);
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
                .computePrefixWith(cacheName -> "mindhealth::" + cacheName + "::")
                .entryTtl(Duration.ofMinutes(cacheProperties.getTherapistDirectoryTtlMinutes()))
                .serializeValuesWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(serializer))
                .disableCachingNullValues();

        log.info("Redis cache enabled with therapist directory ttl={} minutes",
                cacheProperties.getTherapistDirectoryTtlMinutes());
        return RedisCacheManager.builder(redisConnectionFactory)
                .cacheDefaults(defaultConfig)
                .build();
    }

    @Bean
    public CacheErrorHandler cacheErrorHandler() {
        return new CacheErrorHandler() {
            private final Logger logger = LoggerFactory.getLogger("MindHealthCache");

            @Override
            public void handleCacheGetError(RuntimeException exception, org.springframework.cache.Cache cache,
                    Object key) {
                logger.warn("Cache GET failed: cache={}, key={}, err={}",
                        cache != null ? cache.getName() : "unknown", key, exception.getMessage());
            }

            @Override
            public void handleCachePutError(RuntimeException exception, org.springframework.cache.Cache cache,
                    Object key, Object value) {
                logger.warn("Cache PUT failed: cache={}, key={}, err={}",
                        cache != null ? cache.getName() : "unknown", key, exception.getMessage());
            }

            @Override
            public void handleCacheEvictError(RuntimeException exception, org.springframework.cache.Cache cache,
                    Object key) {
                logger.warn("Cache EVICT failed: cache={}, key={}, err={}",
                        cache != null ? cache.getName() : "unknown", key, exception.getMessage());
            }

            @Override
            public void handleCacheClearError(RuntimeException exception, org.springframework.cache.Cache cache) {
                logger.warn("Cache CLEAR failed: cache={}, err={}",
                        cache != null ? cache.getName() : "unknown", exception.getMessage());
            }
        };
    }
}
