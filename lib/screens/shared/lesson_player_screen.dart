import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_theme.dart';
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
  String? url;
  bool isPdf = false;
  bool isDoc = false;
  bool isVideo = false;
  String? error;

  @override
  void initState() {
    super.initState();
    url = widget.lesson['video_url']?.toString().trim();
    if (url == null || url!.isEmpty) {
      return;
    }

    final lowerUrl = url!.toLowerCase();
    isPdf = lowerUrl.contains('.pdf');
    isDoc = lowerUrl.contains('.doc') || lowerUrl.contains('.docx') || lowerUrl.contains('.ppt') || lowerUrl.contains('.txt');
    isVideo = !isPdf && !isDoc && (lowerUrl.contains('.mp4') || lowerUrl.contains('.m3u8') || lowerUrl.contains('.mov') || lowerUrl.contains('video') || lowerUrl.startsWith('http'));

    if (isVideo && !isPdf && !isDoc) {
      controller = VideoPlayerController.networkUrl(Uri.parse(url!))
        ..initialize().then((_) { if (mounted) setState(() {}); }).catchError((e) {
          if (mounted) setState(() => error = 'Could not load video player: $e');
        });
    }
  }

  Future<void> _openFile() async {
    if (url == null || url!.isEmpty) return;
    final uri = Uri.parse(url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open link: $url')));
    }
  }

  @override
  void dispose() { controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background,
      title: Text(widget.lesson['title'] ?? 'Lesson', style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
    ),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      if (isPdf)
        _buildPdfCard()
      else if (isDoc)
        _buildDocCard()
      else if (url != null && url!.isNotEmpty)
        _buildVideoPlayer()
      else
        _buildNoContentCard(),

      const SizedBox(height: 24),

      SizedBox(
        height: 52,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.yellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await LessonService().markComplete(widget.lesson['id'].toString(), widget.courseId);
            if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Lesson marked complete.')));
          },
          icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
          label: const Text('Mark Lesson Complete', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    ]),
  );

  Widget _buildVideoPlayer() => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: AspectRatio(
      aspectRatio: controller?.value.isInitialized == true ? controller!.value.aspectRatio : 16/9,
      child: Container(
        color: Colors.black,
        child: error != null
          ? Center(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_creation_outlined, color: AppTheme.yellow, size: 42),
                  const SizedBox(height: 8),
                  Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openFile,
                    icon: const Icon(Icons.open_in_new_rounded, color: AppTheme.yellow, size: 18),
                    label: const Text('Open Video Link', style: TextStyle(color: AppTheme.yellow)),
                  ),
                ],
              ),
            ))
          : controller?.value.isInitialized == true
            ? Stack(alignment: Alignment.center, children: [
                VideoPlayer(controller!),
                GestureDetector(
                  onTap: () => setState(() => controller!.value.isPlaying ? controller!.pause() : controller!.play()),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.yellow.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(controller!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 48, color: Colors.black),
                  ),
                ),
              ])
            : const Center(child: CircularProgressIndicator(color: AppTheme.yellow)),
      ),
    ),
  );

  Widget _buildPdfCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.surfaceBorder),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppTheme.pink.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.picture_as_pdf_rounded, size: 64, color: AppTheme.pink),
        ),
        const SizedBox(height: 16),
        Text(widget.lesson['title'] ?? 'PDF Document Lesson', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('This lesson contains a PDF document attachment.', style: TextStyle(color: AppTheme.muted, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white),
            onPressed: _openFile,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('View / Open PDF Document', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    ),
  );

  Widget _buildDocCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.surfaceBorder),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppTheme.purple.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.description_rounded, size: 64, color: AppTheme.purpleLight),
        ),
        const SizedBox(height: 16),
        Text(widget.lesson['title'] ?? 'Document Lesson', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.ink), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('This lesson contains a document resource file.', style: TextStyle(color: AppTheme.muted, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white),
            onPressed: _openFile,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download / Open Document', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    ),
  );

  Widget _buildNoContentCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.surfaceBorder),
    ),
    child: const Column(
      children: [
        Icon(Icons.article_rounded, size: 54, color: AppTheme.purpleLight),
        SizedBox(height: 14),
        Text('Reading & Concept Lesson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        SizedBox(height: 6),
        Text('Review the lesson topic and mark complete when finished.', style: TextStyle(color: AppTheme.muted, fontSize: 13), textAlign: TextAlign.center),
      ],
    ),
  );
}
