package com.reconnect.mindhealth.modules.risk.job;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.reconnect.mindhealth.modules.risk.service.IRiskScoringService;

@Component
public class RiskIndexCronJob {

    private static final Logger log = LoggerFactory.getLogger(RiskIndexCronJob.class);

    @Autowired
    private IRiskScoringService riskScoringService;

    // 00:00 every day (Asia/Bangkok)
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Bangkok")
    public void runNightlyRiskIndex() {
        int processed = riskScoringService.calculateAndPersistForAllActivePatients();
        log.info("RiskIndexCronJob completed. processedPatients={}", processed);
    }
}

