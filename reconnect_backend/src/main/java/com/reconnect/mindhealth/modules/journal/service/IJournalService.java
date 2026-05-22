package com.reconnect.mindhealth.modules.journal.service;

import java.util.List;
import java.util.UUID;
import com.reconnect.mindhealth.modules.journal.dto.JournalDto;

/**
 * Service interface for Journal business logic operations.
 */
public interface IJournalService {

    /**
     * Save a new CBT Journal (Thought Record or Credit List) securely.
     */
    JournalDto saveJournal(JournalDto dto, UUID loggedInPatientId);

    /**
     * Get list of journals for a specific patient.
     */
    List<JournalDto> getJournalsByPatient(UUID patientId);

    /**
     * Get a single journal detail, with ownership verification.
     */
    JournalDto getJournalById(UUID id, UUID patientId);
}
