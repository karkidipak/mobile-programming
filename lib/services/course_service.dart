import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class CourseService {
  final _db = Supabase.instance.client;

  Future<List<Course>> getCourses({String search = ''}) async {
    var query = _db.from('courses').select('*, enrollments(count), reviews(rating)');
    if (search.trim().isNotEmpty) {
      query = query.or('title.ilike.%$search%,description.ilike.%$search%,category.ilike.%$search%');
    }
    final rows = await query.order('created_at', ascending: false);
    return rows.map((row) {
      final course = Map<String, dynamic>.from(row);
      final enrollments = course['enrollments'] as List? ?? [];
      course['student_count'] = enrollments.fold<int>(0, (sum, item) => sum + ((item['count'] as num?)?.toInt() ?? 0));
      final reviews = course['reviews'] as List? ?? [];
      if (reviews.isNotEmpty) {
        final ratings = reviews.map((e) => (e['rating'] as num).toDouble()).toList();
        course['rating'] = ratings.reduce((a, b) => a + b) / ratings.length;
      }
      return Course.fromMap(course);
    }).toList();
  }

  Future<List<Course>> getTutorCourses(String tutorId) async {
    final rows = await _db.from('courses').select('*, enrollments(count)').eq('tutor_id', tutorId).order('created_at', ascending: false);
    return rows.map((row) {
      final data = Map<String, dynamic>.from(row);
      final enrollments = data['enrollments'] as List? ?? [];
      data['student_count'] = enrollments.fold<int>(0, (sum, item) => sum + ((item['count'] as num?)?.toInt() ?? 0));
      return Course.fromMap(data);
    }).toList();
  }

  Future<String?> uploadThumbnail(Uint8List bytes, String fileName) async {
    final user = _db.auth.currentUser!;
    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _db.storage.from('course-images').uploadBinary(path, bytes);
    return _db.storage.from('course-images').getPublicUrl(path);
  }

  Future<void> saveCourse({
    String? id,
    required String title,
    required String description,
    required String category,
    required bool isFree,
    required double price,
    String? thumbnailUrl,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'category': category,
      'is_free': isFree,
      'price': isFree ? 0 : price,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    };
    if (id == null) {
      await _db.from('courses').insert({...data, 'tutor_id': _db.auth.currentUser!.id});
    } else {
      await _db.from('courses').update(data).eq('id', id);
    }
  }

  Future<void> deleteCourse(String id) async {
    await _db.from('courses').delete().eq('id', id);
  }

  Future<int> enrolledCount(String courseId) async {
    final rows = await _db.from('enrollments').select('id').eq('course_id', courseId);
    return rows.length;
  }

  Future<List<Map<String, dynamic>>> studentsForCourse(String courseId) async {
    return await _db.from('enrollments').select('student_id, profiles!enrollments_student_id_fkey(full_name,email)').eq('course_id', courseId);
  }

  Future<bool> isEnrolled(String courseId) async {
    final uid = _db.auth.currentUser!.id;
    final row = await _db.from('enrollments').select('id').eq('course_id', courseId).eq('student_id', uid).maybeSingle();
    return row != null;
  }

  Future<void> enroll(String courseId) async {
    final uid = _db.auth.currentUser!.id;
    await _db.from('enrollments').upsert({'course_id': courseId, 'student_id': uid}, onConflict: 'course_id,student_id');
  }

  Future<void> addReview(String courseId, int rating, String comment) async {
    await _db.from('reviews').upsert({
      'course_id': courseId,
      'student_id': _db.auth.currentUser!.id,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'course_id,student_id');
  }
}
