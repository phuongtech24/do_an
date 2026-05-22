package com.reconnect.mindhealth.modules.booster.controller;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.service.IBoosterService;
import com.reconnect.mindhealth.modules.booster.service.ITaperingBoosterSchedulingService;

@RestController
@RequestMapping("/api/booster")
public class BoosterController {

    private final IBoosterService boosterService;
    private final ITaperingBoosterSchedulingService schedulingService;

    public BoosterController(IBoosterService boosterService, ITaperingBoosterSchedulingService schedulingService) {
        this.boosterService = boosterService;
        this.schedulingService = schedulingService;
    }

    @GetMapping("/slots")
    public ResponseEntity<ApiResponse<List<AvailableSlotDto>>> getSlots(@RequestParam UUID patientId,
            @RequestParam(required = false) String date) {
        try {
            LocalDate d = date != null && !date.isBlank() ? LocalDate.parse(date) : LocalDate.now();
            List<AvailableSlotDto> result = boosterService.getAvailableSlots(patientId, d);
            return ResponseEntity.ok(ApiResponse.success("OK", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải slots: " + e.getMessage()));
        }
    }

    @PostMapping("/appointments/book")
    public ResponseEntity<ApiResponse<AppointmentDto>> book(@RequestBody BookAppointmentRequestDto request) {
        try {
            AppointmentDto result = boosterService.bookAppointment(request);
            return ResponseEntity.ok(ApiResponse.success("OK", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi đặt lịch: " + e.getMessage()));
        }
    }

    @GetMapping("/appointments/my")
    public ResponseEntity<ApiResponse<List<AppointmentDto>>> myAppointments(@RequestParam UUID patientId) {
        try {
            List<AppointmentDto> result = boosterService.getMyAppointments(patientId);
            return ResponseEntity.ok(ApiResponse.success("OK", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch hẹn: " + e.getMessage()));
        }
    }

    @PostMapping("/scheduling/run")
    public ResponseEntity<ApiResponse<Integer>> runScheduling() {
        try {
            int created = schedulingService.runDailyScheduling();
            return ResponseEntity.ok(ApiResponse.success("OK", created));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi chạy scheduling: " + e.getMessage()));
        }
    }
}
