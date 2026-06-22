package com.reconnect.mindhealth.modules.ai.dto;

public class GuideChatSuggestedActionDto {

    private String label;

    private String route;

    public GuideChatSuggestedActionDto() {
    }

    public GuideChatSuggestedActionDto(String label, String route) {
        this.label = label;
        this.route = route;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }
}
