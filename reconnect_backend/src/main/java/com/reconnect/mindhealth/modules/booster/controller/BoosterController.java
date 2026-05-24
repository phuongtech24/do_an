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
import com.reconnect.mindhealth.modules.booster.dto.TherapistScheduleSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.ToggleSlotRequestDto;
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

    // ===== Bệnh nhân =====

    /** GET /api/booster/slots?patientId=&date= — xem slot còn trống */
    @GetMapping("/slots")
    public ResponseEntity<ApiResponse<List<AvailableSlotDto>>> getSlots(
            @RequestParam UUID patientId,
            @RequestParam(required = false) String date) {
        try {
            LocalDate d = date != null && !date.isBlank() ? LocalDate.parse(date) : LocalDate.now();
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getAvailableSlots(patientId, d)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải slots: " + e.getMessage()));
        }
    }

    /** POST /api/booster/appointments/book — đặt lịch */
    @PostMapping("/appointments/book")
    public ResponseEntity<ApiResponse<AppointmentDto>> book(@RequestBody BookAppointmentRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.bookAppointment(request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi đặt lịch: " + e.getMessage()));
        }
    }

    /** GET /api/booster/appointments/my?patientId= — xem lịch của bệnh nhân */
    @GetMapping("/appointments/my")
    public ResponseEntity<ApiResponse<List<AppointmentDto>>> myAppointments(@RequestParam UUID patientId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getMyAppointments(patientId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch hẹn: " + e.getMessage()));
        }
    }

    // ===== Bác sĩ =====

    /** GET /api/booster/schedule?therapistId=&date= — xem lịch của bác sĩ theo ngày */
    @GetMapping("/schedule")
    public ResponseEntity<ApiResponse<List<TherapistScheduleSlotDto>>> getTherapistSchedule(
            @RequestParam UUID therapistId,
            @RequestParam(required = false) String date) {
        try {
            LocalDate d = date != null && !date.isBlank() ? LocalDate.parse(date) : LocalDate.now();
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getTherapistSchedule(therapistId, d)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch: " + e.getMessage()));
        }
    }

    /** POST /api/booster/schedule/toggle — bác sĩ bật/tắt slot */
    @PostMapping("/schedule/toggle")
    public ResponseEntity<ApiResponse<TherapistScheduleSlotDto>> toggleSlot(@RequestBody ToggleSlotRequestDto request) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.toggleSlot(request)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi thay đổi slot: " + e.getMessage()));
        }
    }

    /** GET /api/booster/appointments/therapist?therapistId= — bác sĩ xem tất cả lịch hẹn của mình */
    @GetMapping("/appointments/therapist")
    public ResponseEntity<ApiResponse<List<AppointmentDto>>> therapistAppointments(@RequestParam UUID therapistId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getTherapistAppointments(therapistId)));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch hẹn: " + e.getMessage()));
        }
    }

    /** POST /api/booster/scheduling/run — trigger cron job thủ công */
    @PostMapping("/scheduling/run")
    public ResponseEntity<ApiResponse<Integer>> runScheduling() {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", schedulingService.runDailyScheduling()));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi chạy scheduling: " + e.getMessage()));
        }
    }
}
