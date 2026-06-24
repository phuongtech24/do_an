import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/therapist/data/models/therapist_patient_list_item.dart';
import '../../features/therapist/data/repositories/therapist_credential_repository.dart';
import '../../features/therapist/data/repositories/therapist_patient_repository.dart';
import '../../theme/app_colors.dart';
import 'patient_detail_screen.dart';
import 'therapist_appointments_screen.dart';
import 'therapist_credentials_upload_screen.dart';
import 'therapist_profile_screen.dart';

class MainTherapistScreen extends StatefulWidget {
  const MainTherapistScreen({super.key});

  @override
  State<MainTherapistScreen> createState() => _MainTherapistScreenState();
}

class _MainTherapistScreenState extends State<MainTherapistScreen> {
  int _selectedIndex = 0;
  final TherapistCredentialRepository _credentialRepo = TherapistCredentialRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guard());
  }

  Future<void> _guard() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    try {
      final status = await _credentialRepo.myStatus(token: token);
      if (!mounted) return;
      if (status.approvalStatus != 'ACTIVE') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TherapistCredentialsUploadScreen()),
        );
      }
    } catch (_) {
      // Demo mode: kh?ng ch?n m?n ch?nh n?u API status t?m l?i.
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Icon(Icons.spa, size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Hi, ${email ?? 'Chuyên gia'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 48),
                _SidebarItem(
                  icon: Icons.psychology,
                  label: 'Bảng điều trị',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _SidebarItem(
                  icon: Icons.calendar_month,
                  label: 'Lịch hẹn & Tham vấn',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _SidebarItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Hồ sơ chuyên gia',
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.grey),
                  title: const Text('Đăng xuất'),
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 0
                ? const Padding(padding: EdgeInsets.all(40), child: PatientDashboard())
                : _selectedIndex == 1
                    ? const Padding(padding: EdgeInsets.all(40), child: TherapistAppointmentsScreen())
                    : const TherapistProfileScreen(),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      iconColor: selected ? AppColors.primary : AppColors.textSecondary,
      textColor: selected ? AppColors.primary : AppColors.textPrimary,
      onTap: onTap,
    );
  }
}

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final TherapistPatientRepository _repo = TherapistPatientRepository();
  bool _loading = true;
  bool _redFlagOnly = false;
  String _error = '';
  List<TherapistPatientListItem> _patients = [];
  int _redFlagCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatients());
  }

  Future<void> _loadPatients() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Chưa đăng nhập hoặc token không hợp lệ.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final patients = await _repo.listPatients(token: token, redFlagOnly: _redFlagOnly);
      final redFlags = await _repo.listPatients(token: token, redFlagOnly: true);
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _redFlagCount = redFlags.length;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Danh sách bệnh nhân',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _redFlagOnly = !_redFlagOnly);
                _loadPatients();
              },
              icon: Icon(_redFlagOnly ? Icons.flag : Icons.flag_outlined),
              label: Text(_redFlagOnly ? 'Đang lọc Red Flag ($_redFlagCount)' : 'Red Flag ($_redFlagCount)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _redFlagOnly ? AppColors.alert : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Tải lại',
              onPressed: _loadPatients,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Theo dõi bệnh nhân được Admin gán, ưu tiên ca Red Flag và tiến độ can thiệp CBT.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: _buildPatientList(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientList(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(color: AppColors.alert)));
    }
    if (_patients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _redFlagOnly
                ? 'Không có bệnh nhân Red Flag trong danh sách phụ trách.'
                : 'Chưa có bệnh nhân nào được Admin gán cho tài khoản chuyên gia này.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _patients.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final patient = _patients[index];
        final isRedAlert = patient.isRedFlagActive || patient.currentRiskScore >= 70;
        final displayName = patient.nickname.isEmpty ? 'Bệnh nhân ${patient.patientId.substring(0, 8)}' : patient.nickname;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          leading: CircleAvatar(
            backgroundColor: isRedAlert ? AppColors.alert.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
            child: Text(
              displayName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isRedAlert ? AppColors.alert : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusBadge(
                  label: isRedAlert ? 'RED FLAG' : 'ĐANG THEO DÕI',
                  color: isRedAlert ? AppColors.alert : AppColors.success,
                ),
                Text(
                  'Risk Index: ${patient.currentRiskScore}/100',
                  style: TextStyle(
                    color: isRedAlert ? AppColors.alert : AppColors.textSecondary,
                    fontWeight: isRedAlert ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (patient.isRedFlagActive)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.alert, size: 16),
                      SizedBox(width: 4),
                      Text('Cần ưu tiên can thiệp', style: TextStyle(color: AppColors.alert)),
                    ],
                  ),
              ],
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailScreen(
                    patient: {
                      'id': patient.patientId,
                      'name': displayName,
                      'status': isRedAlert ? 'Cảnh báo' : 'Ổn định',
                      'isAnonymous': patient.anonymousModeEnabled,
                      'color': isRedAlert ? AppColors.alert : AppColors.primary,
                      'avatar': Icons.person,
                      'hasRedFlag': patient.isRedFlagActive,
                      'riskScore': patient.currentRiskScore,
                      'moodHistory': const [50, 50, 50, 50, 50, 50, 50],
                      'realFullName': patient.realFullName,
                      'phoneNumber': patient.phoneNumber,
                      'emergencyContactPhone': patient.emergencyContactPhone,
                      'dateOfBirth': patient.dateOfBirth,
                      'gender': patient.gender,
                      'educationLevel': patient.educationLevel,
                      'occupation': patient.occupation,
                      'relationshipStatus': patient.relationshipStatus,
                      'medicalHistory': patient.medicalHistory,
                    },
                  ),
                ),
              ).then((_) => _loadPatients());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isRedAlert ? AppColors.alert : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xem chi tiết & can thiệp'),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
