import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonService {
  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> lessons(String courseId) async {
    final rows = await _db.from('lessons').select().eq('course_id', courseId).order('position');
    return rows.cast<Map<String, dynamic>>();
  }

  String _getMimeType(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return 'application/pdf';
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'mp4': return 'video/mp4';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt': return 'application/vnd.ms-powerpoint';
      case 'pptx': return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt': return 'text/plain';
      case 'zip': return 'application/zip';
      default: return 'application/octet-stream';
    }
  }

  Future<String?> uploadLessonFile(Uint8List bytes, String fileName) async {
    final user = _db.auth.currentUser!;
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = 'lessons/${user.id}/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final mime = _getMimeType(fileName);
    await _db.storage.from('course-images').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: mime, upsert: true),
    );
    return _db.storage.from('course-images').getPublicUrl(path);
  }

  Future<void> addLesson({
    required String courseId,
    required String title,
    String? videoUrl,
    required int position,
  }) async {
    await _db.from('lessons').insert({
      'course_id': courseId,
      'title': title,
      'video_url': videoUrl ?? '',
      'position': position,
    });
  }

  Future<void> markComplete(String lessonId, String courseId) async {
    await _db.from('lesson_progress').upsert({
      'lesson_id': lessonId,
      'course_id': courseId,
      'student_id': _db.auth.currentUser!.id,
      'completed': true,
    }, onConflict: 'lesson_id,student_id');
  }
}
