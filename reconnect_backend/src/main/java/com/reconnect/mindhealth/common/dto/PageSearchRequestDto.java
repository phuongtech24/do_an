package com.reconnect.mindhealth.common.dto;

import lombok.Data;

@Data
public class PageSearchRequestDto {
    private Integer pageIndex = 1;
    private Integer pageSize = 10;
    private String keyword;

    public int resolvePageIndexZeroBased() {
        int resolved = pageIndex != null ? pageIndex : 1;
        return Math.max(resolved - 1, 0);
    }

    public int resolvePageSize() {
        int resolved = pageSize != null ? pageSize : 10;
        resolved = Math.max(resolved, 1);
        return Math.min(resolved, 100);
    }

    public String normalizedKeyword() {
        if (keyword == null) {
            return null;
        }
        String trimmed = keyword.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
