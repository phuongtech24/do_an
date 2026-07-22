package com.reconnect.mindhealth.modules.clinical.controller;

import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
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
import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSubmissionRepository;
import com.reconnect.mindhealth.modules.clinical.dto.GoalSettingDto;
import com.reconnect.mindhealth.modules.clinical.dto.LsasProgressDto;
import com.reconnect.mindhealth.modules.clinical.dto.LsasProgressResponseDto;
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

    @Autowired
    private LsasSubmissionRepository lsasSubmissionRepository;

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

    @GetMapping("/patient/progress/lsas")
    public ResponseEntity<ApiResponse<LsasProgressResponseDto>> getLsasProgress(@RequestParam UUID patientId) {
        try {
            List<LsasSubmission> submissions = lsasSubmissionRepository
                    .findByPatientProfile_IdOrderByCreateDateDesc(patientId);
            Collections.reverse(submissions);

            DateTimeFormatter labelFormatter = DateTimeFormatter.ofPattern("dd/MM");
            List<LsasProgressDto> chartData = submissions.stream()
                    .filter(item -> !Boolean.TRUE.equals(item.getVoided()))
                    .map(item -> new LsasProgressDto(
                            item.getCreateDate() == null
                                    ? "Lần đánh giá"
                                    : item.getCreateDate().toInstant()
                                            .atZone(ZoneId.systemDefault())
                                            .toLocalDate()
                                            .format(labelFormatter),
                            item.getTotalScore()))
                    .toList();

            if (chartData.isEmpty()) {
                return ResponseEntity.ok(ApiResponse.success(
                        "Chưa có dữ liệu LSAS.",
                        new LsasProgressResponseDto(List.of(), 0, 0,
                                "Bạn chưa có lần đánh giá LSAS nào để theo dõi tiến trình.")));
            }

            int startScore = chartData.get(0).getTotalScore();
            int currentScore = chartData.get(chartData.size() - 1).getTotalScore();
            int change = startScore - currentScore;
            String insightMessage;
            if (chartData.size() == 1) {
                insightMessage = "Đây là điểm LSAS ban đầu của bạn. Hãy đánh giá lại theo lịch để hệ thống theo dõi xu hướng thay đổi.";
            } else if (change > 0) {
                insightMessage = "Điểm LSAS của bạn đã giảm " + change
                        + " điểm so với lần đầu. Hãy tiếp tục duy trì lộ trình hiện tại.";
            } else if (change < 0) {
                insightMessage = "Điểm LSAS hiện tăng " + Math.abs(change)
                        + " điểm so với lần đầu. Bạn nên trao đổi thêm với chuyên gia phụ trách.";
            } else {
                insightMessage = "Điểm LSAS hiện chưa thay đổi so với lần đầu. Hãy tiếp tục theo dõi ở lần đánh giá tiếp theo.";
            }

            LsasProgressResponseDto dto = new LsasProgressResponseDto(
                    chartData,
                    startScore,
                    currentScore,
                    insightMessage);
            return ResponseEntity.ok(ApiResponse.success("OK", dto));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tải tiến trình phục hồi LSAS: " + e.getMessage()));
        }
    }

    @GetMapping("/therapist-assignment-status")
    public ResponseEntity<ApiResponse<TherapistAssignmentStatusDto>> getTherapistAssignmentStatus(@RequestParam UUID patientId) {
        try {
            PatientProfile patient = patientProfileRepository.findById(patientId).orElse(null);
            if (patient == null) {
                return ResponseEntity.ok(ApiResponse.error("Không tìm thấy bệnh nhân."));
            }

            if (patient.getTherapist() == null && isSelfHelpFlow(patient)) {
                TherapistAssignmentStatusDto dto = new TherapistAssignmentStatusDto(
                        patientId,
                        false,
                        null,
                        null,
                        "Bạn đang ở nhánh tự trị liệu. Giai đoạn này không bắt buộc ghép bác sĩ; app sẽ đóng vai trò hướng dẫn CBT số cho bạn.",
                        "SELF_HELP",
                        "Tự trị liệu có hướng dẫn",
                        "Theo nhịp độ cá nhân hằng ngày",
                        "Ưu tiên psychoeducation, Thought Record, Fear Ladder, Coping Cards, Daily Check-in và các công cụ tự ổn định cảm xúc.",
                        "Không cần đặt lịch bác sĩ ở giai đoạn này. Hãy tập trung vào các bài tập CBT số hóa trên app.",
                        null,
                        false);
                return ResponseEntity.ok(ApiResponse.success("OK", dto));
            }

            if (patient.getTherapist() == null && isReassuranceFlow(patient)) {
                TherapistAssignmentStatusDto dto = new TherapistAssignmentStatusDto(
                        patientId,
                        false,
                        null,
                        null,
                        "Kết quả LSAS hiện cho thấy bạn chưa nằm trong nhóm cần trị liệu chuyên sâu. App sẽ ưu tiên thông điệp an tâm và công cụ chăm sóc tinh thần cơ bản.",
                        "REASSURANCE",
                        "Theo dõi và an tâm",
                        "Tự theo dõi linh hoạt",
                        "Ưu tiên các mẹo chăm sóc tinh thần cơ bản, coping cards, check-in và theo dõi thay đổi theo thời gian.",
                        "Chưa cần đặt lịch CBT với bác sĩ ở giai đoạn này.",
                        null,
                        false);
                return ResponseEntity.ok(ApiResponse.success("OK", dto));
            }

            if (patient.getTherapist() == null && Boolean.TRUE.equals(patient.getTriageRequired())) {
                TherapistAssignmentStatusDto dto = new TherapistAssignmentStatusDto(
                        patientId,
                        false,
                        null,
                        null,
                        "Ca của bạn đang được admin lâm sàng ưu tiên tiếp nhận để đánh giá an toàn và điều phối bác sĩ phù hợp. Bạn chưa cần tự chọn chuyên gia ở bước này.",
                        "RED_FLAG_OVERRIDE",
                        "Điều phối lâm sàng khẩn",
                        "Ưu tiên xử lý ngay",
                        "Admin lâm sàng sẽ gọi, đánh giá nguy cơ ban đầu và chủ động điều phối bác sĩ điều trị phù hợp.",
                        "Khi hoàn tất điều phối, lịch CBT hoặc can thiệp cường độ cao sẽ được mở theo chỉ định lâm sàng.",
                        "CRISIS",
                        true);
                return ResponseEntity.ok(ApiResponse.success("OK", dto));
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
                        "Liệu trình chuẩn gồm 14 phiên CBT hằng tuần trước khi cân nhắc giãn cách.",
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
        if (isSelfHelpFlow(patient)) {
            return "SELF_HELP";
        }
        if (isReassuranceFlow(patient)) {
            return "REASSURANCE";
        }
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
            case "SELF_HELP" -> "Tự trị liệu có hướng dẫn";
            case "REASSURANCE" -> "Theo dõi và an tâm";
            case "RED_FLAG_OVERRIDE" -> "Ngoại lệ cờ đỏ";
            case "MAINTENANCE" -> "Duy trì sau điều trị";
            case "TAPERING_BIWEEKLY" -> "Giãn cách 2 tuần / lần";
            case "TAPERING_3_TO_4_WEEKS" -> "Giãn cách 3-4 tuần / lần";
            default -> "Điều trị tiêu chuẩn";
        };
    }

    private String deriveFrequencyLabel(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP" -> "Theo nhịp độ cá nhân hằng ngày";
            case "REASSURANCE" -> "Tự theo dõi linh hoạt";
            case "RED_FLAG_OVERRIDE" -> "2-3 lần / tuần hoặc lịch dày hơn theo bác sĩ";
            case "MAINTENANCE" -> "Booster vào mốc 3 / 6 / 12 tháng";
            case "TAPERING_BIWEEKLY" -> "1 lần / 2 tuần";
            case "TAPERING_3_TO_4_WEEKS" -> "1 lần / 3-4 tuần";
            default -> "1 lần / tuần";
        };
    }

    private String derivePlanSummary(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP" -> "Nhóm LSAS 30-59 phù hợp với luồng tự trị liệu: psychoeducation, Thought Record, Fear Ladder, Coping Cards, Daily Check-in và thực hành tự chủ mỗi ngày.";
            case "REASSURANCE" -> "Điểm LSAS hiện thấp; app ưu tiên theo dõi, trấn an và các mẹo chăm sóc tinh thần cơ bản thay vì ép vào phác đồ điều trị.";
            case "RED_FLAG_OVERRIDE" -> "Ưu tiên an toàn. Bác sĩ có thể tăng tần suất gặp hoặc xếp can thiệp cường độ cao khi cần.";
            case "MAINTENANCE" -> "Đã hoàn tất liệu trình chính và chuyển sang giai đoạn theo dõi tái phát bằng booster sessions.";
            case "TAPERING_BIWEEKLY" -> "Triệu chứng đã cải thiện ở mức độ đủ để bắt đầu giãn lịch 2 tuần / lần.";
            case "TAPERING_3_TO_4_WEEKS" -> "Tiếp tục tự trị liệu nhiều hơn, bác sĩ theo dõi bằng nhịp hẹn 3-4 tuần / lần.";
            default -> "Liệu trình CBT chuẩn gồm 14 phiên hằng tuần để đi qua giai đoạn khởi đầu và đi sâu.";
        };
    }

    private String deriveDurationGuidance(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP" -> "Không cần lịch bác sĩ ở giai đoạn này. Hãy ưu tiên các bài tập CBT số hóa ngắn 3-15 phút mỗi ngày và Daily Check-in.";
            case "REASSURANCE" -> "Chưa cần đặt lịch CBT. Bạn có thể theo dõi thêm, xem coping cards và quay lại đánh giá định kỳ khi cần.";
            case "RED_FLAG_OVERRIDE" -> "45-50 phút cho phiên hỗ trợ chuẩn; bác sĩ có thể nâng lên 90 phút hoặc sắp can thiệp dày hơn nếu nguy cơ cao.";
            case "MAINTENANCE" -> "Booster thường phù hợp 45-60 phút; dùng 90 phút khi cần làm Behavioral Experiment trực tiếp.";
            default -> "45-50 phút cho CBT chuẩn, 60 phút cho phiên khởi đầu, 90 phút cho Behavioral Experiment.";
        };
    }

    private String deriveRecommendedPurposeCode(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP", "REASSURANCE" -> null;
            case "RED_FLAG_OVERRIDE" -> "CRISIS";
            case "MAINTENANCE" -> "BOOSTER_3M";
            default -> "CBT_SESSION";
        };
    }

    private boolean isOverrideAllowed(PatientProfile patient) {
        return Boolean.TRUE.equals(patient.getIsRedFlagActive())
                || (patient.getCurrentRiskScore() != null && patient.getCurrentRiskScore() >= 70);
    }

    private boolean isSelfHelpFlow(PatientProfile patient) {
        int score = patient.getCurrentLsasScore() != null ? patient.getCurrentLsasScore() : 0;
        return score >= 30 && score <= 59;
    }

    private boolean isReassuranceFlow(PatientProfile patient) {
        int score = patient.getCurrentLsasScore() != null ? patient.getCurrentLsasScore() : 0;
        return score < 30;
    }
}
