package com.reconnect.mindhealth.modules.admin.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.admin.dto.AdminAnalyticsDto;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

@RestController
@RequestMapping("/api/admin/analytics")
public class AdminAnalyticsController {

    private final AuthContextService authContextService;
    private final PatientProfileRepository patientProfileRepository;
    private final TherapistProfileRepository therapistProfileRepository;
    private final AppointmentRepository appointmentRepository;

    public AdminAnalyticsController(AuthContextService authContextService,
            PatientProfileRepository patientProfileRepository,
            TherapistProfileRepository therapistProfileRepository,
            AppointmentRepository appointmentRepository) {
        this.authContextService = authContextService;
        this.patientProfileRepository = patientProfileRepository;
        this.therapistProfileRepository = therapistProfileRepository;
        this.appointmentRepository = appointmentRepository;
    }

    private void requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chỉ ADMIN mới có quyền truy cập.");
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<AdminAnalyticsDto>> getAnalytics() {
        try {
            requireAdmin();
            AdminAnalyticsDto dto = new AdminAnalyticsDto();

            long totalPatients = patientProfileRepository.count();
            long activePatients = patientProfileRepository.countByIsActiveTrue();
            long redFlagPatients = patientProfileRepository.countByIsRedFlagActiveTrue();
            long graduatedPatients = patientProfileRepository.countByGraduatedAtIsNotNull();

            dto.setTotalPatients(totalPatients);
            dto.setActivePatients(activePatients);
            dto.setRedFlagPatients(redFlagPatients);
            dto.setGraduatedPatients(graduatedPatients);
            dto.setGraduationRate(activePatients == 0 ? 0.0 : (graduatedPatients * 1.0 / activePatients));

            dto.setTotalTherapists(therapistProfileRepository.count());
            dto.setPendingTherapists(therapistProfileRepository.countByApprovalStatus(ApprovalStatus.PENDING));

            dto.setTotalAppointments(appointmentRepository.count());

            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
}

