package com.reconnect.mindhealth.modules.clinical.repository.projection;

import java.util.UUID;

public interface TherapistCountProjection {
    UUID getTherapistId();

    long getCount();
}
