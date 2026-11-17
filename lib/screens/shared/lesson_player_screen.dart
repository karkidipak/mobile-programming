import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/lesson_service.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String courseId;
  final Map<String,dynamic> lesson;
  const LessonPlayerScreen({super.key, required this.courseId, required this.lesson});
  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}
class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  VideoPlayerController? controller;
  String? error;
  @override
  void initState() {
    super.initState();
    final url = widget.lesson['video_url']?.toString() ?? '';
    if (url.isEmpty) { error = 'This lesson has no video URL yet.'; return; }
    controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) { if (mounted) setState(() {}); }).catchError((e) { if (mounted) setState(() => error = e.toString()); });
  }
  @override
  void dispose() { controller?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.lesson['title'] ?? 'Lesson')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      AspectRatio(aspectRatio: controller?.value.isInitialized == true ? controller!.value.aspectRatio : 16/9,
        child: error != null ? Center(child: Text(error!)) : controller?.value.isInitialized == true
          ? Stack(alignment: Alignment.center, children: [VideoPlayer(controller!), IconButton(onPressed: () => setState(() => controller!.value.isPlaying ? controller!.pause() : controller!.play()), icon: Icon(controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: Colors.white))])
          : const Center(child: CircularProgressIndicator())),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: () async {
        await LessonService().markComplete(widget.lesson['id'].toString(), widget.courseId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson marked complete.')));
      }, icon: const Icon(Icons.check), label: const Text('Mark lesson complete')),
    ]),
  );
}
