package com.reconnect.mindhealth.modules.roadmap.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.roadmap.dto.CompleteQuestRequest;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientQuestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.VerifyQuestProofResponseDto;
import com.reconnect.mindhealth.modules.roadmap.service.IRoadmapService;

@RestController
@RequestMapping("/api/roadmap")
public class RoadmapController {

    @Autowired
    private IRoadmapService roadmapService;

    @GetMapping("/daily")
    public ResponseEntity<ApiResponse<List<PatientQuestDto>>> getDailyQuests(@RequestParam UUID patientId) {
        try {
            List<PatientQuestDto> list = roadmapService.getDailyQuests(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy danh sách nhiệm vụ hôm nay thành công!", list));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải nhiệm vụ: " + e.getMessage()));
        }
    }

    @PostMapping("/quests/{id}/complete")
    public ResponseEntity<ApiResponse<PatientQuestDto>> completeQuest(@PathVariable UUID id,
            @RequestParam UUID patientId,
            @RequestBody(required = false) CompleteQuestRequest request) {
        try {
            PatientQuestDto result = roadmapService.completeQuest(patientId, id, request);
            return ResponseEntity.ok(ApiResponse.success("Hoàn thành nhiệm vụ thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi hoàn thành nhiệm vụ: " + e.getMessage()));
        }
    }

    @PostMapping("/quests/{id}/proof/verify")
    public ResponseEntity<ApiResponse<VerifyQuestProofResponseDto>> verifyQuestProof(
            @PathVariable UUID id,
            @RequestParam UUID patientId,
            @RequestParam("file") MultipartFile file) {
        try {
            if (file == null || file.isEmpty()) {
                return ResponseEntity.ok(ApiResponse.error("Thiếu file ảnh minh chứng."));
            }
            String mimeType = file.getContentType() != null ? file.getContentType() : "image/jpeg";
            VerifyQuestProofResponseDto result = roadmapService.verifyQuestProof(patientId, id, file.getBytes(),
                    mimeType);
            return ResponseEntity.ok(ApiResponse.success("OK", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi xác minh minh chứng: " + e.getMessage()));
        }
    }
}
