import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/course.dart';
import '../../core/app_theme.dart';

class CertificateScreen extends StatefulWidget {
  final Course course;
  const CertificateScreen({super.key, required this.course});
  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}
class _CertificateScreenState extends State<CertificateScreen> {
  late Future<bool> completion = _isComplete();

  Future<bool> _isComplete() async {
    final db = Supabase.instance.client;
    final uid = db.auth.currentUser!.id;
    final lessons = await db.from('lessons').select('id').eq('course_id', widget.course.id);
    if (lessons.isEmpty) return false;
    final progress = await db.from('lesson_progress').select('lesson_id')
      .eq('course_id', widget.course.id).eq('student_id', uid).eq('completed', true);
    final completedIds = progress.map((e) => e['lesson_id'].toString()).toSet();
    return lessons.every((lesson) => completedIds.contains(lesson['id'].toString()));
  }

  Future<void> printCertificate() async {
    final db = Supabase.instance.client;
    // Re-check at the moment of issuing the certificate.
    if (!await _isComplete()) throw Exception('Complete every lesson before generating your certificate.');
    final profile = await db.from('profiles').select('full_name').eq('id', db.auth.currentUser!.id).single();
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (_) => pw.Center(child: pw.Container(
      padding: const pw.EdgeInsets.all(35),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 3)),
      child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text('LEARN WITH ME', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 35),
        pw.Text('CERTIFICATE OF COMPLETION', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 25),
        pw.Text('This certificate is presented to'),
        pw.SizedBox(height: 12),
        pw.Text(profile['full_name'] ?? 'Student', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        pw.Text('for completing the course'),
        pw.SizedBox(height: 10),
        pw.Text(widget.course.title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 30),
        pw.Text('Issued ${DateTime.now().toLocal().toString().split(' ').first}'),
      ]),
    ))));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background,
      title: const Text('Certificate', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
    ),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Card(child: Padding(
      padding: const EdgeInsets.all(26), child: FutureBuilder<bool>(
        future: completion,
        builder: (context, snap) {
          final done = snap.data == true;
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: done ? AppTheme.yellow.withOpacity(0.15) : AppTheme.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium_rounded, size: 68, color: done ? AppTheme.yellow : AppTheme.muted),
            ),
            const SizedBox(height: 16),
            const Text('Certificate of Completion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.ink), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(widget.course.title, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.purpleLight, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            if (snap.connectionState == ConnectionState.waiting) const CircularProgressIndicator(color: AppTheme.yellow)
            else Text(done ? 'Congratulations! You have completed every lesson. Your certificate is ready to print or download.' : 'Complete every lesson in this course to unlock your certificate.', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, height: 1.4)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: done ? AppTheme.yellow : AppTheme.surfaceLight,
                  foregroundColor: done ? Colors.black : AppTheme.muted,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: done ? () async {
                  try { await printCertificate(); }
                  catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
                } : null,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Generate PDF Certificate', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ]);
        },
      ),
    )))),
  );
}
