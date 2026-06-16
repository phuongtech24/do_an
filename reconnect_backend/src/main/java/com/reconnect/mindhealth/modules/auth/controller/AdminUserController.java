package com.reconnect.mindhealth.modules.auth.controller;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

import org.springframework.data.domain.Page;
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
import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.common.util.PagingUtils;
import com.reconnect.mindhealth.modules.auth.dto.UserDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;

import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {

    private final AuthContextService authContextService;
    private final UserRepository userRepository;

    public AdminUserController(AuthContextService authContextService, UserRepository userRepository) {
        this.authContextService = authContextService;
        this.userRepository = userRepository;
    }

    private void requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chỉ ADMIN mới có quyền truy cập chức năng này.");
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<UserDto>>> listUsers() {
        try {
            requireAdmin();
            List<UserDto> users = userRepository.findAll().stream().map(UserDto::new).toList();
            return ResponseEntity.ok(ApiResponse.success("OK", users));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/paging")
    public ResponseEntity<ApiResponse<Page<UserDto>>> searchByPage(
            @RequestBody(required = false) PageSearchRequestDto request) {
        try {
            requireAdmin();
            PageSearchRequestDto safeRequest = request != null ? request : new PageSearchRequestDto();
            String keyword = safeRequest.normalizedKeyword();
            List<UserDto> users = userRepository.findAll().stream()
                    .map(UserDto::new)
                    .filter(item -> matchesKeyword(item, keyword))
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", PagingUtils.paginate(users, safeRequest)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PatchMapping("/{id}/active")
    public ResponseEntity<ApiResponse<UserDto>> setActive(@PathVariable UUID id, @RequestParam boolean active) {
        try {
            requireAdmin();
            User user = userRepository.findById(id)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user với id: " + id));
            user.setIsActive(active);
            User saved = userRepository.save(user);
            return ResponseEntity.ok(ApiResponse.success("OK", new UserDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PatchMapping("/{id}/role")
    public ResponseEntity<ApiResponse<UserDto>> setRole(@PathVariable UUID id, @RequestParam Role role) {
        try {
            requireAdmin();
            User user = userRepository.findById(id)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy user với id: " + id));
            user.setRole(role);
            User saved = userRepository.save(user);
            return ResponseEntity.ok(ApiResponse.success("OK", new UserDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private boolean matchesKeyword(UserDto item, String keyword) {
        if (keyword == null) {
            return true;
        }
        String normalized = keyword.toLowerCase(Locale.ROOT);
        return containsIgnoreCase(item.getEmail(), normalized)
                || containsIgnoreCase(item.getUsername(), normalized)
                || containsIgnoreCase(item.getRole() != null ? item.getRole().name() : null, normalized)
                || containsIgnoreCase(item.getId() != null ? item.getId().toString() : null, normalized);
    }

    private boolean containsIgnoreCase(String value, String keyword) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(keyword);
    }
}
