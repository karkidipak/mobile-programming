import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> messages(String courseId) async {
    final rows = await _db.from('messages').select('*, profiles!messages_sender_id_fkey(full_name)')
      .eq('course_id', courseId).order('created_at');
    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> send(String courseId, String message) async {
    await _db.from('messages').insert({
      'course_id': courseId,
      'sender_id': _db.auth.currentUser!.id,
      'body': message,
    });
  }

  Stream<List<Map<String, dynamic>>> watch(String courseId) {
    return _db.from('messages').stream(primaryKey: ['id'])
      .eq('course_id', courseId).order('created_at');
  }
}
