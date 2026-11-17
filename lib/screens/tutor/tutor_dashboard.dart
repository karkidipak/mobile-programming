import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import 'upload_course_screen.dart';
import 'tutor_course_detail_screen.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});
  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  late Future<List<Course>> future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    future = userId == null ? Future.value([]) : CourseService().getTutorCourses(userId);
  }

  Future<void> _upload() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadCourseScreen()));
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: RefreshIndicator(
      color: AppTheme.yellow,
      backgroundColor: AppTheme.surface,
      onRefresh: () async => setState(_load),
      child: FutureBuilder<List<Course>>(
        future: future,
        builder: (context, snap) {
          final courses = snap.data ?? [];
          final learners = courses.fold<int>(0, (sum, c) => sum + c.studentCount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('LEARN WITH ME • CREATOR STUDIO', style: TextStyle(color: AppTheme.purpleLight, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                  SizedBox(height: 5),
                  Text('Tutor dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                ])),
                Container(
                  decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
                  child: IconButton(
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.yellow, size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppTheme.purple.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Turn your knowledge\ninto someone’s next skill.', style: TextStyle(color: Colors.white, fontSize: 22, height: 1.2, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Publish a course and grow your learning community.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.yellow,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _upload,
                    icon: const Icon(Icons.add_rounded, color: Colors.black),
                    label: const Text('Create a course', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: _metric('Your courses', '${courses.length}', Icons.video_library_rounded, AppTheme.purpleLight, AppTheme.purple)),
                const SizedBox(width: 12),
                Expanded(child: _metric('Total learners', '$learners', Icons.groups_2_rounded, AppTheme.yellow, AppTheme.pink)),
              ]),
              const SizedBox(height: 25),
              Row(children: [
                const Expanded(child: Text('Your courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink))),
                TextButton(
                  onPressed: _upload,
                  child: const Text('+ Add new', style: TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800)),
                ),
              ]),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(color: AppTheme.yellow))),
              if (snap.hasError)
                Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Could not load your courses: ${snap.error}', style: const TextStyle(color: AppTheme.ink)))),
              if (snap.hasData && courses.isEmpty)
                Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
                  const Icon(Icons.video_library_outlined, size: 44, color: AppTheme.purpleLight),
                  const SizedBox(height: 10),
                  const Text('Your teaching journey starts here', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
                  const SizedBox(height: 5),
                  const Text('Upload your first course to start reaching students.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(onPressed: _upload, icon: const Icon(Icons.add, color: AppTheme.yellow), label: const Text('Upload first course', style: TextStyle(color: AppTheme.yellow))),
                ]))),
              ...courses.map(_courseTile),
            ],
          );
        },
      ),
    ),
  );

  Widget _metric(String label, String value, IconData icon, Color iconColor, Color badgeColor) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: badgeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.arrow_upward_rounded, size: 12, color: badgeColor),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.ink)),
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _courseTile(Course course) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.play_lesson_rounded, color: AppTheme.yellow),
      ),
      title: Text(course.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('${course.isFree ? 'Free' : '\$${course.price.toStringAsFixed(2)}'}  •  ${course.studentCount} learners', style: const TextStyle(color: AppTheme.muted)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.muted),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => TutorCourseDetailScreen(course: course)));
        if (mounted) setState(_load);
      },
    ),
  );
}
