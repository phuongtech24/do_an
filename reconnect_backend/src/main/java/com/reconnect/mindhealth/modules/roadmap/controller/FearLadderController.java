package com.reconnect.mindhealth.modules.roadmap.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.roadmap.dto.FearLadderItemDto;
import com.reconnect.mindhealth.modules.roadmap.dto.FearLadderRerateRequestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientGoalDto;
import com.reconnect.mindhealth.modules.roadmap.service.FearLadderService;

@RestController
@RequestMapping("/api/fear-ladder")
public class FearLadderController {

    private final FearLadderService fearLadderService;

    public FearLadderController(FearLadderService fearLadderService) {
        this.fearLadderService = fearLadderService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<FearLadderItemDto>>> list(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.getFearLadder(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PatchMapping("/rerate")
    public ResponseEntity<ApiResponse<List<FearLadderItemDto>>> rerate(@RequestBody FearLadderRerateRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.rerate(request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/goals")
    public ResponseEntity<ApiResponse<List<PatientGoalDto>>> goals(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.getActiveGoals(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/goals")
    public ResponseEntity<ApiResponse<PatientGoalDto>> saveGoal(@RequestBody PatientGoalDto dto) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", fearLadderService.saveGoal(dto)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }
}
