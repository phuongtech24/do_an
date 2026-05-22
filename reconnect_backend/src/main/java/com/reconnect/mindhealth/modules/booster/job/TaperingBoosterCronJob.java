package com.reconnect.mindhealth.modules.booster.job;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.reconnect.mindhealth.modules.booster.service.ITaperingBoosterSchedulingService;

@Component
public class TaperingBoosterCronJob {

    private static final Logger log = LoggerFactory.getLogger(TaperingBoosterCronJob.class);

    private final ITaperingBoosterSchedulingService schedulingService;

    public TaperingBoosterCronJob(ITaperingBoosterSchedulingService schedulingService) {
        this.schedulingService = schedulingService;
    }

    // Run daily at 00:15 (Asia/Bangkok)
    @Scheduled(cron = "0 15 0 * * *", zone = "Asia/Bangkok")
    public void runDaily() {
        int created = schedulingService.runDailyScheduling();
        log.info("TaperingBoosterCronJob completed. createdAppointments={}", created);
    }
}

