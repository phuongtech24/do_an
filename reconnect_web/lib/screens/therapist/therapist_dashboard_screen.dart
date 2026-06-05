import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/therapist/data/models/therapist_patient_list_item.dart';
import '../../features/therapist/data/repositories/therapist_patient_repository.dart';
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
  List<TherapistPatientListItem> _patients = [];
  int _redFlagCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      if (token == null || token.isEmpty) {
        throw Exception('Chưa đăng nhập');
      }
      final list = await _repo.listPatients(token: token, redFlagOnly: _redFlagOnly);
      final red = await _repo.listPatients(token: token, redFlagOnly: true);
      setState(() {
        _patients = list;
        _redFlagCount = red.length;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Therapist Workspace'),
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
                style: const TextStyle(
                  color: AppColors.alert,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TherapistProfileScreen()));
            },
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.16),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
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
            _buildSidebarItem(
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
            _buildSidebarItem(
              icon: Icons.calendar_month_outlined,
              label: 'Lịch hẹn',
              subtitle: 'Phiên CBT và lịch upcoming',
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_circle_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_redFlagCount red flag cần theo dõi',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
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
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildMetricCard(
              title: _redFlagOnly ? 'Danh sách ưu tiên' : 'Bệnh nhân đang phụ trách',
              value: '${_patients.length}',
              subtitle: _redFlagOnly ? 'Đang lọc nhóm red flag' : 'Tổng hồ sơ đang hiển thị',
              icon: Icons.groups_2_outlined,
              tint: AppColors.primary,
            ),
            _buildMetricCard(
              title: 'Red flag đang mở',
              value: '$_redFlagCount',
              subtitle: 'Cần kiểm tra trước buổi hẹn',
              icon: Icons.flag_outlined,
              tint: AppColors.alert,
            ),
            _buildMetricCard(
              title: 'Chế độ xem',
              value: _redFlagOnly ? 'Ưu tiên' : 'Toàn bộ',
              subtitle: 'Có thể đổi nhanh từ nút trên cùng',
              icon: Icons.tune_outlined,
              tint: AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _redFlagOnly ? 'Bệnh nhân cần ưu tiên ngay' : 'Danh sách bệnh nhân',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mỗi thẻ hiển thị mức rủi ro, LSAS và goal chính để bạn vào hồ sơ nhanh hơn.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _loadPatients,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tải lại'),
            ),
          ],
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error, style: const TextStyle(color: AppColors.alert)))
                    : _patients.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có bệnh nhân phù hợp với bộ lọc hiện tại.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            ),
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
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color tint,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tint.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, TherapistPatientListItem patient) {
    final isWarning = patient.isRedFlagActive || patient.currentRiskScore >= 70;
    final accent = isWarning ? AppColors.alert : AppColors.primary;

    return InkWell(
      onTap: () {
        final map = <String, dynamic>{
          'name': patient.nickname.isEmpty ? patient.patientId : patient.nickname,
          'id': patient.patientId,
          'isAnonymous': true,
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
        };
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: map)),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFCFEFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isWarning ? AppColors.alert.withOpacity(0.32) : AppColors.primary.withOpacity(0.08),
            width: isWarning ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.patientId,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isWarning ? AppColors.alert.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isWarning ? 'Cảnh báo' : 'Ổn định',
                    style: TextStyle(
                      color: isWarning ? AppColors.alert : AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoBadge('LSAS hiện tại', '${patient.currentLsasScore}', accent),
                _buildInfoBadge('LSAS baseline', '${patient.baselineLsasScore}', AppColors.secondary),
                _buildInfoBadge('Risk', '${patient.currentRiskScore}', isWarning ? AppColors.alert : AppColors.secondary),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              patient.primaryGoal?.isNotEmpty == true ? patient.primaryGoal! : 'Chưa có goal chính',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                const Text(
                  'Hồ sơ ẩn danh',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final map = <String, dynamic>{
                      'name': patient.nickname.isEmpty ? patient.patientId : patient.nickname,
                      'id': patient.patientId,
                      'isAnonymous': true,
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
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: map)),
                    );
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

  Widget _buildInfoBadge(String label, String value, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: tint,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
