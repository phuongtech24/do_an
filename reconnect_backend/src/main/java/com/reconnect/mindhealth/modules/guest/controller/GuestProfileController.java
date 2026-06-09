package com.reconnect.mindhealth.modules.guest.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.guest.dto.GuestProfileDto;
import com.reconnect.mindhealth.modules.guest.dto.GuestProfileUpdateRequestDto;
import com.reconnect.mindhealth.modules.guest.service.GuestProfileSelfService;

@RestController
@RequestMapping("/api/guest/profile")
public class GuestProfileController {

    private final GuestProfileSelfService guestProfileSelfService;

    public GuestProfileController(GuestProfileSelfService guestProfileSelfService) {
        this.guestProfileSelfService = guestProfileSelfService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<GuestProfileDto>> getProfile(@RequestParam UUID guestId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", guestProfileSelfService.getProfile(guestId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<GuestProfileDto>> updateProfile(@RequestBody GuestProfileUpdateRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Đã lưu hồ sơ guest.", guestProfileSelfService.updateProfile(request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error(e.getMessage()));
        }
    }
}
