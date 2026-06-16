package com.reconnect.mindhealth.modules.roadmap.controller;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.common.util.PagingUtils;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.roadmap.dto.QuestTemplateDto;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.repository.QuestTemplateRepository;
import com.reconnect.mindhealth.modules.roadmap.support.QuestTemplatePhaseCodeNormalizer;

import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/api/admin/quest-templates")
public class AdminQuestTemplateController {

    private final AuthContextService authContextService;
    private final QuestTemplateRepository questTemplateRepository;

    public AdminQuestTemplateController(AuthContextService authContextService,
            QuestTemplateRepository questTemplateRepository) {
        this.authContextService = authContextService;
        this.questTemplateRepository = questTemplateRepository;
    }

    private void requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chỉ ADMIN mới có quyền truy cập chức năng này.");
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<QuestTemplateDto>>> list() {
        try {
            requireAdmin();
            List<QuestTemplateDto> list = questTemplateRepository.findAll().stream().map(QuestTemplateDto::new).toList();
            return ResponseEntity.ok(ApiResponse.success("OK", list));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/paging")
    public ResponseEntity<ApiResponse<Page<QuestTemplateDto>>> searchByPage(
            @RequestBody(required = false) PageSearchRequestDto request) {
        try {
            requireAdmin();
            PageSearchRequestDto safeRequest = request != null ? request : new PageSearchRequestDto();
            String keyword = safeRequest.normalizedKeyword();
            List<QuestTemplateDto> list = questTemplateRepository.findAll().stream()
                    .map(QuestTemplateDto::new)
                    .filter(item -> matchesKeyword(item, keyword))
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", PagingUtils.paginate(list, safeRequest)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<QuestTemplateDto>> create(@RequestBody QuestTemplateDto dto) {
        try {
            requireAdmin();
            if (dto == null) {
                throw new IllegalArgumentException("Thiếu payload.");
            }
            if (dto.getTitle() == null || dto.getTitle().trim().isEmpty()) {
                throw new IllegalArgumentException("Thiếu title.");
            }
            if (dto.getDescription() == null || dto.getDescription().trim().isEmpty()) {
                throw new IllegalArgumentException("Thiếu description.");
            }
            if (dto.getCategory() == null) {
                throw new IllegalArgumentException("Thiếu category.");
            }

            QuestTemplate qt = new QuestTemplate();
            qt.setTitle(dto.getTitle().trim());
            qt.setDescription(dto.getDescription().trim());
            qt.setCategory(dto.getCategory());
            if (dto.getDifficulty() != null) {
                qt.setDifficulty(dto.getDifficulty());
            }
            qt.setModuleCode(dto.getModuleCode());
            qt.setProgramWeek(dto.getProgramWeek());
            qt.setProgramPhaseCode(QuestTemplatePhaseCodeNormalizer.normalize(dto.getProgramPhaseCode()));
            qt.setInterventionType(dto.getInterventionType());
            qt.setPrerequisiteCodesJson(dto.getPrerequisiteCodesJson());
            qt.setTherapistOnlyAssignable(Boolean.TRUE.equals(dto.getTherapistOnlyAssignable()));
            qt.setHardLocked(Boolean.TRUE.equals(dto.getHardLocked()));

            QuestTemplate saved = questTemplateRepository.save(qt);
            return ResponseEntity.ok(ApiResponse.success("OK", new QuestTemplateDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<QuestTemplateDto>> update(@PathVariable UUID id, @RequestBody QuestTemplateDto dto) {
        try {
            requireAdmin();
            QuestTemplate qt = questTemplateRepository.findById(id)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy quest template: " + id));

            if (dto.getTitle() != null && !dto.getTitle().trim().isEmpty()) {
                qt.setTitle(dto.getTitle().trim());
            }
            if (dto.getDescription() != null && !dto.getDescription().trim().isEmpty()) {
                qt.setDescription(dto.getDescription().trim());
            }
            if (dto.getCategory() != null) {
                qt.setCategory(dto.getCategory());
            }
            if (dto.getDifficulty() != null) {
                qt.setDifficulty(dto.getDifficulty());
            }
            qt.setModuleCode(dto.getModuleCode());
            qt.setProgramWeek(dto.getProgramWeek());
            qt.setProgramPhaseCode(QuestTemplatePhaseCodeNormalizer.normalize(dto.getProgramPhaseCode()));
            qt.setInterventionType(dto.getInterventionType());
            qt.setPrerequisiteCodesJson(dto.getPrerequisiteCodesJson());
            if (dto.getTherapistOnlyAssignable() != null) {
                qt.setTherapistOnlyAssignable(dto.getTherapistOnlyAssignable());
            }
            if (dto.getHardLocked() != null) {
                qt.setHardLocked(dto.getHardLocked());
            }

            QuestTemplate saved = questTemplateRepository.save(qt);
            return ResponseEntity.ok(ApiResponse.success("OK", new QuestTemplateDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> delete(@PathVariable UUID id) {
        try {
            requireAdmin();
            QuestTemplate qt = questTemplateRepository.findById(id)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy quest template: " + id));
            questTemplateRepository.delete(qt);
            return ResponseEntity.ok(ApiResponse.success("OK", null));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private boolean matchesKeyword(QuestTemplateDto item, String keyword) {
        if (keyword == null) {
            return true;
        }
        String normalized = keyword.toLowerCase(Locale.ROOT);
        return containsIgnoreCase(item.getTitle(), normalized)
                || containsIgnoreCase(item.getDescription(), normalized)
                || containsIgnoreCase(item.getCategory() != null ? item.getCategory().name() : null, normalized)
                || containsIgnoreCase(item.getDifficulty() != null ? item.getDifficulty().name() : null, normalized)
                || containsIgnoreCase(item.getModuleCode(), normalized)
                || containsIgnoreCase(item.getProgramPhaseCode(), normalized)
                || containsIgnoreCase(item.getInterventionType(), normalized)
                || containsIgnoreCase(item.getId() != null ? item.getId().toString() : null, normalized);
    }

    private boolean containsIgnoreCase(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }
}
