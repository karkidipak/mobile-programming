import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../shared/course_detail_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});
  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final search = TextEditingController();
  late Future<List<Course>> future;

  @override
  void initState() {
    super.initState();
    future = CourseService().getCourses();
  }

  void find(String value) {
    setState(() => future = CourseService().getCourses(search: value));
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: RefreshIndicator(
      onRefresh: () async => find(search.text),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          Row(children: [
            Container(
              height: 46, width: 46,
              decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.school_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LEARN WITH ME', style: TextStyle(fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w800, color: AppTheme.teal)),
              Text('Discover', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.navy)),
            ])),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => AuthService().signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.muted),
            ),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x24286A91), blurRadius: 18, offset: Offset(0, 8))],
            ),
            child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Build skills.\nUnlock your future.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w800)),
                SizedBox(height: 9),
                Text('Explore courses made by passionate tutors.', style: TextStyle(color: Colors.white70, height: 1.35)),
              ])),
              const SizedBox(width: 8),
              const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 62),
            ]),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: search,
            onChanged: find,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search courses or topics',
              suffixIcon: Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            const Expanded(child: Text('Popular courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.navy))),
            TextButton(onPressed: () => find(''), child: const Text('See all')),
          ]),
          const SizedBox(height: 8),
          FutureBuilder<List<Course>>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator()));
              }
              if (snap.hasError) {
                return _NoticeCard(
                  icon: Icons.cloud_off_outlined,
                  title: 'Courses could not load',
                  subtitle: snap.error.toString(),
                  action: 'Try again',
                  onTap: () => find(search.text),
                );
              }
              final courses = snap.data ?? [];
              if (courses.isEmpty) {
                return const _NoticeCard(
                  icon: Icons.menu_book_outlined,
                  title: 'No courses yet',
                  subtitle: 'New courses from tutors will appear here.',
                );
              }
              return Column(children: courses.map(_courseCard).toList());
            },
          ),
        ],
      ),
    ),
  );

  Widget _courseCard(Course course) => Container(
    margin: const EdgeInsets.only(bottom: 15),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            if (course.thumbnailUrl != null)
              Image.network(course.thumbnailUrl!, height: 165, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverPlaceholder())
            else
              _coverPlaceholder(),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: Text(course.isFree ? 'FREE' : '\$${course.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.category.toUpperCase(), style: const TextStyle(color: AppTheme.teal, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(course.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.navy)),
              const SizedBox(height: 6),
              Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, height: 1.35)),
              const SizedBox(height: 13),
              Row(children: [
                const Icon(Icons.people_alt_outlined, size: 16, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text('${course.studentCount} learners', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(width: 14),
                const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF2B544)),
                Text(course.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                const Spacer(),
                const Text('View course', style: TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w800, fontSize: 12)),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.blue),
              ]),
            ]),
          ),
        ]),
      ),
    ),
  );

  Widget _coverPlaceholder() => Container(
    height: 165, width: double.infinity,
    decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
    child: const Center(child: Icon(Icons.play_lesson_rounded, size: 58, color: Colors.white70)),
  );
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onTap;
  const _NoticeCard({required this.icon, required this.title, required this.subtitle, this.action, this.onTap});

  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(22),
    child: Column(children: [
      Icon(icon, size: 40, color: AppTheme.teal),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
      const SizedBox(height: 5),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ]),
  ));
}
