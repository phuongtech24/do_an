package com.reconnect.mindhealth.modules.ai.service;

import java.text.Normalizer;
import java.util.Locale;

import org.springframework.stereotype.Service;

@Service
public class GuideChatRoutingService {

    public String detectIntent(String userMessage) {
        String message = normalize(userMessage);
        if (containsAny(message, "khong an toan", "cap cuu", "khan cap", "nguy hiem", "co do")) {
            return "SAFETY_ESCALATION";
        }
        if (containsAny(message, "toi dang lo", "toi lo", "lo qua", "cang thang", "hoang", "tran an", "binh tinh")) {
            return "CBT_SUPPORT_LIGHT";
        }
        if (containsAny(message, "giai thich", "tai sao", "y nghia", "co che", "nhu nao", "phan luong")) {
            return "FEATURE_EXPLAINER";
        }
        if (containsAny(message, "lam gi tiep", "tiep theo", "bat dau tu dau", "nen lam gi")) {
            return "NEXT_STEP";
        }
        return "APP_GUIDE";
    }

    public String detectTopicHint(String userMessage, String screenContext, String intent) {
        String message = normalize(userMessage);
        if (containsAny(message, "diem danh", "cam xuc", "5 chi so", "safety gate", "chot an toan")) {
            return "DAILY_CHECKIN";
        }
        if (containsAny(message, "lsas", "24 cau", "ket qua lsas", "phan luong lsas")) {
            return "LSAS_ROUTING";
        }
        if (containsAny(message, "nhat ky suy nghi", "thought record", "suy nghi tu dong")) {
            return "THOUGHT_RECORD";
        }
        if (containsAny(message, "hanh vi an toan", "safety behavior")) {
            return "SAFETY_BEHAVIORS_EXPLAINER";
        }
        if (containsAny(message, "thu nghiem hanh vi", "behavioral experiment", "bai thuc hanh")) {
            return "BEHAVIORAL_EXPERIMENT_SETUP";
        }
        if (containsAny(message, "fear ladder", "thang so", "lo trinh")) {
            return "ROADMAP_OVERVIEW";
        }
        if (containsAny(message, "dat lich", "lich hen", "tham van", "telehealth")) {
            return "TELEHEALTH";
        }
        if (containsAny(message, "muc tieu", "goal setting")) {
            return "GOAL_SETTING";
        }
        if ("CBT_SUPPORT_LIGHT".equals(intent)) {
            return "COPING_CARDS_LIGHT";
        }

        String screen = normalize(screenContext);
        if (screen.contains("daily-checkin")) {
            return "DAILY_CHECKIN";
        }
        if (screen.contains("thought-record") || screen.contains("journal")) {
            return "THOUGHT_RECORD";
        }
        if (screen.contains("behavioral-experiment")) {
            return "BEHAVIORAL_EXPERIMENT_SETUP";
        }
        if (screen.contains("roadmap") || screen.contains("fear-ladder")) {
            return "ROADMAP_OVERVIEW";
        }
        if (screen.contains("telehealth") || screen.contains("booking")) {
            return "TELEHEALTH";
        }
        if (screen.contains("goal-setting")) {
            return "GOAL_SETTING";
        }
        if (screen.contains("lsas")) {
            return "LSAS_OVERVIEW";
        }
        return "";
    }

    private boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(normalize(keyword))) {
                return true;
            }
        }
        return false;
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }
        return Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("\\s+", " ")
                .trim();
    }
}
