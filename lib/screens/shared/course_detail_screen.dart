import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../services/lesson_service.dart';
import 'lesson_player_screen.dart';
import 'chat_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool enrolled = false, loading = true;
  List<Map<String,dynamic>> lessons = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      enrolled = await CourseService().isEnrolled(widget.course.id);
      lessons = await LessonService().lessons(widget.course.id);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> _enroll() async {
    if (!widget.course.isFree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paid checkout is not configured yet. Connect Stripe or Razorpay server checkout before accepting payments.')));
      return;
    }
    try {
      await CourseService().enroll(widget.course.id);
      setState(() => enrolled = true);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background,
      title: const Text('Course details', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
          child: IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(course: widget.course))),
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.yellow, size: 20),
          ),
        ),
      ],
    ),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      if (widget.course.thumbnailUrl != null)
        ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(widget.course.thumbnailUrl!, height: 200, fit: BoxFit.cover))
      else
        Container(
          height: 200, width: double.infinity,
          decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(24)),
          child: const Center(child: Icon(Icons.play_lesson_rounded, size: 64, color: Colors.white70)),
        ),
      const SizedBox(height: 18),
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.purple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.purpleLight.withOpacity(0.3)),
          ),
          child: Text(widget.course.category.toUpperCase(), style: const TextStyle(color: AppTheme.purpleLight, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
        ),
        const Spacer(),
        const Icon(Icons.star_rounded, size: 20, color: AppTheme.yellow),
        const SizedBox(width: 4),
        Text(widget.course.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(width: 12),
        const Icon(Icons.people_alt_outlined, size: 18, color: AppTheme.muted),
        const SizedBox(width: 4),
        Text('${widget.course.studentCount}', style: const TextStyle(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
      Text(widget.course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.ink)),
      const SizedBox(height: 10),
      Text(widget.course.description, style: const TextStyle(color: AppTheme.muted, fontSize: 14, height: 1.45)),
      const SizedBox(height: 22),
      SizedBox(
        height: 54,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: enrolled ? AppTheme.surfaceLight : AppTheme.yellow,
            foregroundColor: enrolled ? AppTheme.ink : Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: loading || enrolled ? null : _enroll,
          child: Text(
            loading ? 'Loading...' : enrolled ? '✓ Enrolled in Course' : widget.course.isFree ? 'Enroll for free' : 'Buy course • \$${widget.course.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ),
      const SizedBox(height: 28),
      Row(children: [
        const Expanded(child: Text('Course lessons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(12)),
          child: Text('${lessons.length} lessons', style: const TextStyle(color: AppTheme.purpleLight, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
      const SizedBox(height: 12),
      if (lessons.isEmpty)
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Text('Lessons will appear here when the tutor adds them.', style: TextStyle(color: AppTheme.muted)))),
      ...lessons.map((lesson) {
        final videoUrl = lesson['video_url']?.toString().toLowerCase() ?? '';
        final isPdf = videoUrl.contains('.pdf');
        final isDoc = videoUrl.contains('.doc') || videoUrl.contains('.docx') || videoUrl.contains('.txt') || videoUrl.contains('.ppt');
        final isVideo = videoUrl.contains('.mp4') || videoUrl.contains('.m3u8') || videoUrl.contains('video') || videoUrl.contains('.mov');

        final icon = isPdf ? Icons.picture_as_pdf_rounded
          : isDoc ? Icons.description_rounded
          : isVideo ? Icons.play_arrow_rounded
          : videoUrl.isNotEmpty ? Icons.link_rounded
          : Icons.article_rounded;

        final iconColor = isPdf ? AppTheme.pink
          : isDoc ? AppTheme.purpleLight
          : AppTheme.yellow;

        final subtitle = isPdf ? 'PDF Document Attachment'
          : isDoc ? 'Document Resource'
          : isVideo ? 'Video Lesson'
          : videoUrl.isNotEmpty ? 'Resource Link'
          : 'Reading Lesson';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              title: Text(lesson['title'] ?? 'Lesson', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink)),
              subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              trailing: enrolled ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.yellow) : const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.muted),
              onTap: enrolled ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonPlayerScreen(courseId: widget.course.id, lesson: lesson))) : null,
            ),
          ),
        );
      }),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.yellow,
          side: const BorderSide(color: AppTheme.surfaceBorder),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => _reviewDialog(),
        icon: const Icon(Icons.star_outline_rounded, color: AppTheme.yellow),
        label: const Text('Write a review', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    ]),
  );

  void _reviewDialog() {
    int rating = 5;
    final comment = TextEditingController();
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(
      backgroundColor: AppTheme.surface,
      title: const Text('Rate this course', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButton<int>(
          dropdownColor: AppTheme.surfaceLight,
          value: rating,
          items: [1,2,3,4,5].map((v) => DropdownMenuItem(value: v, child: Text('$v stars', style: const TextStyle(color: AppTheme.ink)))).toList(),
          onChanged: (v) => setDialog(() => rating = v ?? 5),
        ),
        const SizedBox(height: 10),
        TextField(controller: comment, decoration: const InputDecoration(hintText: 'Share your experience'), maxLines: 3),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.muted))),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.yellow, foregroundColor: Colors.black),
          onPressed: () async {
            try { await CourseService().addReview(widget.course.id, rating, comment.text); }
            catch (e) { if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(e.toString()))); }
            if (mounted) Navigator.pop(this.context);
          },
          child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    )));
  }
}
