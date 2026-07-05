package com.reconnect.mindhealth.modules.ai.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class GuideChatRoutingServiceTest {

    private final GuideChatRoutingService service = new GuideChatRoutingService();

    @Test
    void emotionalSupportTakesPriorityOverGenericNextStep() {
        String message = "Tôi đang lo, bắt đầu từ đâu?";

        assertThat(service.detectIntent(message)).isEqualTo("CBT_SUPPORT_LIGHT");
        assertThat(service.detectTopicHint(message, "home", "CBT_SUPPORT_LIGHT"))
                .isEqualTo("COPING_CARDS_LIGHT");
    }

    @Test
    void dailyCheckinQuestionRoutesToDailyCheckinKnowledge() {
        String message = "Hệ thống phân luồng như nào ở màn điểm danh cảm xúc?";

        assertThat(service.detectIntent(message)).isEqualTo("FEATURE_EXPLAINER");
        assertThat(service.detectTopicHint(message, "home", "FEATURE_EXPLAINER"))
                .isEqualTo("DAILY_CHECKIN");
    }

    @Test
    void explicitLsasQuestionStillRoutesToLsas() {
        String message = "Kết quả LSAS được phân luồng như nào?";

        assertThat(service.detectTopicHint(message, "home", service.detectIntent(message)))
                .isEqualTo("LSAS_ROUTING");
    }
}
