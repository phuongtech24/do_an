package com.reconnect.mindhealth.modules.clinical.controller;

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

    @PostMapping("/goals")
    public ResponseEntity<ApiResponse<GoalSettingDto>> saveGoals(@RequestBody GoalSettingDto dto) {
        try {
            GoalSettingDto result = clinicalService.saveGoals(dto);
            return ResponseEntity.ok(ApiResponse.success("LÆ°u má»¥c tiÃªu trá»‹ liá»‡u thÃ nh cÃ´ng!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i khi lÆ°u má»¥c tiÃªu: " + e.getMessage()));
        }
    }

    @GetMapping("/goals")
    public ResponseEntity<ApiResponse<GoalSettingDto>> getGoals(@RequestParam UUID patientId) {
        try {
            GoalSettingDto result = clinicalService.getGoals(patientId);
            return ResponseEntity.ok(ApiResponse.success("Láº¥y má»¥c tiÃªu trá»‹ liá»‡u thÃ nh cÃ´ng!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i khi táº£i má»¥c tiÃªu: " + e.getMessage()));
        }
    }

    @PostMapping("/psychoeducation/complete")
    public ResponseEntity<ApiResponse<Object>> completePsychoeducation(@RequestParam UUID patientId) {
        try {
            clinicalService.completePsychoeducation(patientId);
            return ResponseEntity.ok(ApiResponse.success("ÄÃ£ ghi nháº­n hoÃ n thÃ nh pháº§n giá»›i thiá»‡u trá»‹ liá»‡u!", null));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i khi cáº­p nháº­t psychoeducation: " + e.getMessage()));
        }
    }

    @GetMapping("/onboarding-status")
    public ResponseEntity<ApiResponse<OnboardingStatusDto>> getOnboardingStatus(@RequestParam UUID patientId) {
        try {
            OnboardingStatusDto result = clinicalService.getOnboardingStatus(patientId);
            return ResponseEntity.ok(ApiResponse.success("Láº¥y tráº¡ng thÃ¡i onboarding thÃ nh cÃ´ng!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lá»—i khi táº£i onboarding status: " + e.getMessage()));
        }
    }

    @GetMapping("/patient/progress/lsas")
    public ResponseEntity<ApiResponse<LsasProgressResponseDto>> getLsasProgress() {
        try {
            List<LsasProgressDto> chartData = List.of(
                    new LsasProgressDto("W0", 95),
                    new LsasProgressDto("W2", 82),
                    new LsasProgressDto("W4", 65),
                    new LsasProgressDto("W6", 45),
                    new LsasProgressDto("W8", 25)
            );

            int startScore = 95;
            int currentScore = 25;
            String insightMessage = currentScore < 30
                    ? "Sự tiến bộ vượt bậc! Bạn đã giảm từ mức Rất nặng xuống mức Ổn định."
                    : "Bạn đang có tiến triển tích cực. Hãy tiếp tục duy trì lộ trình trị liệu.";

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
                return ResponseEntity.ok(ApiResponse.error("KhÃ´ng tÃ¬m tháº¥y bá»‡nh nhÃ¢n."));
            }

            if (patient.getTherapist() == null && isSelfHelpFlow(patient)) {
                TherapistAssignmentStatusDto dto = new TherapistAssignmentStatusDto(
                        patientId,
                        false,
                        null,
                        null,
                        "Báº¡n Ä‘ang á»Ÿ nhÃ¡nh tá»± trá»‹ liá»‡u. Giai Ä‘oáº¡n nÃ y khÃ´ng báº¯t buá»™c ghÃ©p bÃ¡c sÄ©; app sáº½ Ä‘Ã³ng vai trÃ² hÆ°á»›ng dáº«n CBT sá»‘ cho báº¡n.",
                        "SELF_HELP",
                        "Tá»± trá»‹ liá»‡u cÃ³ hÆ°á»›ng dáº«n",
                        "Theo nhá»‹p Ä‘á»™ cÃ¡ nhÃ¢n háº±ng ngÃ y",
                        "Æ¯u tiÃªn psychoeducation, Thought Record, Fear Ladder, Coping Cards, Daily Check-in vÃ  cÃ¡c cÃ´ng cá»¥ tá»± á»•n Ä‘á»‹nh cáº£m xÃºc.",
                        "KhÃ´ng cáº§n Ä‘áº·t lá»‹ch bÃ¡c sÄ© á»Ÿ giai Ä‘oáº¡n nÃ y. HÃ£y táº­p trung vÃ o cÃ¡c bÃ i táº­p CBT sá»‘ hÃ³a trÃªn app.",
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
                        "Káº¿t quáº£ LSAS hiá»‡n cho tháº¥y báº¡n chÆ°a náº±m trong nhÃ³m cáº§n trá»‹ liá»‡u chuyÃªn sÃ¢u. App sáº½ Æ°u tiÃªn thÃ´ng Ä‘iá»‡p an tÃ¢m vÃ  cÃ´ng cá»¥ chÄƒm sÃ³c tinh tháº§n cÆ¡ báº£n.",
                        "REASSURANCE",
                        "Theo dÃµi vÃ  an tÃ¢m",
                        "Tá»± theo dÃµi linh hoáº¡t",
                        "Æ¯u tiÃªn cÃ¡c máº¹o chÄƒm sÃ³c tinh tháº§n cÆ¡ báº£n, coping cards, check-in vÃ  theo dÃµi thay Ä‘á»•i theo thá»i gian.",
                        "ChÆ°a cáº§n Ä‘áº·t lá»‹ch CBT vá»›i bÃ¡c sÄ© á»Ÿ giai Ä‘oáº¡n nÃ y.",
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
                        "Ca cá»§a báº¡n Ä‘ang Ä‘Æ°á»£c admin lÃ¢m sÃ ng Æ°u tiÃªn tiáº¿p nháº­n Ä‘á»ƒ Ä‘Ã¡nh giÃ¡ an toÃ n vÃ  Ä‘iá»u phá»‘i bÃ¡c sÄ© phÃ¹ há»£p. Báº¡n chÆ°a cáº§n tá»± chá»n chuyÃªn gia á»Ÿ bÆ°á»›c nÃ y.",
                        "RED_FLAG_OVERRIDE",
                        "Äiá»u phá»‘i lÃ¢m sÃ ng kháº©n",
                        "Æ¯u tiÃªn xá»­ lÃ½ ngay",
                        "Admin lÃ¢m sÃ ng sáº½ gá»i, Ä‘Ã¡nh giÃ¡ nguy cÆ¡ ban Ä‘áº§u vÃ  chá»§ Ä‘á»™ng Ä‘iá»u phá»‘i bÃ¡c sÄ© Ä‘iá»u trá»‹ phÃ¹ há»£p.",
                        "Khi hoÃ n táº¥t Ä‘iá»u phá»‘i, lá»‹ch CBT hoáº·c can thiá»‡p cÆ°á»ng Ä‘á»™ cao sáº½ Ä‘Æ°á»£c má»Ÿ theo chá»‰ Ä‘á»‹nh lÃ¢m sÃ ng.",
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
                        "Báº¡n chÆ°a chá»n chuyÃªn gia. HÃ£y chá»n therapist phÃ¹ há»£p Ä‘á»ƒ báº¯t Ä‘áº§u Ä‘áº·t lá»‹ch CBT.",
                        "STANDARD_WEEKLY",
                        "Äiá»u trá»‹ tiÃªu chuáº©n",
                        "1 láº§n / tuáº§n",
                        "Liá»‡u trÃ¬nh chuáº©n gá»“m 14 phiÃªn CBT háº±ng tuáº§n trÆ°á»›c khi cÃ¢n nháº¯c giÃ£n cÃ¡ch.",
                        "45-50 phÃºt cho CBT chuáº©n, 60 phÃºt cho phiÃªn khá»Ÿi Ä‘áº§u, 90 phÃºt cho thá»­ nghiá»‡m hÃ nh vi.",
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
            return ResponseEntity.ok(ApiResponse.error("Lá»—i khi kiá»ƒm tra bÃ¡c sÄ© phá»¥ trÃ¡ch: " + e.getMessage()));
        }
    }

    private String buildAssignmentMessage(PatientProfile patient) {
        if (isOverrideAllowed(patient)) {
            return "Báº¡n Ä‘ang á»Ÿ nhÃ³m Æ°u tiÃªn an toÃ n. BÃ¡c sÄ© cÃ³ thá»ƒ ghi Ä‘Ã¨ lá»‹ch chuáº©n Ä‘á»ƒ sáº¯p ca kháº©n cáº¥p hoáº·c can thiá»‡p dÃ y hÆ¡n.";
        }
        if (patient.getGraduatedAt() != null) {
            return "Báº¡n Ä‘Ã£ sang giai Ä‘oáº¡n duy trÃ¬. Há»‡ thá»‘ng sáº½ gá»£i Ã½ booster session á»Ÿ cÃ¡c má»‘c 3, 6 vÃ  12 thÃ¡ng.";
        }
        if (patient.getTaperingStage() == TaperingStage.MONTHLY || patient.getTaperingStage() == TaperingStage.QUARTERLY) {
            return "Báº¡n Ä‘ang á»Ÿ giai Ä‘oáº¡n giÃ£n cÃ¡ch phiÃªn theo tiáº¿n Ä‘á»™ há»“i phá»¥c Ä‘Ã£ thá»‘ng nháº¥t vá»›i bÃ¡c sÄ©.";
        }
        return "Báº¡n Ä‘Ã£ cÃ³ chuyÃªn gia Ä‘á»“ng hÃ nh. Há»‡ thá»‘ng Ä‘ang gá»£i Ã½ lá»‹ch CBT chuáº©n 1 láº§n má»—i tuáº§n.";
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
            case "SELF_HELP" -> "Tá»± trá»‹ liá»‡u cÃ³ hÆ°á»›ng dáº«n";
            case "REASSURANCE" -> "Theo dÃµi vÃ  an tÃ¢m";
            case "RED_FLAG_OVERRIDE" -> "Ngoáº¡i lá»‡ cá» Ä‘á»";
            case "MAINTENANCE" -> "Duy trÃ¬ sau Ä‘iá»u trá»‹";
            case "TAPERING_BIWEEKLY" -> "GiÃ£n cÃ¡ch 2 tuáº§n / láº§n";
            case "TAPERING_3_TO_4_WEEKS" -> "GiÃ£n cÃ¡ch 3-4 tuáº§n / láº§n";
            default -> "Äiá»u trá»‹ tiÃªu chuáº©n";
        };
    }

    private String deriveFrequencyLabel(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP" -> "Theo nhá»‹p Ä‘á»™ cÃ¡ nhÃ¢n háº±ng ngÃ y";
            case "REASSURANCE" -> "Tá»± theo dÃµi linh hoáº¡t";
            case "RED_FLAG_OVERRIDE" -> "2-3 láº§n / tuáº§n hoáº·c lá»‹ch dÃ y hÆ¡n theo bÃ¡c sÄ©";
            case "MAINTENANCE" -> "Booster vÃ o má»‘c 3 / 6 / 12 thÃ¡ng";
            case "TAPERING_BIWEEKLY" -> "1 láº§n / 2 tuáº§n";
            case "TAPERING_3_TO_4_WEEKS" -> "1 láº§n / 3-4 tuáº§n";
            default -> "1 láº§n / tuáº§n";
        };
    }

    private String derivePlanSummary(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP" -> "NhÃ³m LSAS 30-59 phÃ¹ há»£p vá»›i luá»“ng tá»± trá»‹ liá»‡u: psychoeducation, Thought Record, Fear Ladder, Coping Cards, Daily Check-in vÃ  thá»±c hÃ nh tá»± chá»§ má»—i ngÃ y.";
            case "REASSURANCE" -> "Äiá»ƒm LSAS hiá»‡n tháº¥p; app Æ°u tiÃªn theo dÃµi, tráº¥n an vÃ  cÃ¡c máº¹o chÄƒm sÃ³c tinh tháº§n cÆ¡ báº£n thay vÃ¬ Ã©p vÃ o phÃ¡c Ä‘á»“ Ä‘iá»u trá»‹.";
            case "RED_FLAG_OVERRIDE" -> "Æ¯u tiÃªn an toÃ n. BÃ¡c sÄ© cÃ³ thá»ƒ tÄƒng táº§n suáº¥t gáº·p hoáº·c xáº¿p can thiá»‡p cÆ°á»ng Ä‘á»™ cao khi cáº§n.";
            case "MAINTENANCE" -> "ÄÃ£ hoÃ n táº¥t liá»‡u trÃ¬nh chÃ­nh vÃ  chuyá»ƒn sang giai Ä‘oáº¡n theo dÃµi tÃ¡i phÃ¡t báº±ng booster sessions.";
            case "TAPERING_BIWEEKLY" -> "Triá»‡u chá»©ng Ä‘Ã£ cáº£i thiá»‡n á»Ÿ má»©c Ä‘á»™ Ä‘á»§ Ä‘á»ƒ báº¯t Ä‘áº§u giÃ£n lá»‹ch 2 tuáº§n / láº§n.";
            case "TAPERING_3_TO_4_WEEKS" -> "Tiáº¿p tá»¥c tá»± trá»‹ liá»‡u nhiá»u hÆ¡n, bÃ¡c sÄ© theo dÃµi báº±ng nhá»‹p háº¹n 3-4 tuáº§n / láº§n.";
            default -> "Liá»‡u trÃ¬nh CBT chuáº©n gá»“m 14 phiÃªn háº±ng tuáº§n Ä‘á»ƒ Ä‘i qua giai Ä‘oáº¡n khá»Ÿi Ä‘áº§u vÃ  Ä‘i sÃ¢u.";
        };
    }

    private String deriveDurationGuidance(PatientProfile patient) {
        return switch (deriveCarePhaseCode(patient)) {
            case "SELF_HELP" -> "KhÃ´ng cáº§n lá»‹ch bÃ¡c sÄ© á»Ÿ giai Ä‘oáº¡n nÃ y. HÃ£y Æ°u tiÃªn cÃ¡c bÃ i táº­p CBT sá»‘ hÃ³a ngáº¯n 3-15 phÃºt má»—i ngÃ y vÃ  Daily Check-in.";
            case "REASSURANCE" -> "ChÆ°a cáº§n Ä‘áº·t lá»‹ch CBT. Báº¡n cÃ³ thá»ƒ theo dÃµi thÃªm, xem coping cards vÃ  quay láº¡i Ä‘Ã¡nh giÃ¡ Ä‘á»‹nh ká»³ khi cáº§n.";
            case "RED_FLAG_OVERRIDE" -> "45-50 phÃºt cho phiÃªn há»— trá»£ chuáº©n; bÃ¡c sÄ© cÃ³ thá»ƒ nÃ¢ng lÃªn 90 phÃºt hoáº·c sáº¯p can thiá»‡p dÃ y hÆ¡n náº¿u nguy cÆ¡ cao.";
            case "MAINTENANCE" -> "Booster thÆ°á»ng phÃ¹ há»£p 45-60 phÃºt; dÃ¹ng 90 phÃºt khi cáº§n lÃ m Behavioral Experiment trá»±c tiáº¿p.";
            default -> "45-50 phÃºt cho CBT chuáº©n, 60 phÃºt cho phiÃªn khá»Ÿi Ä‘áº§u, 90 phÃºt cho Behavioral Experiment.";
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

