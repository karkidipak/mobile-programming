import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../student/student_shell.dart';
import '../tutor/tutor_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _subscription;
  String? _userId;
  Future<String>? _roleFuture;

  @override
  void initState() {
    super.initState();
    _syncUser();
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      _syncUser();
    });
  }

  void _syncUser() {
    final user = Supabase.instance.client.auth.currentUser;
    final nextId = user?.id;
    if (nextId != _userId) {
      _userId = nextId;
      _roleFuture = user == null ? null : AuthService().currentRole();
      if (mounted) setState(() {});
    } else if (user != null && _roleFuture == null) {
      _roleFuture = AuthService().currentRole();
      if (mounted) setState(() {});
    }
  }

  void _retry() {
    setState(() {
      _roleFuture = AuthService().currentRole();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const LoginScreen();

    final future = _roleFuture;
    if (future == null) {
      return const _LoadingScreen(message: 'Preparing your learning space...');
    }

    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen(message: 'Preparing your learning space...');
        }

        if (snapshot.hasError) {
          return _AuthProblemScreen(
            message: snapshot.error.toString(),
            onRetry: _retry,
            onSignOut: () => Supabase.instance.client.auth.signOut(),
          );
        }

        if (snapshot.data == 'tutor') return const TutorShell();
        if (snapshot.data == 'student') return const StudentShell();

        return _AuthProblemScreen(
          message: 'We could not identify whether this account is a student or tutor.',
          onRetry: _retry,
          onSignOut: () => Supabase.instance.client.auth.signOut(),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  final String message;
  const _LoadingScreen({required this.message});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 76, width: 76,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 22),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: AppTheme.muted)),
      ]),
    ),
  );
}

class _AuthProblemScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;
  const _AuthProblemScreen({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded, size: 54, color: AppTheme.teal),
          const SizedBox(height: 16),
          const Text('Almost there', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppTheme.navy)),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onRetry, child: const Text('Try again'))),
          TextButton(onPressed: onSignOut, child: const Text('Sign out')),
        ]),
      ),
    ),
  );
}
