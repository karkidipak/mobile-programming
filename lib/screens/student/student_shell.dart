import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'student_home.dart';
import '../shared/my_learning_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int index = 0;
  final pages = const [StudentHome(), MyLearningScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: pages[index],
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF140D2B),
        border: Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 1)),
      ),
      child: NavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded, color: AppTheme.yellow),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.yellow),
            label: 'My learning',
          ),
        ],
      ),
    ),
  );
}
