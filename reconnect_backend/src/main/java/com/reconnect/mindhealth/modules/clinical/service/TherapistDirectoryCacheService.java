package com.reconnect.mindhealth.modules.clinical.service;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;

@Service
public class TherapistDirectoryCacheService {

    @CacheEvict(cacheNames = {
            "therapistDirectoryList",
            "therapistDirectoryItem",
            "adminTherapistList"
    }, allEntries = true)
    public void evictAll() {
    }
}
