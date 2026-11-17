import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
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

  Uint8List? pickedFileBytes;
  String? pickedFileName;
  bool isUploadingLesson = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    count = CourseService().enrolledCount(widget.course.id);
    students = CourseService().studentsForCourse(widget.course.id);
  }

  Future<void> pickLessonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;
        bytes ??= await file.xFile.readAsBytes();
        
        setState(() {
          pickedFileBytes = bytes;
          pickedFileName = file.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick file: $e')),
        );
      }
    }
  }

  Future<void> addLesson() async {
    final title = lessonTitle.text.trim();
    final url = videoUrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the lesson title.'),
        ),
      );
      return;
    }

    setState(() => isUploadingLesson = true);
    try {
      String? finalUrl = url.isEmpty ? null : url;

      if (pickedFileBytes != null && pickedFileName != null) {
        final uploadedUrl = await LessonService().uploadLessonFile(
          pickedFileBytes!,
          pickedFileName!,
        );
        if (uploadedUrl != null) {
          finalUrl = uploadedUrl;
        }
      }

      final existingLessons =
          await LessonService().lessons(widget.course.id);

      await LessonService().addLesson(
        courseId: widget.course.id,
        title: title,
        videoUrl: finalUrl,
        position: existingLessons.length + 1,
      );

      lessonTitle.clear();
      videoUrl.clear();
      setState(() {
        pickedFileBytes = null;
        pickedFileName = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson added successfully.')),
      );
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add lesson: $error')),
      );
    } finally {
      if (mounted) setState(() => isUploadingLesson = false);
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
        backgroundColor: AppTheme.surface,
        title: const Text('Delete course?', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
        content: const Text(
          'This will also delete its lessons and enrollments. This action cannot be undone.',
          style: TextStyle(color: AppTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.pink),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Manage course', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Edit course',
            onPressed: editCourse,
            icon: const Icon(Icons.edit_rounded, color: AppTheme.yellow),
          ),
          IconButton(
            tooltip: 'Delete course',
            onPressed: deleteCourse,
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.pink),
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
              fontWeight: FontWeight.w900,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<int>(
            future: count,
            builder: (context, snapshot) {
              return Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
                    child: const Icon(Icons.people_alt_rounded, color: AppTheme.yellow),
                  ),
                  title: const Text('Enrolled students', style: TextStyle(color: AppTheme.purpleLight, fontWeight: FontWeight.w700)),
                  trailing: Text(
                    '${snapshot.data ?? 0}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.yellow,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            'Add a lesson',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lessonTitle,
            style: const TextStyle(color: AppTheme.ink),
            decoration: const InputDecoration(labelText: 'Lesson title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: videoUrl,
            keyboardType: TextInputType.url,
            style: const TextStyle(color: AppTheme.ink),
            decoration: const InputDecoration(
              labelText: 'Video or File URL (optional)',
              prefixIcon: Icon(Icons.link_rounded, color: AppTheme.purpleLight),
            ),
          ),
          const SizedBox(height: 12),
          // File Picker / PDF Attachment Option
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.yellow,
              side: const BorderSide(color: AppTheme.surfaceBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: isUploadingLesson ? null : pickLessonFile,
            icon: const Icon(Icons.attach_file_rounded, color: AppTheme.yellow),
            label: Text(
              pickedFileName != null ? 'Selected: $pickedFileName' : 'Attach PDF, Document, or Video file',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (pickedFileName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.yellow),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Attached: $pickedFileName', style: const TextStyle(color: AppTheme.purpleLight, fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    pickedFileBytes = null;
                    pickedFileName = null;
                  }),
                  child: const Text('Remove', style: TextStyle(color: AppTheme.pink, fontSize: 12)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.yellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: isUploadingLesson ? null : addLesson,
              icon: isUploadingLesson
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.add_rounded, color: Colors.black),
              label: Text(
                isUploadingLesson ? 'Uploading lesson file...' : 'Add lesson',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Enrolled Students',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: students,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(color: AppTheme.yellow),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text('Could not load students: ${snapshot.error}', style: const TextStyle(color: AppTheme.muted));
              }

              final studentRows = snapshot.data ?? [];

              if (studentRows.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No students enrolled yet.', style: TextStyle(color: AppTheme.muted)),
                  ),
                );
              }

              return Column(
                children: studentRows.map<Widget>((student) {
                  final profile = student['profiles'] as Map<String, dynamic>?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.surfaceLight,
                          child: Icon(Icons.person, color: AppTheme.purpleLight),
                        ),
                        title: Text(
                          profile?['full_name']?.toString() ?? 'Student',
                          style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          profile?['email']?.toString() ?? '',
                          style: const TextStyle(color: AppTheme.muted),
                        ),
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
