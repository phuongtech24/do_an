package com.reconnect.mindhealth.modules.booster.controller;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import com.reconnect.mindhealth.modules.booster.dto.AppointmentDto;
import com.reconnect.mindhealth.modules.booster.dto.AvailableSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.BookAppointmentRequestDto;
import com.reconnect.mindhealth.modules.booster.dto.TherapistScheduleSlotDto;
import com.reconnect.mindhealth.modules.booster.dto.ToggleSlotRequestDto;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentStatus;
import com.reconnect.mindhealth.modules.booster.service.IBoosterService;
import com.reconnect.mindhealth.modules.booster.service.ITaperingBoosterSchedulingService;

@RestController
@RequestMapping("/api/booster")
public class BoosterController {

    private static final Logger log = LoggerFactory.getLogger(BoosterController.class);

    private final IBoosterService boosterService;
    private final ITaperingBoosterSchedulingService schedulingService;

    public BoosterController(IBoosterService boosterService, ITaperingBoosterSchedulingService schedulingService) {
        this.boosterService = boosterService;
        this.schedulingService = schedulingService;
    }

    @GetMapping("/slots")
    public ResponseEntity<ApiResponse<List<AvailableSlotDto>>> getSlots(
            @RequestParam UUID patientId,
            @RequestParam(required = false) String date) {
        try {
            LocalDate d = date != null && !date.isBlank() ? LocalDate.parse(date) : LocalDate.now();
            log.info("Get available slots: patientId={}, date={}", patientId, d);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getAvailableSlots(patientId, d)));
        } catch (Exception e) {
            log.warn("Get available slots failed: patientId={}, date={}, err={}", patientId, date, e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải slots: " + e.getMessage()));
        }
    }

    @PostMapping("/appointments/book")
    public ResponseEntity<ApiResponse<AppointmentDto>> book(@RequestBody BookAppointmentRequestDto request) {
        try {
            log.info("Book appointment: patientId={}, startAt={}", request != null ? request.getPatientId() : null,
                    request != null ? request.getStartAt() : null);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.bookAppointment(request)));
        } catch (Exception e) {
            log.warn("Book appointment failed: patientId={}, startAt={}, err={}",
                    request != null ? request.getPatientId() : null,
                    request != null ? request.getStartAt() : null,
                    e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi đặt lịch: " + e.getMessage()));
        }
    }

    @GetMapping("/appointments/my")
    public ResponseEntity<ApiResponse<List<AppointmentDto>>> myAppointments(@RequestParam UUID patientId) {
        try {
            log.info("Get my appointments: patientId={}", patientId);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getMyAppointments(patientId)));
        } catch (Exception e) {
            log.warn("Get my appointments failed: patientId={}, err={}", patientId, e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch hẹn: " + e.getMessage()));
        }
    }

    @PatchMapping("/appointments/{appointmentId}/status")
    public ResponseEntity<ApiResponse<AppointmentDto>> updateAppointmentStatus(
            @PathVariable UUID appointmentId,
            @RequestParam AppointmentStatus status) {
        try {
            log.info("Update appointment status: appointmentId={}, status={}", appointmentId, status);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.updateAppointmentStatus(appointmentId, status)));
        } catch (Exception e) {
            log.warn("Update appointment status failed: appointmentId={}, status={}, err={}", appointmentId, status, e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi cập nhật lịch hẹn: " + e.getMessage()));
        }
    }

    @GetMapping("/schedule")
    public ResponseEntity<ApiResponse<List<TherapistScheduleSlotDto>>> getTherapistSchedule(
            @RequestParam UUID therapistId,
            @RequestParam(required = false) String date) {
        try {
            LocalDate d = date != null && !date.isBlank() ? LocalDate.parse(date) : LocalDate.now();
            log.info("Get therapist schedule: therapistId={}, date={}", therapistId, d);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getTherapistSchedule(therapistId, d)));
        } catch (Exception e) {
            log.warn("Get therapist schedule failed: therapistId={}, date={}, err={}", therapistId, date, e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch: " + e.getMessage()));
        }
    }

    @PostMapping("/schedule/toggle")
    public ResponseEntity<ApiResponse<TherapistScheduleSlotDto>> toggleSlot(@RequestBody ToggleSlotRequestDto request) {
        try {
            log.info("Toggle slot: therapistId={}, date={}, time={}, open={}",
                    request != null ? request.getTherapistId() : null,
                    request != null ? request.getSlotDate() : null,
                    request != null ? request.getStartTime() : null,
                    request != null ? request.isOpen() : null);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.toggleSlot(request)));
        } catch (Exception e) {
            log.warn("Toggle slot failed: therapistId={}, date={}, time={}, open={}, err={}",
                    request != null ? request.getTherapistId() : null,
                    request != null ? request.getSlotDate() : null,
                    request != null ? request.getStartTime() : null,
                    request != null ? request.isOpen() : null,
                    e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi thay đổi slot: " + e.getMessage()));
        }
    }

    @GetMapping("/appointments/therapist")
    public ResponseEntity<ApiResponse<List<AppointmentDto>>> therapistAppointments(@RequestParam UUID therapistId) {
        try {
            log.info("Get therapist appointments: therapistId={}", therapistId);
            return ResponseEntity.ok(ApiResponse.success("OK", boosterService.getTherapistAppointments(therapistId)));
        } catch (Exception e) {
            log.warn("Get therapist appointments failed: therapistId={}, err={}", therapistId, e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải lịch hẹn: " + e.getMessage()));
        }
    }

    @PostMapping("/scheduling/run")
    public ResponseEntity<ApiResponse<Integer>> runScheduling() {
        try {
            log.info("Run scheduling (manual trigger)");
            return ResponseEntity.ok(ApiResponse.success("OK", schedulingService.runDailyScheduling()));
        } catch (Exception e) {
            log.warn("Run scheduling failed: err={}", e.toString());
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi chạy scheduling: " + e.getMessage()));
        }
    }
}

