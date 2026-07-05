import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

import '../../network/api_service.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  late Future<List<Map<String, dynamic>>> _roadmapFuture;

  @override
  void initState() {
    super.initState();
    // Use a dummy UUID since Auth is not fully wired up yet
    _roadmapFuture = ApiService.getPatientRoadmap('123e4567-e89b-12d3-a456-426614174000');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hành Trình Chữa Lành'),
        actions: [
          Row(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              SizedBox(width: 4),
              Text('12', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 16),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _roadmapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: \${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có trạm nhiệm vụ nào.'));
          }

          final nodes = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chặng 1: Bước Nhỏ Đầu Tiên', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Hoàn thành từng thử thách nhỏ mỗi ngày để rèn luyện thói quen tích cực.', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final node = nodes[index];
                    final isDone = node['status'] == 'DONE';
                    final isActive = node['status'] == 'ACTIVE';
                    final isLocked = node['status'] == 'LOCKED';
                    final isSideQuest = node['isSideQuest'] == true;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Node Icon & Line connecting
                          Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDone ? AppColors.success : (isActive ? (isSideQuest ? Colors.deepPurple : AppColors.secondary) : Colors.grey.shade300),
                                  shape: BoxShape.circle,
                                  border: isActive ? Border.all(color: isSideQuest ? Colors.purple : AppColors.primary, width: 3) : null,
                                ),
                                child: Icon(
                                  isDone ? Icons.check : (isLocked ? Icons.lock : (isSideQuest ? Icons.favorite : Icons.star)),
                                  color: isLocked ? Colors.grey.shade500 : Colors.white,
                                  size: 20,
                                ),
                              ),
                              if (index < nodes.length - 1)
                                Container(
                                  width: 4,
                                  height: 60,
                                  color: isDone ? AppColors.success : Colors.grey.shade300,
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          
                          // Node Content Card
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isActive) {
                                  context.push('/roadmap/camera');
                                } else if (isLocked) {
                                  if (node['timeLock'] != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bạn đã làm rất tốt hôm nay. Trạm tiếp theo sẽ mở khóa vào 06:00 sáng mai!'),
                                        backgroundColor: Colors.blueGrey,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Vui lòng hoàn thành trạm trước đó để mở khóa!')),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isLocked ? Colors.grey.shade100 : (isSideQuest ? Colors.purple.shade50 : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isLocked ? [] : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                  border: isSideQuest 
                                    ? Border.all(color: Colors.deepPurpleAccent, width: 2) 
                                    : (isActive ? Border.all(color: AppColors.secondary, width: 2) : Border.all(color: Colors.transparent)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isSideQuest ? 'Nhiệm vụ phụ' : 'Trạm ${node['order']}',
                                          style: TextStyle(
                                            color: isLocked ? Colors.grey : (isSideQuest ? Colors.deepPurple : AppColors.primary),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isSideQuest)
                                          const Icon(Icons.medical_services, size: 16, color: Colors.deepPurple)
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      node['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isLocked ? Colors.grey : AppColors.textPrimary,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (node['timeLock'] != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            node['timeLock'],
                                            style: const TextStyle(color: Colors.orange, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: nodes.length,
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
