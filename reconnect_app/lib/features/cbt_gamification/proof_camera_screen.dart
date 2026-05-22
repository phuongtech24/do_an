import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class ProofCameraScreen extends StatefulWidget {
  const ProofCameraScreen({super.key});

  @override
  State<ProofCameraScreen> createState() => _ProofCameraScreenState();
}

class _ProofCameraScreenState extends State<ProofCameraScreen> {
  bool _isScanning = false;

  void _scanImage() {
    setState(() => _isScanning = true);
    
    // Simulate AI Vision API Call
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _isScanning = false);
      
      // Navigate to Reward Screen on success
      context.push('/roadmap/reward');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark for camera feel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Chụp minh chứng', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Fake Camera Preview Area
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.grey, size: 64),
                    SizedBox(height: 16),
                    Text('Hướng camera vào đối tượng\nđể chụp hình', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          
          // AI Scan Overlay
          if (_isScanning)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: AppColors.secondary),
                    SizedBox(height: 24),
                    Text(
                      'AI Vision đang phân tích ảnh...',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vui lòng đợi giây lát',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hệ thống yêu cầu chụp ảnh trực tiếp. Chức năng tải ảnh từ thư viện đã bị khóa.')),
                  );
                },
                icon: const Icon(Icons.photo_library, color: Colors.grey, size: 32), // Blocked gallery
              ),
              GestureDetector(
                onTap: _isScanning ? null : _scanImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
