package com.reconnect.mindhealth.modules.ai.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.ai.config.AiProperties;
import com.reconnect.mindhealth.modules.ai.dto.AiKnowledgeQueryDto;
import com.reconnect.mindhealth.modules.ai.model.GuideKnowledgeCard;

class GuideKnowledgeRetrieverServiceTest {

    @Test
    void explicitDailyCheckinTopicBeatsUnrelatedClinicalRoute() {
        AiProperties properties = new AiProperties();
        properties.getGuide().setRetrievalEnabled(true);
        properties.getGuide().setTopK(3);
        properties.getGuide().setMinScore(2);
        GuideKnowledgeRetrieverService service = new GuideKnowledgeRetrieverService(properties, new ObjectMapper());
        service.loadGuideKnowledgeCards();

        AiKnowledgeQueryDto query = new AiKnowledgeQueryDto();
        query.setUserMessage("Hệ thống phân luồng như nào ở màn điểm danh cảm xúc?");
        query.setScreenContext("home");
        query.setPatientRoute("URGENT_RED_FLAG");
        query.setIntent("FEATURE_EXPLAINER");
        query.setTopicHint("DAILY_CHECKIN");

        List<GuideKnowledgeCard> cards = service.retrieve(query);

        assertThat(cards).isNotEmpty();
        assertThat(cards.get(0).getTopicCode()).isEqualTo("DAILY_CHECKIN");
    }

    @Test
    void emotionalSupportRetrievesCopingCardInsteadOfLsasRoute() {
        AiProperties properties = new AiProperties();
        properties.getGuide().setRetrievalEnabled(true);
        properties.getGuide().setTopK(3);
        properties.getGuide().setMinScore(2);
        GuideKnowledgeRetrieverService service = new GuideKnowledgeRetrieverService(properties, new ObjectMapper());
        service.loadGuideKnowledgeCards();

        AiKnowledgeQueryDto query = new AiKnowledgeQueryDto();
        query.setUserMessage("Tôi đang lo, bắt đầu từ đâu?");
        query.setScreenContext("home");
        query.setPatientRoute("THERAPIST_TRACK_14_WEEKS");
        query.setIntent("CBT_SUPPORT_LIGHT");
        query.setTopicHint("COPING_CARDS_LIGHT");

        List<GuideKnowledgeCard> cards = service.retrieve(query);

        assertThat(cards).isNotEmpty();
        assertThat(cards.get(0).getTopicCode()).isEqualTo("COPING_CARDS_LIGHT");
    }
}
