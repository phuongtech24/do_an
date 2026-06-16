import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/therapist/data/models/therapist_patient_list_item.dart';
import '../../features/therapist/data/repositories/therapist_patient_repository.dart';
import '../../shared/widgets/pagination_bar.dart';
import '../../theme/app_colors.dart';
import 'patient_detail_screen.dart';
import 'therapist_appointments_screen.dart';
import 'therapist_profile_screen.dart';

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  int _selectedIndex = 0;
  final TherapistPatientRepository _repo = TherapistPatientRepository();
  bool _redFlagOnly = false;
  bool _loading = true;
  String _error = '';
  String _query = '';
  List<TherapistPatientListItem> _patients = [];
  int _redFlagCount = 0;
  int _pageIndex = 1;
  int _pageSize = 9;
  int _totalPages = 0;
  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients({int? pageIndex, int? pageSize, String? keyword}) async {
    setState(() {
      _loading = true;
      _error = '';
      if (pageIndex != null) _pageIndex = pageIndex;
      if (pageSize != null) _pageSize = pageSize;
      if (keyword != null) _query = keyword;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Chưa đăng nhập');
      }
      final page = await _repo.listPatientsPaged(
        token: token,
        redFlagOnly: _redFlagOnly,
        keyword: _query,
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      final red = await _repo.listPatients(token: token, redFlagOnly: true);
      setState(() {
        _patients = page.content;
        _redFlagCount = red.length;
        _totalPages = page.totalPages;
        _totalElements = page.totalElements;
        _pageIndex = page.pageIndex;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Không gian chuyên gia'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
                _redFlagOnly = true;
              });
              _loadPatients();
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Ưu tiên red flag'),
          ),
          if (_redFlagCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.alert.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$_redFlagCount cảnh báo',
                style: const TextStyle(color: AppColors.alert, fontWeight: FontWeight.w800),
              ),
            ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TherapistProfileScreen())),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                backgroundColor: Color(0xFFE8F7F5),
                child: Text('A', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _selectedIndex == 0 ? _buildPatientsView() : const TherapistAppointmentsScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E7A73), Color(0xFF159489)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.health_and_safety_outlined, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bảng điều phối chuyên gia',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Theo dõi bệnh nhân, red flag và lịch hẹn trong cùng một không gian làm việc.',
              style: TextStyle(color: Colors.white70, height: 1.45),
            ),
            const SizedBox(height: 24),
            _sidebarItem(
              icon: Icons.people_alt_outlined,
              label: 'Bệnh nhân của tôi',
              subtitle: 'Danh sách đang phụ trách',
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  _redFlagOnly = false;
                });
                _loadPatients();
              },
            ),
            const SizedBox(height: 12),
            _sidebarItem(
              icon: Icons.calendar_month_outlined,
              label: 'Lịch hẹn',
              subtitle: 'Phiên CBT và lịch sắp tới',
              selected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? Colors.white.withOpacity(0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(selected ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _redFlagOnly ? 'Bệnh nhân cần ưu tiên ngay' : 'Danh sách bệnh nhân',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Mỗi thẻ hiển thị mức rủi ro, LSAS và goal chính để bạn vào hồ sơ nhanh hơn.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm theo nickname / tên thật / mục tiêu...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onChanged: (v) => _query = v,
          onSubmitted: (v) => _loadPatients(pageIndex: 1, keyword: v),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                          ? Center(child: Text(_error, style: const TextStyle(color: AppColors.alert)))
                          : _patients.isEmpty
                              ? const Center(
                                  child: Text('Chưa có bệnh nhân phù hợp với bộ lọc hiện tại.', style: TextStyle(color: AppColors.textSecondary)),
                                )
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                    childAspectRatio: 1.22,
                                  ),
                                  itemCount: _patients.length,
                                  itemBuilder: (context, index) => _buildPatientCard(context, _patients[index]),
                                ),
                ),
                PaginationBar(
                  pageIndex: _pageIndex,
                  totalPages: _totalPages,
                  totalElements: _totalElements,
                  pageSize: _pageSize,
                  onPageChanged: (page) => _loadPatients(pageIndex: page),
                  onPageSizeChanged: (size) => _loadPatients(pageIndex: 1, pageSize: size),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context, TherapistPatientListItem patient) {
    final isWarning = patient.isRedFlagActive || patient.currentRiskScore >= 70;
    final accent = isWarning ? AppColors.alert : AppColors.primary;
    final map = <String, dynamic>{
      'name': patient.nickname.isEmpty ? patient.patientId : patient.nickname,
      'id': patient.patientId,
      'isAnonymous': patient.anonymousModeEnabled,
      'status': isWarning ? 'Cảnh báo' : 'Ổn định',
      'lsasBaseline': patient.baselineLsasScore,
      'lsasCurrent': patient.currentLsasScore,
      'moodHistory': [50, 50, 50, 50, 50, 50, 50],
      'hasRedFlag': patient.isRedFlagActive,
      'avatar': Icons.person,
      'color': isWarning ? Colors.red : Colors.blue,
      'riskScore': patient.currentRiskScore,
      'primaryGoal': patient.primaryGoal,
      'therapistName': patient.therapistName,
      'programWeek': patient.programWeek,
      'programPhaseLabel': patient.programPhaseLabel,
      'upcomingAppointmentAt': patient.upcomingAppointmentAt,
      'latestThoughtRecordAt': patient.latestThoughtRecordAt,
      'latestCheckinAt': patient.latestCheckinAt,
      'stalledProgress': patient.stalledProgress,
      'realFullName': patient.realFullName,
      'phoneNumber': patient.phoneNumber,
      'emergencyContactPhone': patient.emergencyContactPhone,
      'dateOfBirth': patient.dateOfBirth,
      'gender': patient.gender,
      'educationLevel': patient.educationLevel,
      'occupation': patient.occupation,
      'relationshipStatus': patient.relationshipStatus,
      'medicalHistory': patient.medicalHistory,
    };

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: map)));
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isWarning ? AppColors.alert.withOpacity(0.32) : AppColors.primary.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: accent.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accent.withOpacity(0.12),
                  child: Icon(Icons.person_outline, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.nickname.isEmpty ? patient.patientId : patient.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(patient.patientId, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _infoBadge('LSAS hiện tại', '${patient.currentLsasScore}', accent),
                _infoBadge('LSAS baseline', '${patient.baselineLsasScore}', AppColors.secondary),
                _infoBadge('Mức rủi ro', '${patient.currentRiskScore}', isWarning ? AppColors.alert : AppColors.secondary),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              patient.primaryGoal?.isNotEmpty == true ? patient.primaryGoal! : 'Chưa có mục tiêu chính',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, height: 1.4),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                const Text('Hồ sơ ẩn danh', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: map)));
                  },
                  child: const Text('Xem chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String label, String value, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
            TextSpan(text: value, style: TextStyle(color: tint, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
