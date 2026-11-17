import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String role = 'student';
  bool busy = false;
  bool obscure = true;

  Future<void> register() async {
    if (name.text.trim().isEmpty || email.text.trim().isEmpty || password.text.length < 6) {
      _message('Enter your name, a valid email and a password of at least 6 characters.');
      return;
    }

    setState(() => busy = true);
    try {
      await AuthService().signUp(
        name: name.text.trim(),
        email: email.text.trim(),
        password: password.text,
        role: role,
      );

      if (!mounted) return;
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      if (hasSession) {
        // AuthGate observes the Supabase session and routes to the selected dashboard.
        Navigator.pop(context);
      } else {
        _message('Account created. Check your email to confirm your account, then sign in.');
        Navigator.pop(context);
      }
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _message(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(backgroundColor: AppTheme.background, title: const Text('Create account', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800))),
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Card(
        child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Join our community', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.ink)),
          const SizedBox(height: 7),
          const Text('Create an account as a student or tutor.', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 22),
          const Text('I want to join as', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.purpleLight)),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'student', label: Text('Student'), icon: Icon(Icons.school_outlined)),
              ButtonSegment(value: 'tutor', label: Text('Tutor'), icon: Icon(Icons.co_present_outlined)),
            ],
            selected: {role},
            onSelectionChanged: (v) => setState(() => role = v.first),
          ),
          const SizedBox(height: 18),
          TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'Password (at least 6 characters)', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, height: 54, child: FilledButton(
            onPressed: busy ? null : register,
            child: busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create account'),
          )),
        ])),
      )),
    )),
  );
}
