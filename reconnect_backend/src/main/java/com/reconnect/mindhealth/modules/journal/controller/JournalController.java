package com.reconnect.mindhealth.modules.journal.controller;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.util.PagingUtils;
import com.reconnect.mindhealth.modules.journal.dto.JournalDto;
import com.reconnect.mindhealth.modules.journal.dto.JournalSearchRequestDto;
import com.reconnect.mindhealth.modules.journal.service.IJournalService;

@RestController
@RequestMapping("/api/journal")
public class JournalController {

    @Autowired
    private IJournalService journalService;

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

    @GetMapping("/thought-records")
    public ResponseEntity<ApiResponse<List<JournalDto>>> getJournalsByPatient(@RequestParam UUID patientId) {
        try {
            List<JournalDto> list = journalService.getJournalsByPatient(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy danh sách nhật ký thành công!", list));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải danh sách: " + e.getMessage()));
        }
    }

    @PostMapping("/thought-records/paging")
    public ResponseEntity<ApiResponse<Page<JournalDto>>> getJournalsByPatientPaging(
            @RequestBody(required = false) JournalSearchRequestDto request) {
        try {
            if (request == null || request.getPatientId() == null) {
                return ResponseEntity.ok(ApiResponse.error("Thiếu thông tin patientId."));
            }
            String keyword = request.normalizedKeyword();
            List<JournalDto> list = journalService.getJournalsByPatient(request.getPatientId()).stream()
                    .filter(item -> matchesKeyword(item, keyword))
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("Lấy danh sách nhật ký thành công!", PagingUtils.paginate(list, request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải danh sách: " + e.getMessage()));
        }
    }

    @GetMapping("/thought-records/{id}")
    public ResponseEntity<ApiResponse<JournalDto>> getJournalById(
            @PathVariable UUID id,
            @RequestParam UUID patientId) {
        try {
            JournalDto journal = journalService.getJournalById(id, patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy chi tiết nhật ký thành công!", journal));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private boolean matchesKeyword(JournalDto item, String keyword) {
        if (keyword == null) {
            return true;
        }
        String normalized = keyword.toLowerCase(Locale.ROOT);
        return containsIgnoreCase(item.getSituation(), normalized)
                || containsIgnoreCase(item.getWorstPrediction(), normalized)
                || containsIgnoreCase(item.getAutomaticThought(), normalized)
                || containsIgnoreCase(item.getAdaptiveResponse(), normalized)
                || containsIgnoreCase(item.getContent(), normalized)
                || containsIgnoreCase(item.getJournalType() != null ? item.getJournalType().name() : null, normalized);
    }

    private boolean containsIgnoreCase(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }
}
