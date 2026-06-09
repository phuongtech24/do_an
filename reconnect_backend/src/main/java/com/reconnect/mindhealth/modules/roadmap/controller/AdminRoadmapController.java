package com.reconnect.mindhealth.modules.roadmap.controller;

import java.time.LocalDate;
import java.time.ZoneId;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.roadmap.dto.DailyQuestAssignmentSummaryDto;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;

@RestController
@RequestMapping("/api/admin/roadmap")
public class AdminRoadmapController {

    private static final ZoneId APP_ZONE = ZoneId.of("Asia/Bangkok");

    private final RoadmapDailyAssignmentService dailyAssignmentService;

    public AdminRoadmapController(RoadmapDailyAssignmentService dailyAssignmentService) {
        this.dailyAssignmentService = dailyAssignmentService;
    }

    @PostMapping("/daily-quests/run")
    public ResponseEntity<ApiResponse<DailyQuestAssignmentSummaryDto>> runDailyQuests(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        LocalDate effectiveDate = date != null ? date : LocalDate.now(APP_ZONE);
        DailyQuestAssignmentSummaryDto summary = dailyAssignmentService.assignDailyQuestsForAllActivePatients(effectiveDate);
        return ResponseEntity.ok(ApiResponse.success("Đã chạy giao bài CBT hằng ngày.", summary));
    }
}
