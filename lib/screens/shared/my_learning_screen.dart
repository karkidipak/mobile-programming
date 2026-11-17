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
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('My learning')), body: FutureBuilder<List<Course>>(
    future: load(), builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      if (snap.data!.isEmpty) return const Center(child: Text('Your enrolled courses will appear here.'));
      return ListView(padding: const EdgeInsets.all(16), children: snap.data!.map((c) => Card(child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFE5F2F4), child: Icon(Icons.menu_book, color: AppTheme.navy)),
        title: Text(c.title), subtitle: Text(c.category),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))),
        trailing: IconButton(icon: const Icon(Icons.workspace_premium), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(course: c)))),
      ))).toList());
    },
  ));
}
