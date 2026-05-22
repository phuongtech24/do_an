package com.reconnect.mindhealth.modules.journal.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.journal.dto.JournalDto;
import com.reconnect.mindhealth.modules.journal.service.IJournalService;

/**
 * Controller class for CBT Journal APIs.
 */
@RestController
@RequestMapping("/api/journal")
public class JournalController {

    @Autowired
    private IJournalService journalService;

    /**
     * POST /api/journal/thought-records
     * Saves a new CBT Journal (Thought Record or Credit List).
     */
    @PostMapping("/thought-records")
    public ResponseEntity<ApiResponse<JournalDto>> saveJournal(@RequestBody JournalDto dto) {
        try {
            if (dto.getPatientId() == null) {
                return ResponseEntity.ok(ApiResponse.error("Thiếu thông tin patientId."));
            }
            if (dto.getJournalType() == null) {
                return ResponseEntity.ok(ApiResponse.error("Thiếu loại nhật ký (journalType)."));
            }
            JournalDto result = journalService.saveJournal(dto, dto.getPatientId());
            return ResponseEntity.ok(ApiResponse.success("Lưu nhật ký thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi lưu nhật ký: " + e.getMessage()));
        }
    }

    /**
     * GET /api/journal/thought-records
     * Retrieves all journals written by a specific patient.
     */
    @GetMapping("/thought-records")
    public ResponseEntity<ApiResponse<List<JournalDto>>> getJournalsByPatient(@RequestParam UUID patientId) {
        try {
            if (patientId == null) {
                return ResponseEntity.ok(ApiResponse.error("Thiếu thông tin patientId."));
            }
            List<JournalDto> list = journalService.getJournalsByPatient(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy danh sách nhật ký thành công!", list));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải danh sách: " + e.getMessage()));
        }
    }

    /**
     * GET /api/journal/thought-records/{id}
     * Retrieves a single journal's details, verifying ownership.
     */
    @GetMapping("/thought-records/{id}")
    public ResponseEntity<ApiResponse<JournalDto>> getJournalById(
            @PathVariable UUID id,
            @RequestParam UUID patientId) {
        try {
            if (patientId == null) {
                return ResponseEntity.ok(ApiResponse.error("Thiếu thông tin patientId."));
            }
            JournalDto journal = journalService.getJournalById(id, patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy chi tiết nhật ký thành công!", journal));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}
