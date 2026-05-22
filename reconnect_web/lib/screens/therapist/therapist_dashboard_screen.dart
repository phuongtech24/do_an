import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../features/therapist/data/models/therapist_patient_list_item.dart';
import '../../features/therapist/data/repositories/therapist_patient_repository.dart';
import 'patient_detail_screen.dart';
import 'therapist_appointments_screen.dart';
import 'therapist_profile_screen.dart';

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  int _selectedIndex = 0; // 0 = Bệnh nhân, 1 = Lịch hẹn

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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
                _redFlagOnly = true;
              });
              _loadPatients();
            },
          ),
          if (_redFlagCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.alert,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$_redFlagCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TherapistProfileScreen()));
            },
            borderRadius: BorderRadius.circular(20),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('A', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Menu
          Container(
            width: 250,
            color: Colors.white,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_alt, color: AppColors.primary),
                  title: const Text('Bệnh nhân của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: _selectedIndex == 0 ? AppColors.primary.withValues(alpha: 0.1) : null,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                      _redFlagOnly = false;
                    });
                    _loadPatients();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                  title: const Text('Lịch hẹn (Appointments)', style: TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: _selectedIndex == 1 ? AppColors.primary.withValues(alpha: 0.1) : null,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          // Vertical Divider
          Container(width: 1, color: Colors.grey[200]),
          
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: _selectedIndex == 0 ? _buildPatientsView() : const TherapistAppointmentsScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _redFlagOnly ? 'Emergency Alert — Red Flag' : 'Bệnh nhân đang phụ trách',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(child: Text(_error, style: const TextStyle(color: AppColors.alert)))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return _buildPatientCard(context, patient);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(String time, String name, bool isAnonymous) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(
          isAnonymous ? Icons.masks_rounded : Icons.person,
          color: AppColors.secondary,
        ),
        title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(name),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, TherapistPatientListItem patient) {
    final bool isWarning = patient.isRedFlagActive || patient.currentRiskScore >= 70;
    
    return InkWell(
      onTap: () {
        final map = <String, dynamic>{
          'name': patient.nickname.isEmpty ? patient.patientId : patient.nickname,
          'id': patient.patientId,
          'isAnonymous': true,
          'status': isWarning ? 'Cảnh báo' : 'Ổn định',
          'phq9Baseline': 0,
          'phq9Current': 0,
          'moodHistory': [50, 50, 50, 50, 50, 50, 50],
          'hasRedFlag': patient.isRedFlagActive,
          'avatar': Icons.person,
          'color': isWarning ? Colors.red : Colors.blue,
          'riskScore': patient.currentRiskScore,
        };
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: map)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWarning ? AppColors.alert : Colors.grey[200]!,
            width: isWarning ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: (isWarning ? Colors.red : Colors.blue).withValues(alpha: 0.2),
                  child: Icon(Icons.person, color: isWarning ? Colors.red : Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.nickname.isEmpty ? patient.patientId : patient.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        patient.patientId,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Tooltip(
                  message: 'Bệnh nhân ẩn danh',
                  child: Icon(Icons.shield, color: AppColors.success, size: 16),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risk: ${patient.currentRiskScore}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWarning ? AppColors.alert : AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWarning ? AppColors.alert.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isWarning ? 'Cảnh báo' : 'Ổn định',
                    style: TextStyle(
                      color: isWarning ? AppColors.alert : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (patient.isRedFlagActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.flag, color: AppColors.alert, size: 14),
                  const SizedBox(width: 4),
                  const Text('AI Cảnh báo Rủi ro Cao', style: TextStyle(color: AppColors.alert, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSparkline(List<int> history) {
    // Simple mock sparkline using a row of bars or a tiny chart
    return Row(
      children: history.map((val) {
        return Container(
          margin: const EdgeInsets.only(right: 2),
          width: 3,
          height: val / 5, // Scaling for display
          decoration: BoxDecoration(
            color: val < 40 ? Colors.red : (val < 60 ? Colors.orange : Colors.green),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }).toList(),
    );
  }
}
