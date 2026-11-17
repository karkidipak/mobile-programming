import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../../models/course.dart';
import 'course_detail_screen.dart';
import 'certificate_screen.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});
  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  Future<List<Course>> load() async {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    final rows = await Supabase.instance.client.from('enrollments').select('courses(*)').eq('student_id', uid);
    return rows.map((r) => Course.fromMap(Map<String,dynamic>.from(r['courses']))).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      title: const Text('My learning', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
      backgroundColor: AppTheme.background,
    ),
    body: FutureBuilder<List<Course>>(
      future: load(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.yellow));
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
                  child: const Icon(Icons.menu_book_rounded, size: 48, color: AppTheme.purpleLight),
                ),
                const SizedBox(height: 16),
                const Text('No courses enrolled yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 6),
                const Text('Explore popular courses to start learning!', style: TextStyle(color: AppTheme.muted)),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: snap.data!.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.play_lesson_rounded, color: AppTheme.yellow),
                ),
                title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(c.category.toUpperCase(), style: const TextStyle(color: AppTheme.purpleLight, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))),
                trailing: IconButton(
                  tooltip: 'View certificate',
                  icon: const Icon(Icons.workspace_premium_rounded, color: AppTheme.yellow, size: 28),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(course: c))),
                ),
              ),
            ),
          )).toList(),
        );
      },
    ),
  );
}
