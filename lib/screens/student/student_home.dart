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
  int selectedDayIndex = 1;
  String selectedFilter = 'All';

  final days = [
    {'day': 'Sun', 'date': '5'},
    {'day': 'Mon', 'date': '6'},
    {'day': 'Tue', 'date': '7'},
    {'day': 'Wed', 'date': '8'},
    {'day': 'Thu', 'date': '9'},
    {'day': 'Fri', 'date': '10'},
    {'day': 'Sat', 'date': '11'},
  ];

  final filters = ['All', 'Plan', 'Calendar', 'Reminders'];

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
      color: AppTheme.yellow,
      backgroundColor: AppTheme.surface,
      onRefresh: () async => find(search.text),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          // Header Row: Avatar, Greeting, Actions
          Row(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.brandGradient,
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.surface,
                child: Icon(Icons.person, color: AppTheme.purpleLight, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good Morning,', style: TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text('Learn With Me', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              ]),
            ),
            Container(
              decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.ink, size: 20),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
              child: IconButton(
                tooltip: 'Sign out',
                onPressed: () => AuthService().signOut(),
                icon: const Icon(Icons.logout_rounded, color: AppTheme.yellow, size: 20),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // Date / Calendar Strip
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedDayIndex;
                final d = days[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedDayIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.purple : AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppTheme.purple : AppTheme.surfaceBorder,
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: AppTheme.purple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(d['day']!, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : AppTheme.muted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(d['date']!, style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : AppTheme.ink, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Category / Action Pills
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final f = filters[index];
                final isSelected = f == selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.surfaceLight : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppTheme.purpleLight : AppTheme.surfaceBorder),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppTheme.yellow : AppTheme.muted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // "Today's Progress" Ring Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.surfaceBorder),
              boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: Row(
              children: [
                // Circular Progress Ring (matching 80% widget in reference image)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72, height: 72,
                      child: CircularProgressIndicator(
                        value: 0.80,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.purple),
                      ),
                    ),
                    const Text(
                      '80%',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.ink),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Progress", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                      SizedBox(height: 6),
                      Text("You've completed 3 out of 5 lessons. Keep going!", style: TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Electric Yellow "Need a boost?" Card (from central reference image)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.yellowGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.yellow.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need a boost?',
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Start a 25-minute focus learning session now.',
                        style: TextStyle(color: Color(0xFF3B3000), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Start Session',
                          style: TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 40),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Priority / Category Stat Cards Row (from UI kit image)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppTheme.yellow, size: 20),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.pink.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Text('15 Task', style: TextStyle(color: AppTheme.pink, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('High Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.change_history_rounded, color: AppTheme.purpleLight, size: 20),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.yellow.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Text('10 Task', style: TextStyle(color: AppTheme.yellow, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Medium Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Search Field
          TextField(
            controller: search,
            onChanged: find,
            style: const TextStyle(color: AppTheme.ink),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.muted),
              hintText: 'Search courses or topics',
              suffixIcon: Icon(Icons.tune_rounded, color: AppTheme.yellow),
            ),
          ),

          const SizedBox(height: 24),

          // Courses Header
          Row(children: [
            const Expanded(child: Text('Popular courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink))),
            TextButton(
              onPressed: () => find(''),
              child: const Text('See all', style: TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w700)),
            ),
          ]),

          const SizedBox(height: 10),

          // Course List
          FutureBuilder<List<Course>>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.yellow)),
                );
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
    margin: const EdgeInsets.only(bottom: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.yellowGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Text(
                  course.isFree ? 'FREE' : '\$${course.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purpleLight.withOpacity(0.3)),
                ),
                child: Text(
                  course.category.toUpperCase(),
                  style: const TextStyle(color: AppTheme.purpleLight, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              Text(course.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              const SizedBox(height: 6),
              Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, height: 1.35, fontSize: 13)),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.people_alt_outlined, size: 16, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text('${course.studentCount} learners', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(width: 14),
                const Icon(Icons.star_rounded, size: 17, color: AppTheme.yellow),
                Text(course.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: AppTheme.ink, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('View course', style: TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.yellow),
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
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(children: [
        Icon(icon, size: 40, color: AppTheme.purpleLight),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 5),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
        if (action != null) ...[
          const SizedBox(height: 10),
          TextButton(onPressed: onTap, child: Text(action!, style: const TextStyle(color: AppTheme.yellow))),
        ],
      ]),
    ),
  );
}

