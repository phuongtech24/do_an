package com.reconnect.mindhealth.modules.roadmap.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.roadmap.dto.BehavioralExperimentDebriefRequestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.BehavioralExperimentDto;
import com.reconnect.mindhealth.modules.roadmap.dto.BehavioralExperimentStartRequestDto;
import com.reconnect.mindhealth.modules.roadmap.service.FearLadderService;

@RestController
@RequestMapping("/api/behavioral-experiments")
public class BehavioralExperimentController {

    private final FearLadderService fearLadderService;

    public BehavioralExperimentController(FearLadderService fearLadderService) {
        this.fearLadderService = fearLadderService;
    }

    @GetMapping("/today")
    public ResponseEntity<ApiResponse<BehavioralExperimentDto>> today(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.getTodayExperiment(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<BehavioralExperimentDto>>> history(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.getExperimentHistory(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/select")
    public ResponseEntity<ApiResponse<BehavioralExperimentDto>> select(
            @RequestParam UUID patientId,
            @RequestParam UUID ladderItemId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.selectExperiment(patientId, ladderItemId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{id}/start")
    public ResponseEntity<ApiResponse<BehavioralExperimentDto>> start(
            @PathVariable UUID id,
            @RequestBody BehavioralExperimentStartRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.startExperiment(id, request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PatchMapping("/{id}/debrief")
    public ResponseEntity<ApiResponse<BehavioralExperimentDto>> debrief(
            @PathVariable UUID id,
            @RequestBody BehavioralExperimentDebriefRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.debriefExperiment(id, request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }
}
