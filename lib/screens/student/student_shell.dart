import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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
    bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Explore'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'My learning'),
    ]),
  );
}
