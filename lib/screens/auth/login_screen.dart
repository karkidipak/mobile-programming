import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  String role = 'student';
  bool busy = false;
  bool obscure = true;

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      _message('Please enter your email and password.');
      return;
    }
    setState(() => busy = true);
    try {
      await AuthService().signIn(email.text.trim(), password.text);
      final actualRole = await AuthService().currentRole();
      if (actualRole != role) {
        await AuthService().signOut();
        throw Exception('This account is registered as ${actualRole.toUpperCase()}. Select the correct login type.');
      }
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 76, width: 76,
                decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x30286A91), blurRadius: 20, offset: Offset(0, 8))]),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 28),
              const Text('LEARN WITH ME', style: TextStyle(color: AppTheme.teal, fontSize: 12, letterSpacing: 2.2, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your next skill starts here.', style: TextStyle(fontSize: 30, height: 1.15, fontWeight: FontWeight.w800, color: AppTheme.navy)),
              const SizedBox(height: 10),
              const Text('Learn from expert tutors. Teach what you love.', style: TextStyle(color: AppTheme.muted, fontSize: 15)),
              const SizedBox(height: 30),
              Card(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Welcome back', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                  const SizedBox(height: 5),
                  const Text('Choose your account type to continue.', style: TextStyle(color: AppTheme.muted)),
                  const SizedBox(height: 18),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'student', label: Text('Student'), icon: Icon(Icons.school_outlined)),
                      ButtonSegment(value: 'tutor', label: Text('Tutor'), icon: Icon(Icons.cast_for_education_outlined)),
                    ],
                    selected: {role},
                    onSelectionChanged: (v) => setState(() => role = v.first),
                  ),
                  const SizedBox(height: 18),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline))),
                  const SizedBox(height: 13),
                  TextField(controller: password, obscureText: obscure, onSubmitted: (_) => login(), decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 54, child: FilledButton(
                    onPressed: busy ? null : login,
                    child: busy ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Sign in'), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 19)]),
                  )),
                ]),
              )),
              const SizedBox(height: 20),
              Center(child: Wrap(alignment: WrapAlignment.center, children: [
                const Text("Don't have an account? ", style: TextStyle(color: AppTheme.muted)),
                GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Create one', style: TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w800))),
              ])),
              const SizedBox(height: 22),
              const Center(child: Text('Learn • Grow • Share', style: TextStyle(color: AppTheme.muted, letterSpacing: 1.2, fontSize: 12))),
            ]),
          ),
        ),
      ),
    ),
  );
}
