import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'tutor_dashboard.dart';

class TutorShell extends StatelessWidget {
  const TutorShell({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: const TutorDashboard(),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF140D2B),
        border: Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 1)),
      ),
      child: NavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.yellow),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.yellow),
            label: 'Insights',
          ),
        ],
        onDestinationSelected: (i) {
          if (i == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('More tutor analytics can be added here.')),
            );
          }
        },
      ),
    ),
  );
}
