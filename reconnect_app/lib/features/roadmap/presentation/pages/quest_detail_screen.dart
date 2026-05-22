import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/roadmap_provider.dart';
import '../../data/models/verify_quest_proof_result.dart';

class QuestDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String category;
  final Color categoryColor;
  final IconData icon;

  const QuestDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.icon,
  });

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _isSubmitting = false;
  double _masteryValue = 5.0;
  double _pleasureValue = 5.0;
  bool _isVerifyingProof = false;
  File? _proofImageFile;
  VerifyQuestProofResult? _proofResult;
  String? _proofImageUrl;

  bool get _requiresPhotoProof => widget.category == 'Hành vi' || widget.category == 'Xã hội';

  Future<void> _captureAndVerifyProof() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final roadmapProvider = Provider.of<RoadmapProvider>(context, listen: false);

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập trước khi nộp minh chứng.')),
      );
      return;
    }

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1280,
      maxHeight: 1280,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xfile == null) return;

    final file = File(xfile.path);

    setState(() {
      _isVerifyingProof = true;
      _proofImageFile = file;
      _proofResult = null;
      _proofImageUrl = null;
    });

    final result = await roadmapProvider.verifyQuestProof(
      patientId,
      widget.id,
      imageFile: file,
      token: token,
    );

    if (!mounted) return;

    setState(() {
      _isVerifyingProof = false;
      _proofResult = result;
      _proofImageUrl = result?.accepted == true ? result?.proofImageUrl : null;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${roadmapProvider.errorMessage}')),
      );
      return;
    }

    if (result.accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minh chứng hợp lệ (score: ${result.score ?? '-'}).')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.reason ?? 'Minh chứng chưa phù hợp, vui lòng chụp lại.')),
      );
    }
  }

  void _submitQuest() async {
    setState(() {
      _isSubmitting = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final roadmapProvider = Provider.of<RoadmapProvider>(context, listen: false);

    if (_requiresPhotoProof && (_proofImageUrl == null || _proofImageUrl!.isEmpty)) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chụp và xác minh ảnh minh chứng trước khi hoàn thành nhiệm vụ.')),
      );
      return;
    }

    final ok = await roadmapProvider.completeQuest(
      patientId,
      widget.id,
      masteryScore: _masteryValue.toInt(),
      pleasureScore: _pleasureValue.toInt(),
      proofImageUrl: _proofImageUrl,
      token: token,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${roadmapProvider.errorMessage}')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Tuyệt vời!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hệ thống đã ghi nhận nhiệm vụ của bạn. Đã hoàn thành nhiệm vụ!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.categoryColor,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('Nhận thưởng & Trở về', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực hiện Nhiệm vụ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.categoryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: widget.categoryColor.withOpacity(0.2),
                    child: Icon(widget.icon, size: 32, color: widget.categoryColor),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(widget.category, style: TextStyle(color: widget.categoryColor, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: widget.categoryColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Submission Area
            const Text(
              'Nộp minh chứng (FR4.3)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (widget.category == 'Hành vi' || widget.category == 'Xã hội') ...[
              // Camera Placeholder cho Hành vi / Xã hội
              GestureDetector(
                onTap: _isVerifyingProof ? null : _captureAndVerifyProof,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isVerifyingProof)
                        const CircularProgressIndicator()
                      else
                        Icon(
                          _proofResult?.accepted == true ? Icons.check_circle : Icons.add_a_photo_outlined,
                          size: 40,
                          color: _proofResult?.accepted == true ? Colors.green : Colors.grey[400],
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _proofResult == null
                            ? 'Bấm để chụp ảnh minh chứng'
                            : (_proofResult!.accepted
                                ? 'Minh chứng hợp lệ (score: ${_proofResult!.score ?? '-'})'
                                : 'Chưa phù hợp: ${_proofResult!.reason ?? 'Vui lòng chụp lại'}'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                            ),
            ] else ...[
              // Text Placeholder cho Nhận thức / Cảm xúc
              TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú hoặc suy nghĩ của bạn vào đây để AI phân tích...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Tự đánh giá kết quả (Kích hoạt hành vi)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),
            
            // Mastery Slider
            Row(
              children: [
                const Icon(Icons.workspace_premium_outlined, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Mức độ Thành tựu (Mastery)', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_masteryValue.toInt()}/10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
              ],
            ),
            const Text('Bạn thấy mình hoàn thành tốt công việc này đến mức nào?', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Slider(
              value: _masteryValue,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: Colors.orange,
              onChanged: (v) => setState(() => _masteryValue = v),
            ),
            
            const SizedBox(height: 16),
            
            // Pleasure Slider
            Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.pink),
                const SizedBox(width: 8),
                const Text('Mức độ Niềm vui (Pleasure)', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_pleasureValue.toInt()}/10', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pink)),
              ],
            ),
            const Text('Công việc này mang lại cho bạn bao nhiêu sự tích cực?', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Slider(
              value: _pleasureValue,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: Colors.pink,
              onChanged: (v) => setState(() => _pleasureValue = v),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.categoryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isSubmitting ? null : _submitQuest,
            child: _isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Xác nhận hoàn thành nhiệm vụ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
