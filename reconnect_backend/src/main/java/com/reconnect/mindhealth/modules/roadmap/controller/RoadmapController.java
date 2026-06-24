package com.reconnect.mindhealth.modules.roadmap.controller;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramStateDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapSafetyOverlayDto;
import com.reconnect.mindhealth.modules.roadmap.service.IRoadmapService;

@RestController
@RequestMapping("/api/roadmap")
public class RoadmapController {

    @Autowired
    private IRoadmapService roadmapService;

    @GetMapping("/program-state")
    public ResponseEntity<ApiResponse<RoadmapProgramStateDto>> getProgramState(@RequestParam UUID patientId) {
        try {
            RoadmapProgramStateDto state = roadmapService.getProgramState(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy trạng thái lộ trình thành công!", state));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải trạng thái lộ trình: " + e.getMessage()));
        }
    }

    @GetMapping("/safety-overlay")
    public ResponseEntity<ApiResponse<RoadmapSafetyOverlayDto>> getSafetyOverlay(@RequestParam UUID patientId) {
        try {
            RoadmapSafetyOverlayDto overlay = roadmapService.getSafetyOverlay(patientId);
            return ResponseEntity.ok(ApiResponse.success("OK", overlay));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải cảnh báo an toàn: " + e.getMessage()));
        }
    }
}
