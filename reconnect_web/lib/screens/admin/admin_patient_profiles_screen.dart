import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/admin_patient_profile_model.dart';
import '../../features/admin/data/models/therapist_applicant_model.dart';
import '../../features/admin/data/repositories/admin_patient_profile_repository.dart';
import '../../features/admin/data/repositories/admin_therapist_approval_repository.dart';
import '../../features/admin/data/repositories/admin_user_repository.dart';
import '../../shared/widgets/pagination_bar.dart';
import '../../theme/app_colors.dart';

class AdminPatientProfilesScreen extends StatefulWidget {
  const AdminPatientProfilesScreen({super.key});

  @override
  State<AdminPatientProfilesScreen> createState() => _AdminPatientProfilesScreenState();
}

class _AdminPatientProfilesScreenState extends State<AdminPatientProfilesScreen> {
  final AdminPatientProfileRepository _repo = AdminPatientProfileRepository();
  final AdminUserRepository _userRepo = AdminUserRepository();
  final AdminTherapistApprovalRepository _therapistRepo = AdminTherapistApprovalRepository();

  bool _loading = false;
  String _error = '';
  String _query = '';
  bool _redFlagOnly = false;
  bool _triageOnly = false;
  int _pageIndex = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalElements = 0;

  List<AdminPatientProfileModel> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({int? pageIndex, int? pageSize, String? keyword}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Chưa đăng nhập.');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
      if (pageIndex != null) _pageIndex = pageIndex;
      if (pageSize != null) _pageSize = pageSize;
      if (keyword != null) _query = keyword;
    });
    try {
      final page = await _repo.listPatientsPaged(
        token: token,
        redFlagOnly: _redFlagOnly,
        triageOnly: _triageOnly,
        keyword: _query,
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = page.content;
        _totalPages = page.totalPages;
        _totalElements = page.totalElements;
        _pageIndex = page.pageIndex;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(AdminPatientProfileModel item, bool active) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _error = '';
      _items = _items.map((x) => x.patientId == item.patientId ? x.copyWith(active: active) : x).toList();
    });

    try {
      await _userRepo.setActive(token: token, userId: item.patientId, active: active);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
    }
  }

  Future<void> _assignTherapist(AdminPatientProfileModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final therapists = await _therapistRepo.list(token: token, status: 'ACTIVE');
      if (!mounted) return;
      setState(() => _loading = false);
      await _showAssignDialog(item, therapists);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _showAssignDialog(AdminPatientProfileModel item, List<TherapistApplicantModel> therapists) async {
    String? selectedId = item.therapistId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Gán chuyên gia phụ trách',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bệnh nhân: ${item.nickname ?? item.email ?? item.patientId}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedId,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Chuyên gia (ACTIVE)'),
                items: therapists
                    .map((t) => DropdownMenuItem<String>(
                          value: t.therapistId,
                          enabled: !(t.caseloadFull && selectedId != t.therapistId),
                          child: Text('${t.fullName} • ${t.email} • ${t.caseloadCount}/${t.caseloadLimit}${t.caseloadFull ? " • Đã đủ lịch" : ""}', overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => selectedId = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true || selectedId == null || selectedId!.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await _repo.assignTherapist(token: token, patientId: item.patientId, therapistId: selectedId!);
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gán chuyên gia cho bệnh nhân.'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _runTriageAction(
    AdminPatientProfileModel item,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final message = await _repo.triageAction(
        token: token,
        patientId: item.patientId,
        action: action,
        body: body,
      );
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _runDemoAction(
    AdminPatientProfileModel item,
    String action, {
    Map<String, String>? query,
  }) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final message = await _repo.runDemoAction(
        token: token,
        patientId: item.patientId,
        action: action,
        query: query,
      );
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showDemoControls(AdminPatientProfileModel item) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Demo Controls',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: SizedBox(
          width: 440,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bệnh nhân: ${item.nickname ?? item.email ?? item.patientId}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Các thao tác này chỉ dùng để demo/clinical override, không dùng cho luồng bệnh nhân thường ngày.',
                    style: TextStyle(color: Colors.black54, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  const _DemoSectionLabel('1. Demo phân luồng LSAS'),
                  _DemoActionTile(
                    icon: Icons.rule_folder_outlined,
                    title: 'LSAS rất thấp (<30)',
                    subtitle: 'Chỉ đổi routing sang nhánh an tâm, không tự mở hết bài tập.',
                    onTap: () => Navigator.pop(context, 'set-lsas-band:REASSURANCE'),
                  ),
                  _DemoActionTile(
                    icon: Icons.self_improvement_outlined,
                    title: 'LSAS nhẹ/vừa (30-59)',
                    subtitle: 'Đưa bệnh nhân vào nhánh tự trị liệu Self-help.',
                    onTap: () => Navigator.pop(context, 'set-lsas-band:SELF_HELP'),
                  ),
                  _DemoActionTile(
                    icon: Icons.psychology_alt_outlined,
                    title: 'LSAS rõ rệt (60-89)',
                    subtitle: 'Đưa bệnh nhân vào therapist track 14 tuần, chưa ép tiến độ ladder.',
                    onTap: () => Navigator.pop(context, 'set-lsas-band:THERAPIST_TRACK'),
                  ),
                  _DemoActionTile(
                    icon: Icons.crisis_alert_outlined,
                    title: 'LSAS khẩn cấp (>=90)',
                    subtitle: 'Bật nhánh urgent red flag từ assessment.',
                    onTap: () => Navigator.pop(context, 'set-lsas-band:URGENT_RED_FLAG'),
                  ),
                  const SizedBox(height: 8),
                  const _DemoSectionLabel('2. Demo tiến trình trị liệu'),
                  _DemoActionTile(
                    icon: Icons.looks_one_outlined,
                    title: 'Đặt tuần trị liệu = 4',
                    subtitle: 'Ép bệnh nhân sang phase thực tế tuần 4.',
                    onTap: () => Navigator.pop(context, 'set-program-week:4'),
                  ),
                  _DemoActionTile(
                    icon: Icons.looks_3_outlined,
                    title: 'Đặt tuần trị liệu = 8',
                    subtitle: 'Ép bệnh nhân sang phase thực tế tuần 8.',
                    onTap: () => Navigator.pop(context, 'set-program-week:8'),
                  ),
                  _DemoActionTile(
                    icon: Icons.looks_5_outlined,
                    title: 'Đặt tuần trị liệu = 12',
                    subtitle: 'Đẩy sang phase can thiệp sâu để demo gần tốt nghiệp.',
                    onTap: () => Navigator.pop(context, 'set-program-week:12'),
                  ),
                  _DemoActionTile(
                    icon: Icons.flag_circle_outlined,
                    title: 'Đặt tuần trị liệu = 14',
                    subtitle: 'Dùng trước khi demo tốt nghiệp / booster.',
                    onTap: () => Navigator.pop(context, 'set-program-week:14'),
                  ),
                  _DemoActionTile(
                    icon: Icons.stairs_outlined,
                    title: 'Fear Ladder: làm chủ 3 bậc',
                    subtitle: 'Ép 3 bậc đầu sang trạng thái đã làm chủ.',
                    onTap: () => Navigator.pop(context, 'set-fear-ladder-mastery:3'),
                  ),
                  _DemoActionTile(
                    icon: Icons.trending_up_outlined,
                    title: 'Fear Ladder: làm chủ 5 bậc',
                    subtitle: 'Ép tiến độ sâu hơn để demo mở khóa nhanh.',
                    onTap: () => Navigator.pop(context, 'set-fear-ladder-mastery:5'),
                  ),
                  _DemoActionTile(
                    icon: Icons.verified_outlined,
                    title: 'Fear Ladder: mở tối đa cho tốt nghiệp',
                    subtitle: 'Đặt toàn bộ bậc sang đã làm chủ để chuẩn bị mark graduated.',
                    onTap: () => Navigator.pop(context, 'set-fear-ladder-mastery:999'),
                  ),
                  _DemoActionTile(
                    icon: Icons.all_inclusive_outlined,
                    title: 'Mở khóa toàn bộ roadmap demo',
                    subtitle: 'Đẩy nhanh lên tuần 14, mở tối đa ladder và tạo bài hệ thống hôm nay.',
                    onTap: () => Navigator.pop(context, 'unlock-all-roadmap-content'),
                  ),
                  _DemoActionTile(
                    icon: Icons.restart_alt,
                    title: 'Reset tiến độ Fear Ladder',
                    subtitle: 'Xóa tiến độ bậc đã làm chủ để demo lại từ đầu.',
                    onTap: () => Navigator.pop(context, 'reset-fear-ladder-progress'),
                  ),
                  const SizedBox(height: 8),
                  const _DemoSectionLabel('3. Daily Check-in / Thought Record'),
                  _DemoActionTile(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Seed Daily Check-in ổn định',
                    subtitle: 'Tạo check-in mẫu nhánh 0-3 để demo coping mode.',
                    onTap: () => Navigator.pop(context, 'seed-daily-checkin:STABLE'),
                  ),
                  _DemoActionTile(
                    icon: Icons.balance_outlined,
                    title: 'Seed Daily Check-in mức 4-5',
                    subtitle: 'Tạo check-in mẫu nhánh cho lựa chọn Thought Record hoặc Thẻ đối phó.',
                    onTap: () => Navigator.pop(context, 'seed-daily-checkin:CHOICE_4_5'),
                  ),
                  _DemoActionTile(
                    icon: Icons.auto_graph_outlined,
                    title: 'Seed Daily Check-in mức 6-8',
                    subtitle: 'Tạo check-in mẫu nhánh AI đẩy sang Thought Record.',
                    onTap: () => Navigator.pop(context, 'seed-daily-checkin:THOUGHT_RECORD_6_8'),
                  ),
                  _DemoActionTile(
                    icon: Icons.emergency_share_outlined,
                    title: 'Seed Daily Check-in không an toàn',
                    subtitle: 'Bật safety gate UNSAFE để demo cờ đỏ và UI khẩn cấp.',
                    onTap: () => Navigator.pop(context, 'seed-daily-checkin:UNSAFE'),
                  ),
                  _DemoActionTile(
                    icon: Icons.edit_note_outlined,
                    title: 'Seed Thought Record mẫu',
                    subtitle: 'Tạo nhanh một thought record cho lịch sử patient/therapist review.',
                    onTap: () => Navigator.pop(context, 'seed-thought-record'),
                  ),
                  const SizedBox(height: 8),
                  const _DemoSectionLabel('4. Graduation / Booster'),
                  _DemoActionTile(
                    icon: Icons.timelapse_outlined,
                    title: 'Tapering 2 tuần/lần',
                    subtitle: 'Chuyển patient sang giai đoạn giãn cách 2 tuần/lần.',
                    onTap: () => Navigator.pop(context, 'set-tapering-stage:MONTHLY'),
                  ),
                  _DemoActionTile(
                    icon: Icons.event_repeat_outlined,
                    title: 'Tapering 3-4 tuần/lần',
                    subtitle: 'Chuyển patient sang giai đoạn giãn cách 3-4 tuần/lần.',
                    onTap: () => Navigator.pop(context, 'set-tapering-stage:QUARTERLY'),
                  ),
                  _DemoActionTile(
                    icon: Icons.school_outlined,
                    title: 'Đánh dấu tốt nghiệp',
                    subtitle: 'Chuyển patient sang maintenance / booster mode.',
                    onTap: () => Navigator.pop(context, 'mark-graduated'),
                  ),
                  _DemoActionTile(
                    icon: Icons.today_outlined,
                    title: 'Tạo Booster 3 tháng',
                    subtitle: 'Tạo lịch booster demo gần nhất cho patient.',
                    onTap: () => Navigator.pop(context, 'trigger-booster:BOOSTER_3M'),
                  ),
                  _DemoActionTile(
                    icon: Icons.date_range_outlined,
                    title: 'Tạo Booster 6 tháng',
                    subtitle: 'Tạo lịch booster 6 tháng để demo hậu điều trị.',
                    onTap: () => Navigator.pop(context, 'trigger-booster:BOOSTER_6M'),
                  ),
                  _DemoActionTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Tạo Booster 12 tháng',
                    subtitle: 'Tạo lịch booster 12 tháng để demo duy trì dài hạn.',
                    onTap: () => Navigator.pop(context, 'trigger-booster:BOOSTER_12M'),
                  ),
                  _DemoActionTile(
                    icon: Icons.lock_open,
                    title: 'Mở khóa LSAS',
                    subtitle: 'Bệnh nhân vào app làm lại LSAS/re-rating ngay.',
                    onTap: () => Navigator.pop(context, 'unlock-lsas'),
                  ),
                  _DemoActionTile(
                    icon: Icons.assignment_turned_in,
                    title: 'Tạo bài thực hành hôm nay',
                    subtitle: 'Tạo bài hệ thống cho Fear Ladder nếu chưa có.',
                    onTap: () => Navigator.pop(context, 'run-daily-roadmap'),
                  ),
                  _DemoActionTile(
                    icon: Icons.warning_amber,
                    title: 'Bật cảnh báo risk cao',
                    subtitle: 'Set risk=80 và bật red flag để demo Safety Overlay.',
                    onTap: () => Navigator.pop(context, 'set-risk'),
                  ),
                  _DemoActionTile(
                    icon: Icons.health_and_safety,
                    title: 'Tắt cảnh báo risk',
                    subtitle: 'Đưa risk/red flag về trạng thái an toàn.',
                    onTap: () => Navigator.pop(context, 'clear-risk'),
                  ),
                  _DemoActionTile(
                    icon: Icons.restart_alt,
                    title: 'Reset tốt nghiệp',
                    subtitle: 'Đưa bệnh nhân về luồng đang điều trị.',
                    onTap: () => Navigator.pop(context, 'reset-graduation'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );

    if (action == null || action.isEmpty) return;
    if (action.contains(':')) {
      final pieces = action.split(':');
      final baseAction = pieces.first;
      final value = pieces.sublist(1).join(':');
      final query = switch (baseAction) {
        'set-lsas-band' => {'band': value},
        'set-program-week' => {'programWeek': value},
        'set-fear-ladder-mastery' => {'masteredCount': value},
        'seed-daily-checkin' => {'mode': value},
        'set-tapering-stage' => {'stage': value},
        'trigger-booster' => {'purpose': value},
        _ => <String, String>{},
      };
      await _runDemoAction(item, baseAction, query: query);
      return;
    }
    if (action == 'set-risk') {
      await _runDemoAction(item, action, query: {'score': '80', 'redFlag': 'true'});
      return;
    }
    await _runDemoAction(item, action);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Quản lý hồ sơ bệnh nhân', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Dữ liệu lấy từ backend (/api/admin/patients).', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            Row(
              children: [
                FilterChip(
                  label: const Text('Red Flag only'),
                  selected: _redFlagOnly,
                  onSelected: _loading
                      ? null
                      : (v) async {
                          setState(() => _redFlagOnly = v);
                          await _load(pageIndex: 1);
                        },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Triage Queue'),
                  selected: _triageOnly,
                  onSelected: _loading
                      ? null
                      : (v) async {
                          setState(() => _triageOnly = v);
                          await _load(pageIndex: 1);
                        },
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm theo nickname / email / chuyên gia...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onChanged: (v) => _query = v,
          onSubmitted: (v) => _load(pageIndex: 1, keyword: v),
        ),
        const SizedBox(height: 12),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? const Center(child: Text('Không có dữ liệu.'))
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final it = _items[i];
                              final risk = it.currentRiskScore ?? 0;
                              final red = it.redFlagActive == true;
                              return Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            it.nickname?.isNotEmpty == true ? it.nickname! : (it.email ?? it.patientId),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${it.realFullName ?? 'Chưa có tên thật'} • ${it.phoneNumber ?? 'Chưa có SĐT'}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Chuyên gia: ${it.therapistName ?? 'Chưa gán'}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'LSAS: ${it.currentLsasScore ?? 0} • Tapering: ${it.taperingStage ?? 'NONE'} • Ẩn danh: ${it.anonymousModeEnabled ? 'Đang bật' : 'Đang tắt'}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Risk: $risk • Red flag: $red • Tốt nghiệp: ${it.graduatedAt != null ? 'Đã bật' : 'Chưa'}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          if (it.triageRequired) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Triage: ${it.triageStatus ?? 'PENDING'} • Priority: ${it.triagePriority ?? risk}',
                                              style: const TextStyle(color: AppColors.alert, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                          if ((it.emergencyContactPhone ?? '').isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Liên hệ khẩn cấp: ${it.emergencyContactPhone}',
                                              style: const TextStyle(color: Colors.black54),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      children: [
                                        Switch(
                                          value: it.active ?? true,
                                          onChanged: _loading ? null : (v) => _toggleActive(it, v),
                                          activeColor: AppColors.success,
                                        ),
                                        const Text('Active'),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                      onPressed: _loading ? null : () => _assignTherapist(it),
                                      child: const Text('Gán BS', style: TextStyle(color: Colors.white)),
                                    ),
                                    if (it.triageRequired) ...[
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: _loading ? null : () => _runTriageAction(it, 'claim'),
                                        child: const Text('Nhận xử lý'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: _loading ? null : () => _runTriageAction(it, 'mark-called'),
                                        child: const Text('Đã gọi'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: _loading ? null : () => _runTriageAction(it, 'close'),
                                        child: const Text('Đóng triage'),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: _loading ? null : () => _showDemoControls(it),
                                      icon: const Icon(Icons.tune, size: 18),
                                      label: const Text('Demo'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              PaginationBar(
                pageIndex: _pageIndex,
                totalPages: _totalPages,
                totalElements: _totalElements,
                pageSize: _pageSize,
                onPageChanged: (page) => _load(pageIndex: page),
                onPageSizeChanged: (size) => _load(pageIndex: 1, pageSize: size),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoSectionLabel extends StatelessWidget {
  const _DemoSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DemoActionTile extends StatelessWidget {
  const _DemoActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

