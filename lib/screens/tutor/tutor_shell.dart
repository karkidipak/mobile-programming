import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'tutor_dashboard.dart';

class TutorShell extends StatelessWidget {
  const TutorShell({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: const TutorDashboard(),
    bottomNavigationBar: NavigationBar(selectedIndex: 0, destinations: const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Insights'),
    ], onDestinationSelected: (i) { if (i == 1) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('More tutor analytics can be added here.'))); }),
  );
}
