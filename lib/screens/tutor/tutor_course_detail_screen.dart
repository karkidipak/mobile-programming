import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../services/lesson_service.dart';
import 'upload_course_screen.dart';

class TutorCourseDetailScreen extends StatefulWidget {
  final Course course;

  const TutorCourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<TutorCourseDetailScreen> createState() =>
      _TutorCourseDetailScreenState();
}

class _TutorCourseDetailScreenState extends State<TutorCourseDetailScreen> {
  late Future<int> count;
  late Future<List<Map<String, dynamic>>> students;

  final TextEditingController lessonTitle = TextEditingController();
  final TextEditingController videoUrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    count = CourseService().enrolledCount(widget.course.id);
    students = CourseService().studentsForCourse(widget.course.id);
  }

  Future<void> addLesson() async {
    final title = lessonTitle.text.trim();
    final url = videoUrl.text.trim();

    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter both the lesson title and video URL.'),
        ),
      );
      return;
    }

    try {
      final existingLessons =
          await LessonService().lessons(widget.course.id);

      await LessonService().addLesson(
        courseId: widget.course.id,
        title: title,
        videoUrl: url,
        position: existingLessons.length + 1,
      );

      lessonTitle.clear();
      videoUrl.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson added successfully.')),
      );
      setState(_refresh);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add lesson: $error')),
      );
    }
  }

  Future<void> editCourse() async {
    try {
      final row = await Supabase.instance.client
          .from('courses')
          .select()
          .eq('id', widget.course.id)
          .single();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UploadCourseScreen(
            courseId: widget.course.id,
            initial: row,
          ),
        ),
      );

      if (mounted) setState(_refresh);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open course editor: $error')),
      );
    }
  }

  Future<void> deleteCourse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete course?'),
        content: const Text(
          'This will also delete its lessons and enrollments. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await CourseService().deleteCourse(widget.course.id);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete course: $error')),
      );
    }
  }

  @override
  void dispose() {
    lessonTitle.dispose();
    videoUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage course'),
        actions: [
          IconButton(
            tooltip: 'Edit course',
            onPressed: editCourse,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete course',
            onPressed: deleteCourse,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            widget.course.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<int>(
            future: count,
            builder: (context, snapshot) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Enrolled students'),
                  trailing: Text(
                    '${snapshot.data ?? 0}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Add a lesson',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: lessonTitle,
            decoration: const InputDecoration(labelText: 'Lesson title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: videoUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Video URL (MP4 or supported stream)',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: addLesson,
            icon: const Icon(Icons.add),
            label: const Text('Add lesson'),
          ),
          const SizedBox(height: 22),
          const Text(
            'Students',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: students,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text('Could not load students: ${snapshot.error}');
              }

              final studentRows = snapshot.data ?? [];

              if (studentRows.isEmpty) {
                return const Text('No students enrolled yet.');
              }

              return Column(
                children: studentRows.map<Widget>((student) {
                  final profile = student['profiles'] as Map<String, dynamic>?;

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        profile?['full_name']?.toString() ?? 'Student',
                      ),
                      subtitle: Text(
                        profile?['email']?.toString() ?? '',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
