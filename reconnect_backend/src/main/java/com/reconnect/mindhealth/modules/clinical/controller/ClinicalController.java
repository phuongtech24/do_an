package com.reconnect.mindhealth.modules.clinical.controller;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.clinical.dto.GoalSettingDto;
import com.reconnect.mindhealth.modules.clinical.dto.OnboardingStatusDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistAssignmentStatusDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.service.IClinicalService;

@RestController
@RequestMapping("/api/clinical")
public class ClinicalController {

    @Autowired
    private IClinicalService clinicalService;

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @PostMapping("/goals")
    public ResponseEntity<ApiResponse<GoalSettingDto>> saveGoals(@RequestBody GoalSettingDto dto) {
        try {
            GoalSettingDto result = clinicalService.saveGoals(dto);
            return ResponseEntity.ok(ApiResponse.success("Lưu mục tiêu trị liệu thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi lưu mục tiêu: " + e.getMessage()));
        }
    }

    @GetMapping("/goals")
    public ResponseEntity<ApiResponse<GoalSettingDto>> getGoals(@RequestParam UUID patientId) {
        try {
            GoalSettingDto result = clinicalService.getGoals(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy mục tiêu trị liệu thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải mục tiêu: " + e.getMessage()));
        }
    }

    @PostMapping("/psychoeducation/complete")
    public ResponseEntity<ApiResponse<Object>> completePsychoeducation(@RequestParam UUID patientId) {
        try {
            clinicalService.completePsychoeducation(patientId);
            return ResponseEntity.ok(ApiResponse.success("Đã ghi nhận hoàn thành phần giới thiệu trị liệu!", null));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi cập nhật psychoeducation: " + e.getMessage()));
        }
    }

    @GetMapping("/onboarding-status")
    public ResponseEntity<ApiResponse<OnboardingStatusDto>> getOnboardingStatus(@RequestParam UUID patientId) {
        try {
            OnboardingStatusDto result = clinicalService.getOnboardingStatus(patientId);
            return ResponseEntity.ok(ApiResponse.success("Lấy trạng thái onboarding thành công!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải onboarding status: " + e.getMessage()));
        }
    }

    @GetMapping("/therapist-assignment-status")
    public ResponseEntity<ApiResponse<TherapistAssignmentStatusDto>> getTherapistAssignmentStatus(@RequestParam UUID patientId) {
        try {
            PatientProfile patient = patientProfileRepository.findById(patientId).orElse(null);
            if (patient == null) {
                return ResponseEntity.ok(ApiResponse.error("Không tìm thấy bệnh nhân."));
            }

            if (patient.getTherapist() == null) {
                TherapistAssignmentStatusDto dto = new TherapistAssignmentStatusDto(
                        patientId,
                        false,
                        null,
                        null,
                        "Bạn chưa chọn chuyên gia. Hãy chọn therapist phù hợp để bắt đầu đặt lịch CBT.",
                        "STANDARD_WEEKLY",
                        "Điều trị tiêu chuẩn",
                        "1 lần / tuần",
                        "Liệu trình chuẩn gồm 14 phiên CBT hàng tuần trước khi cân nhắc giãn cách.",
                        "45-50 phút cho CBT chuẩn, 60 phút cho phiên khởi đầu, 90 phút cho thử nghiệm hành vi.",
                        "CBT_SESSION",
                        false);
                return ResponseEntity.ok(ApiResponse.success("OK", dto));
            }

            String therapistName = patient.getTherapist().getFullName();
            if (therapistName == null || therapistName.isBlank()) {
                therapistName = patient.getTherapist().getUser() != null
                        ? patient.getTherapist().getUser().getEmail()
                        : null;
            }

            TherapistAssignmentStatusDto dto = new TherapistAssignmentStatusDto(
                    patientId,
                    true,
                    patient.getTherapist().getId(),
                    therapistName,
                    buildAssignmentMessage(patient),
                    deriveCarePhaseCode(patient),
                    deriveCarePhaseLabel(patient),
                    deriveFrequencyLabel(patient),
                    derivePlanSummary(patient),
                    deriveDurationGuidance(patient),
                    deriveRecommendedPurposeCode(patient),
                    isOverrideAllowed(patient));
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi kiểm tra bác sĩ phụ trách: " + e.getMessage()));
        }
    }

    private String buildAssignmentMessage(PatientProfile patient) {
        if (isOverrideAllowed(patient)) {
            return "Bạn đang ở nhóm ưu tiên an toàn. Bác sĩ có thể ghi đè lịch chuẩn để sắp ca khẩn cấp hoặc can thiệp dày hơn.";
        }
        if (patient.getGraduatedAt() != null) {
            return "Bạn đã sang giai đoạn duy trì. Hệ thống sẽ gợi ý booster session ở các mốc 3, 6 và 12 tháng.";
        }
        if (patient.getTaperingStage() == TaperingStage.MONTHLY || patient.getTaperingStage() == TaperingStage.QUARTERLY) {
            return "Bạn đang ở giai đoạn giãn cách phiên theo tiến độ hồi phục đã thống nhất với bác sĩ.";
        }
        return "Bạn đã có chuyên gia đồng hành. Hệ thống đang gợi ý lịch CBT chuẩn 1 lần mỗi tuần.";
    }

    private String deriveCarePhaseCode(PatientProfile patient) {
        if (isOverrideAllowed(patient)) {
            return "RED_FLAG_OVERRIDE";
        }
        if (patient.getGraduatedAt() != null) {
            return "MAINTENANCE";
        }
        if (patient.getTaperingStage() == TaperingStage.MONTHLY) {
            return "TAPERING_BIWEEKLY";
        }
        if (patient.getTaperingStage() == TaperingStage.QUARTERLY) {
            return "TAPERING_3_TO_4_WEEKS";
        }
        return "STANDARD_WEEKLY";
    }

    private String deriveCarePhaseLabel(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "RED_FLAG_OVERRIDE" -> "Ngoại lệ cờ đỏ";
            case "MAINTENANCE" -> "Duy trì sau điều trị";
            case "TAPERING_BIWEEKLY" -> "Giãn cách 2 tuần / lần";
            case "TAPERING_3_TO_4_WEEKS" -> "Giãn cách 3-4 tuần / lần";
            default -> "Điều trị tiêu chuẩn";
        };
    }

    private String deriveFrequencyLabel(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "RED_FLAG_OVERRIDE" -> "2-3 lần / tuần hoặc lịch dày hơn theo bác sĩ";
            case "MAINTENANCE" -> "Booster vào mốc 3 / 6 / 12 tháng";
            case "TAPERING_BIWEEKLY" -> "1 lần / 2 tuần";
            case "TAPERING_3_TO_4_WEEKS" -> "1 lần / 3-4 tuần";
            default -> "1 lần / tuần";
        };
    }

    private String derivePlanSummary(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "RED_FLAG_OVERRIDE" -> "Ưu tiên an toàn. Bác sĩ có thể tăng tần suất gặp hoặc xếp can thiệp cường độ cao khi cần.";
            case "MAINTENANCE" -> "Đã hoàn tất liệu trình chính và chuyển sang giai đoạn theo dõi tái phát bằng booster sessions.";
            case "TAPERING_BIWEEKLY" -> "Triệu chứng đã cải thiện ở mức đủ để bắt đầu giãn lịch 2 tuần / lần.";
            case "TAPERING_3_TO_4_WEEKS" -> "Tiếp tục tự trị liệu nhiều hơn, bác sĩ theo dõi bằng nhịp hẹn 3-4 tuần / lần.";
            default -> "Liệu trình CBT chuẩn gồm 14 phiên hàng tuần để đi qua giai đoạn khởi đầu và đi sâu.";
        };
    }

    private String deriveDurationGuidance(PatientProfile patient) {
        if ("RED_FLAG_OVERRIDE".equals(deriveCarePhaseCode(patient))) {
            return "45-50 phút cho phiên hỗ trợ chuẩn; bác sĩ có thể nâng lên 90 phút hoặc sắp can thiệp dày hơn nếu nguy cơ cao.";
        }
        if ("MAINTENANCE".equals(deriveCarePhaseCode(patient))) {
            return "Booster thường phù hợp 45-60 phút; dùng 90 phút khi cần làm Behavioral Experiment trực tiếp.";
        }
        return "45-50 phút cho CBT chuẩn, 60 phút cho phiên khởi đầu, 90 phút cho Behavioral Experiment.";
    }

    private String deriveRecommendedPurposeCode(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "RED_FLAG_OVERRIDE" -> "CRISIS";
            case "MAINTENANCE" -> "BOOSTER_3M";
            default -> "CBT_SESSION";
        };
    }

    private boolean isOverrideAllowed(PatientProfile patient) {
        return Boolean.TRUE.equals(patient.getIsRedFlagActive())
                || (patient.getCurrentRiskScore() != null && patient.getCurrentRiskScore() >= 70);
    }
}
