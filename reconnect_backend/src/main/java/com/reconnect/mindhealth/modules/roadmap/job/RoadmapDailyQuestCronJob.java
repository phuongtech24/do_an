package com.reconnect.mindhealth.modules.roadmap.job;

import java.time.LocalDate;
import java.time.ZoneId;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.reconnect.mindhealth.modules.roadmap.dto.DailyQuestAssignmentSummaryDto;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;

@Component
public class RoadmapDailyQuestCronJob {

    private static final Logger log = LoggerFactory.getLogger(RoadmapDailyQuestCronJob.class);
    private static final ZoneId APP_ZONE = ZoneId.of("Asia/Bangkok");

    private final RoadmapDailyAssignmentService dailyAssignmentService;

    public RoadmapDailyQuestCronJob(RoadmapDailyAssignmentService dailyAssignmentService) {
        this.dailyAssignmentService = dailyAssignmentService;
    }

    @Scheduled(cron = "0 5 6 * * *", zone = "Asia/Bangkok")
    public void run() {
        LocalDate date = LocalDate.now(APP_ZONE);
        DailyQuestAssignmentSummaryDto summary = dailyAssignmentService.assignDailyQuestsForAllActivePatients(date);
        log.info("Roadmap daily quest cron completed date={}, processed={}, created={}, skipped={}, failed={}",
                summary.getDate(), summary.getProcessedPatients(), summary.getCreatedQuests(),
                summary.getSkippedPatients(), summary.getFailedPatients());
    }
}
