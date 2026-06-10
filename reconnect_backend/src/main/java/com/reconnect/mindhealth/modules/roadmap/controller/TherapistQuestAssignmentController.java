package com.reconnect.mindhealth.modules.roadmap.controller;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.Comparator;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.AssignQuestRequestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientQuestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.QuestTemplateDto;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.QuestTemplateRepository;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapProgramStateService;

import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/api/therapist")
public class TherapistQuestAssignmentController {

    private final AuthContextService authContextService;
    private final PatientProfileRepository patientProfileRepository;
    private final QuestTemplateRepository questTemplateRepository;
    private final PatientQuestRepository patientQuestRepository;
    private final RoadmapProgramStateService roadmapProgramStateService;

    public TherapistQuestAssignmentController(
            AuthContextService authContextService,
            PatientProfileRepository patientProfileRepository,
            QuestTemplateRepository questTemplateRepository,
            PatientQuestRepository patientQuestRepository,
            RoadmapProgramStateService roadmapProgramStateService) {
        this.authContextService = authContextService;
        this.patientProfileRepository = patientProfileRepository;
        this.questTemplateRepository = questTemplateRepository;
        this.patientQuestRepository = patientQuestRepository;
        this.roadmapProgramStateService = roadmapProgramStateService;
    }

    @GetMapping("/quest-templates")
    public ResponseEntity<ApiResponse<List<QuestTemplateDto>>> listQuestTemplates(
            @RequestParam(name = "patientId", required = false) UUID patientId) {
        try {
            requireTherapist();
            String activePhase = null;
            if (patientId != null) {
                PatientProfile patient = patientProfileRepository.findById(patientId)
                        .orElse(null);
                if (patient != null) {
                    int programWeek = roadmapProgramStateService.resolveProgramWeek(patient);
                    if (programWeek > 0) {
                        activePhase = roadmapProgramStateService.resolvePhase(programWeek).code();
                    }
                }
            }
            final String phaseCode = activePhase;
            List<QuestTemplateDto> list = questTemplateRepository.findAll().stream()
                    .sorted(Comparator
                            .comparing((QuestTemplate item) -> phaseCode == null
                                    || !phaseCode.equalsIgnoreCase(item.getProgramPhaseCode()))
                            .thenComparing(item -> item.getProgramWeek() == null ? 99 : item.getProgramWeek())
                            .thenComparing(QuestTemplate::getTitle))
                    .map(QuestTemplateDto::new)
                    .toList();
            return ResponseEntity.ok(ApiResponse.success("OK", list));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    @PostMapping("/patients/{patientId}/quests")
    public ResponseEntity<ApiResponse<PatientQuestDto>> assignQuest(
            @PathVariable UUID patientId,
            @RequestBody AssignQuestRequestDto request) {
        try {
            User therapistUser = requireTherapist();
            if (request == null || request.getQuestTemplateId() == null) {
                throw new IllegalArgumentException("Thiếu questTemplateId.");
            }

            PatientProfile patient = patientProfileRepository.findById(patientId)
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
            if (patient.getTherapist() == null || !patient.getTherapist().getId().equals(therapistUser.getId())) {
                throw new SecurityException("Bạn chỉ được gán bài tập cho bệnh nhân đang phụ trách.");
            }

            QuestTemplate template = questTemplateRepository.findById(request.getQuestTemplateId())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bài tập CBT: " + request.getQuestTemplateId()));

            LocalDateTime now = LocalDateTime.now();
            PatientQuest pq = new PatientQuest();
            pq.setPatientProfile(patient);
            pq.setQuestTemplate(template);
            pq.setAssignedByTherapist(patient.getTherapist());
            pq.setSourceType(QuestSourceType.THERAPIST);
            pq.setStatus(QuestStatus.AVAILABLE);
            pq.setUnlockOrder(1);
            pq.setAssignedAt(now);
            pq.setDueDate(request.getDueDate() != null ? request.getDueDate() : now.plusDays(1));

            return ResponseEntity.ok(ApiResponse.success("OK", new PatientQuestDto(patientQuestRepository.save(pq))));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi: " + e.getMessage()));
        }
    }

    private User requireTherapist() {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.THERAPIST) {
            throw new SecurityException("Chỉ THERAPIST mới có quyền truy cập.");
        }
        return current;
    }
}
