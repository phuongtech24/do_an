package com.reconnect.mindhealth.modules.admin.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.admin.dto.AdminDemoControlProgressRequestDto;
import com.reconnect.mindhealth.modules.admin.dto.AdminDemoControlResultDto;
import com.reconnect.mindhealth.modules.admin.service.AdminDemoControlService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;

@RestController
@RequestMapping("/api/admin/demo")
public class AdminDemoControlController {

    private final AuthContextService authContextService;
    private final AdminDemoControlService adminDemoControlService;

    public AdminDemoControlController(
            AuthContextService authContextService,
            AdminDemoControlService adminDemoControlService) {
        this.authContextService = authContextService;
        this.adminDemoControlService = adminDemoControlService;
    }

    @PostMapping("/patients/{patientId}/unlock-lsas")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> unlockLsas(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.unlockLsas(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/trigger-lsas")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> triggerLsas(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.triggerLsas(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/set-risk")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> setRisk(
            @PathVariable UUID patientId,
            @RequestParam(defaultValue = "80") int score,
            @RequestParam(defaultValue = "true") boolean redFlag) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.setRisk(patientId, score, redFlag, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/clear-risk")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> clearRisk(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.clearRisk(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/set-lsas-band")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> setLsasBand(
            @PathVariable UUID patientId,
            @RequestParam String band) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.setLsasBand(patientId, band, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/set-program-week")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> setProgramWeek(
            @PathVariable UUID patientId,
            @RequestParam(required = false) Integer programWeek,
            @RequestBody(required = false) AdminDemoControlProgressRequestDto body) {
        try {
            User admin = requireAdmin();
            Integer effectiveWeek = programWeek != null ? programWeek : (body != null ? body.getProgramWeek() : null);
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.setProgramWeek(patientId, effectiveWeek, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/set-fear-ladder-mastery")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> setFearLadderMastery(
            @PathVariable UUID patientId,
            @RequestParam(required = false) Integer masteredCount,
            @RequestBody(required = false) AdminDemoControlProgressRequestDto body) {
        try {
            User admin = requireAdmin();
            Integer effectiveCount = masteredCount != null ? masteredCount : (body != null ? body.getMasteredCount() : null);
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.setFearLadderMastery(patientId, effectiveCount, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/reset-fear-ladder-progress")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> resetFearLadderProgress(
            @PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.resetFearLadderProgress(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/unlock-all-roadmap-content")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> unlockAllRoadmapContent(
            @PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.unlockAllRoadmapContent(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }
    @PostMapping("/patients/{patientId}/seed-daily-checkin")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> seedDailyCheckin(
            @PathVariable UUID patientId,
            @RequestParam(defaultValue = "STABLE") String mode) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.seedDailyCheckin(patientId, mode, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/seed-thought-record")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> seedThoughtRecord(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.seedThoughtRecord(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/set-tapering-stage")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> setTaperingStage(
            @PathVariable UUID patientId,
            @RequestParam String stage) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.setTaperingStage(patientId, stage, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/mark-graduated")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> markGraduated(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.markGraduated(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/reset-graduation")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> resetGraduation(@PathVariable UUID patientId) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.resetGraduation(patientId, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/trigger-booster")
    public ResponseEntity<ApiResponse<AdminDemoControlResultDto>> triggerBooster(
            @PathVariable UUID patientId,
            @RequestParam(defaultValue = "BOOSTER_3M") String purpose) {
        try {
            User admin = requireAdmin();
            return ResponseEntity.ok(ApiResponse.success("OK",
                    adminDemoControlService.triggerBooster(patientId, purpose, admin.getId())));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i: " + e.getMessage()));
        }
    }

    private User requireAdmin() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Chá»‰ ADMIN má»›i cÃ³ quyá»n dÃ¹ng Demo Controls.");
        }
        return current;
    }
}
