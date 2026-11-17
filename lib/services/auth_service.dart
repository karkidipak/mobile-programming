import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'role': role},
    );

    if (response.user == null) {
      throw Exception('Supabase did not return a user. Please try again.');
    }

    // When email confirmation is disabled, a session exists and we can
    // safely create/update the profile from the client. When confirmation
    // is enabled, the database trigger in schema.sql creates the profile.
    if (response.session != null) {
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': name,
        'email': email,
        'role': role,
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<String> currentRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return '';

    try {
      final row = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final databaseRole = row?['role']?.toString();
      if (databaseRole == 'student' || databaseRole == 'tutor') {
        return databaseRole!;
      }
    } catch (_) {
      // Fall back to Auth metadata so the user is not trapped on a blank page.
    }

    final metadataRole = user.userMetadata?['role']?.toString();
    if (metadataRole == 'student' || metadataRole == 'tutor') {
      // Repair a missing profile when the signed-in session has permission.
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': user.userMetadata?['full_name'] ?? '',
          'email': user.email,
          'role': metadataRole,
        });
      } catch (_) {
        // Role fallback still lets the user enter the correct app area.
      }
      return metadataRole!;
    }

    throw Exception(
      'Your account profile is missing a valid role. Run the latest '
      'supabase/schema.sql in Supabase SQL Editor, then sign out and sign in.',
    );
  }
}
