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
    appBar: AppBar(title: const Text('Course details'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(course: widget.course))), icon: const Icon(Icons.chat_bubble_outline))]),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      if (widget.course.thumbnailUrl != null) ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(widget.course.thumbnailUrl!, height: 190, fit: BoxFit.cover)),
      const SizedBox(height: 16),
      Text(widget.course.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppTheme.navy)),
      const SizedBox(height: 6),
      Text('${widget.course.category}  •  ${widget.course.studentCount} students  •  ${widget.course.rating.toStringAsFixed(1)} ★'),
      const SizedBox(height: 14),
      Text(widget.course.description),
      const SizedBox(height: 18),
      SizedBox(height: 50, child: FilledButton(onPressed: loading || enrolled ? null : _enroll, child: Text(loading ? 'Loading...' : enrolled ? 'You are enrolled' : widget.course.isFree ? 'Enroll for free' : 'Buy course • \$${widget.course.price.toStringAsFixed(2)}'))),
      const SizedBox(height: 22),
      const Text('Course lessons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      if (lessons.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Lessons will appear here when the tutor adds them.')),
      ...lessons.map((lesson) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
        title: Text(lesson['title'] ?? 'Lesson'),
        subtitle: Text(lesson['duration']?.toString() ?? 'Video lesson'),
        onTap: enrolled ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonPlayerScreen(courseId: widget.course.id, lesson: lesson))) : null,
      )),
      const SizedBox(height: 20),
      OutlinedButton.icon(onPressed: () => _reviewDialog(), icon: const Icon(Icons.star_outline), label: const Text('Write a review')),
    ]),
  );
  void _reviewDialog() {
    int rating = 5;
    final comment = TextEditingController();
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(
      title: const Text('Rate this course'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButton<int>(value: rating, items: [1,2,3,4,5].map((v) => DropdownMenuItem(value: v, child: Text('$v stars'))).toList(), onChanged: (v) => setDialog(() => rating = v ?? 5)),
        TextField(controller: comment, decoration: const InputDecoration(hintText: 'Share your experience'), maxLines: 3),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async {
        try { await CourseService().addReview(widget.course.id, rating, comment.text); }
        catch (e) { if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(e.toString()))); }
        if (mounted) Navigator.pop(this.context);
      }, child: const Text('Submit'))],
    )));
  }
}
