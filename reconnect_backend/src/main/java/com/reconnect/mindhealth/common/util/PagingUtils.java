package com.reconnect.mindhealth.common.util;

import java.util.Collections;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import com.reconnect.mindhealth.common.dto.PageSearchRequestDto;

public final class PagingUtils {

    private PagingUtils() {
    }

    public static <T> Page<T> paginate(List<T> items, PageSearchRequestDto request) {
        List<T> safeItems = items != null ? items : Collections.emptyList();
        int pageIndex = request != null ? request.resolvePageIndexZeroBased() : 0;
        int pageSize = request != null ? request.resolvePageSize() : 10;
        int start = Math.min(pageIndex * pageSize, safeItems.size());
        int end = Math.min(start + pageSize, safeItems.size());
        List<T> content = safeItems.subList(start, end);
        return new PageImpl<>(content, PageRequest.of(pageIndex, pageSize), safeItems.size());
    }
}
