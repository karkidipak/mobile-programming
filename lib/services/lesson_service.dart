import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonService {
  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> lessons(String courseId) async {
    final rows = await _db.from('lessons').select().eq('course_id', courseId).order('position');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> addLesson({
    required String courseId,
    required String title,
    required String videoUrl,
    required int position,
  }) async {
    await _db.from('lessons').insert({
      'course_id': courseId,
      'title': title,
      'video_url': videoUrl,
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
