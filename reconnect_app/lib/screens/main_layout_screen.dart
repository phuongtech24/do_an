import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/ai_journal/ai_chat_screen.dart';
import '../features/cbt_gamification/roadmap_screen.dart';
import '../features/telehealth/booking_calendar_screen.dart';
import '../features/settings/profile_settings_screen.dart';
import '../features/ai_journal/sentiment_chart_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final Widget child;

  const MainLayoutScreen({super.key, required this.child});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/chat')) {
      return 0;
    }
    if (location.startsWith('/roadmap')) {
      return 1;
    }
    if (location.startsWith('/telehealth')) {
      return 2;
    }
    if (location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/chat');
        break;
      case 1:
        context.go('/roadmap');
        break;
      case 2:
        context.go('/telehealth');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Nhật ký AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Lộ trình CBT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bác sĩ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
      floatingActionButton: selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // Điều hướng nhanh đến thống kê bằng GoRouter (push)
          context.push('/chat/chart');
        },
        backgroundColor: Colors.teal,
        mini: true,
        child: const Icon(Icons.bar_chart, color: Colors.white),
      ) : null,
    );
  }
}
