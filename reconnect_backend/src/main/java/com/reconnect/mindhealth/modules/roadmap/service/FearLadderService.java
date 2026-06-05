package com.reconnect.mindhealth.modules.roadmap.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.assessment.entity.LsasAnswer;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSituationGroup;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.BehavioralExperimentDebriefRequestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.BehavioralExperimentDto;
import com.reconnect.mindhealth.modules.roadmap.dto.BehavioralExperimentStartRequestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.FearLadderItemDto;
import com.reconnect.mindhealth.modules.roadmap.dto.FearLadderRerateItemDto;
import com.reconnect.mindhealth.modules.roadmap.dto.FearLadderRerateRequestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientGoalDto;
import com.reconnect.mindhealth.modules.roadmap.entity.BehavioralExperiment;
import com.reconnect.mindhealth.modules.roadmap.entity.FearLadderItem;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientGoal;
import com.reconnect.mindhealth.modules.roadmap.enums.BehavioralExperimentStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderBucket;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalStatus;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.repository.BehavioralExperimentRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.FearLadderItemRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientGoalRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class FearLadderService {

    private final PatientProfileRepository patientProfileRepository;
    private final FearLadderItemRepository fearLadderItemRepository;
    private final BehavioralExperimentRepository behavioralExperimentRepository;
    private final PatientGoalRepository patientGoalRepository;

    public FearLadderService(
            PatientProfileRepository patientProfileRepository,
            FearLadderItemRepository fearLadderItemRepository,
            BehavioralExperimentRepository behavioralExperimentRepository,
            PatientGoalRepository patientGoalRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.fearLadderItemRepository = fearLadderItemRepository;
        this.behavioralExperimentRepository = behavioralExperimentRepository;
        this.patientGoalRepository = patientGoalRepository;
    }

    @Transactional
    public List<FearLadderItemDto> rebuildFromBaseline(PatientProfile patient, List<LsasAnswer> answers) {
        fearLadderItemRepository.deleteByPatientProfile_Id(patient.getId());
        PatientGoalType primaryGoalType = resolvePrimaryGoalType(patient.getId());
        List<LsasAnswer> scored = answers.stream()
                .filter(answer -> answer.getTotalScore() != null && answer.getTotalScore() > 0)
                .sorted(Comparator
                        .comparing((LsasAnswer answer) -> !matchesGoal(answer.getSituation().getSituationGroup(), primaryGoalType))
                        .thenComparing(LsasAnswer::getTotalScore)
                        .thenComparing(answer -> answer.getSituation().getSituationNumber()))
                .toList();

        int order = 1;
        for (LsasAnswer answer : scored) {
            FearLadderItem item = new FearLadderItem();
            item.setPatientProfile(patient);
            item.setSituation(answer.getSituation());
            item.setBaselineFearScore(answer.getFearScore());
            item.setBaselineAvoidanceScore(answer.getAvoidanceScore());
            item.setBaselineTotalScore(answer.getTotalScore());
            item.setCurrentFearScore(answer.getFearScore());
            item.setCurrentAvoidanceScore(answer.getAvoidanceScore());
            item.setCurrentTotalScore(answer.getTotalScore());
            item.setBucket(resolveBucket(answer.getTotalScore()));
            item.setLadderOrder(order++);
            item.setStatus(FearLadderStatus.ACTIVE);
            fearLadderItemRepository.save(item);
        }
        return getFearLadder(patient.getId());
    }

    @Transactional(readOnly = true)
    public List<FearLadderItemDto> getFearLadder(UUID patientId) {
        requirePatient(patientId);
        List<FearLadderItem> items = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId);
        PatientGoalType primaryGoalType = resolvePrimaryGoalType(patientId);
        int unlockedUntilIndex = resolveUnlockedUntilIndex(items);
        List<FearLadderItemDto> dtos = new ArrayList<>();
        for (int index = 0; index < items.size(); index++) {
            FearLadderItem item = items.get(index);
            FearLadderItemDto dto = new FearLadderItemDto(item);
            dto.setGoalMatch(matchesGoal(item.getSituation().getSituationGroup(), primaryGoalType));
            dto.setUnlocked(index <= unlockedUntilIndex);
            dto.setMasteredAt(item.getStatus() == FearLadderStatus.MASTERED ? item.getModifyDate() : null);
            dtos.add(dto);
        }
        return dtos;
    }

    @Transactional
    public List<FearLadderItemDto> rerate(FearLadderRerateRequestDto request) {
        requirePatient(request.getPatientId());
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("Thiếu danh sách tình huống cần re-rate.");
        }
        for (FearLadderRerateItemDto itemDto : request.getItems()) {
            FearLadderItem item = fearLadderItemRepository.findById(itemDto.getLadderItemId())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy Fear Ladder item."));
            if (!item.getPatientProfile().getId().equals(request.getPatientId())) {
                throw new SecurityException("Không được cập nhật thang sợ của bệnh nhân khác.");
            }
            int fear = normalizeScore(itemDto.getFearScore());
            int avoidance = normalizeScore(itemDto.getAvoidanceScore());
            int total = fear + avoidance;
            item.setCurrentFearScore(fear);
            item.setCurrentAvoidanceScore(avoidance);
            item.setCurrentTotalScore(total);
            item.setBucket(resolveBucket(total));
            item.setStatus(total <= 1 ? FearLadderStatus.MASTERED : FearLadderStatus.ACTIVE);
            fearLadderItemRepository.save(item);
        }
        return getFearLadder(request.getPatientId());
    }

    @Transactional
    public PatientGoalDto saveGoal(PatientGoalDto dto) {
        PatientProfile patient = requirePatient(dto.getPatientId());
        if (dto.getGoalType() == null) {
            throw new IllegalArgumentException("Thiếu goalType.");
        }

        String description = dto.getDescription();
        if (description == null || description.isBlank()) {
            description = switch (dto.getGoalType()) {
                case SOCIAL_INTERACTION -> "Kết bạn/mở rộng quan hệ";
                case PERFORMANCE -> "Công việc/học tập/trình bày";
                case GENERAL -> "Tự tin trong mọi tình huống";
            };
        }

        patientGoalRepository.findByPatientProfile_IdAndStatusOrderByCreateDateDesc(patient.getId(), PatientGoalStatus.ACTIVE)
                .forEach(existingGoal -> {
                    existingGoal.setStatus(PatientGoalStatus.ARCHIVED);
                    patientGoalRepository.save(existingGoal);
                });

        PatientGoal goal = new PatientGoal();
        goal.setPatientProfile(patient);
        goal.setGoalType(dto.getGoalType());
        goal.setDescription(description.trim());
        goal.setStatus(PatientGoalStatus.ACTIVE);
        return new PatientGoalDto(patientGoalRepository.save(goal));
    }

    @Transactional(readOnly = true)
    public List<PatientGoalDto> getActiveGoals(UUID patientId) {
        requirePatient(patientId);
        return patientGoalRepository
                .findByPatientProfile_IdAndStatusOrderByCreateDateDesc(patientId, PatientGoalStatus.ACTIVE)
                .stream()
                .map(PatientGoalDto::new)
                .toList();
    }

    @Transactional
    public BehavioralExperimentDto getTodayExperiment(UUID patientId) {
        PatientProfile patient = requirePatient(patientId);
        return behavioralExperimentRepository
                .findTopByPatientProfile_IdAndStatusInOrderByAssignedAtDesc(
                        patientId,
                        List.of(BehavioralExperimentStatus.PLANNED, BehavioralExperimentStatus.IN_PROGRESS))
                .map(BehavioralExperimentDto::new)
                .orElseGet(() -> new BehavioralExperimentDto(createNextExperiment(patient)));
    }

    @Transactional(readOnly = true)
    public List<BehavioralExperimentDto> getExperimentHistory(UUID patientId) {
        requirePatient(patientId);
        return behavioralExperimentRepository.findByPatientProfile_IdOrderByAssignedAtDesc(patientId)
                .stream()
                .map(BehavioralExperimentDto::new)
                .toList();
    }

    @Transactional
    public BehavioralExperimentDto startExperiment(UUID experimentId, BehavioralExperimentStartRequestDto request) {
        BehavioralExperiment experiment = requireExperiment(experimentId);
        experiment.setPrediction(request.getPrediction());
        experiment.setPredictionBelief(normalizePercent(request.getPredictionBelief()));
        experiment.setSafetyBehaviorsJson(request.getSafetyBehaviorsJson());
        experiment.setStatus(BehavioralExperimentStatus.IN_PROGRESS);
        return new BehavioralExperimentDto(behavioralExperimentRepository.save(experiment));
    }

    @Transactional
    public BehavioralExperimentDto debriefExperiment(UUID experimentId, BehavioralExperimentDebriefRequestDto request) {
        BehavioralExperiment experiment = requireExperiment(experimentId);
        experiment.setExecutionNotes(request.getExecutionNotes());
        experiment.setProofImageUrl(request.getProofImageUrl());
        experiment.setDebrief(request.getDebrief());
        experiment.setPostFearScore(normalizeScore(request.getPostFearScore()));
        experiment.setPostAvoidanceScore(normalizeScore(request.getPostAvoidanceScore()));
        experiment.setStatus(BehavioralExperimentStatus.DONE);
        experiment.setCompletedAt(LocalDateTime.now());

        FearLadderItem ladderItem = experiment.getFearLadderItem();
        int total = experiment.getPostFearScore() + experiment.getPostAvoidanceScore();
        ladderItem.setCurrentFearScore(experiment.getPostFearScore());
        ladderItem.setCurrentAvoidanceScore(experiment.getPostAvoidanceScore());
        ladderItem.setCurrentTotalScore(total);
        ladderItem.setBucket(resolveBucket(total));
        ladderItem.setStatus(total <= 1 ? FearLadderStatus.MASTERED : FearLadderStatus.ACTIVE);
        fearLadderItemRepository.save(ladderItem);

        return new BehavioralExperimentDto(behavioralExperimentRepository.save(experiment));
    }

    private BehavioralExperiment createNextExperiment(PatientProfile patient) {
        List<FearLadderItem> ladderItems = fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patient.getId());
        int unlockedUntilIndex = resolveUnlockedUntilIndex(ladderItems);
        FearLadderItem item = ladderItems.stream()
                .limit(unlockedUntilIndex + 1L)
                .filter(candidate -> candidate.getStatus() == FearLadderStatus.ACTIVE)
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Chưa có Fear Ladder hoặc tất cả tình huống đã mastered."));

        BehavioralExperiment experiment = new BehavioralExperiment();
        experiment.setPatientProfile(patient);
        experiment.setFearLadderItem(item);
        experiment.setSourceType(QuestSourceType.SYSTEM);
        experiment.setStatus(BehavioralExperimentStatus.PLANNED);
        experiment.setAssignedAt(LocalDateTime.now());
        experiment.setDueDate(LocalDateTime.now().plusDays(2));
        return behavioralExperimentRepository.save(experiment);
    }

    private PatientProfile requirePatient(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu patientId.");
        }
        return patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
    }

    private BehavioralExperiment requireExperiment(UUID experimentId) {
        return behavioralExperimentRepository.findById(experimentId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy Behavioral Experiment: " + experimentId));
    }

    private PatientGoalType resolvePrimaryGoalType(UUID patientId) {
        return patientGoalRepository
                .findByPatientProfile_IdAndStatusOrderByCreateDateDesc(patientId, PatientGoalStatus.ACTIVE)
                .stream()
                .findFirst()
                .map(PatientGoal::getGoalType)
                .orElse(PatientGoalType.GENERAL);
    }

    private int resolveUnlockedUntilIndex(List<FearLadderItem> items) {
        for (int index = 0; index < items.size(); index++) {
            if (items.get(index).getStatus() != FearLadderStatus.MASTERED) {
                return Math.min(index + 1, items.size() - 1);
            }
        }
        return items.isEmpty() ? -1 : items.size() - 1;
    }

    private FearLadderBucket resolveBucket(int total) {
        if (total <= 2) {
            return FearLadderBucket.EASY;
        }
        if (total <= 4) {
            return FearLadderBucket.MEDIUM;
        }
        return FearLadderBucket.HARD;
    }

    private boolean matchesGoal(LsasSituationGroup group, PatientGoalType goalType) {
        return switch (goalType) {
            case PERFORMANCE -> group == LsasSituationGroup.PERFORMANCE;
            case SOCIAL_INTERACTION -> group == LsasSituationGroup.SOCIAL_INTERACTION;
            case GENERAL -> true;
        };
    }

    private int normalizeScore(Integer score) {
        if (score == null) {
            return 0;
        }
        return Math.max(0, Math.min(3, score));
    }

    private int normalizePercent(Integer score) {
        if (score == null) {
            return 0;
        }
        return Math.max(0, Math.min(100, score));
    }
}
