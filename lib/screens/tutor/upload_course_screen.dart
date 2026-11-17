import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/course_service.dart';
import '../../core/app_theme.dart';

class UploadCourseScreen extends StatefulWidget {
  final String? courseId;
  final Map<String,dynamic>? initial;
  const UploadCourseScreen({super.key, this.courseId, this.initial});
  @override
  State<UploadCourseScreen> createState() => _UploadCourseScreenState();
}

class _UploadCourseScreenState extends State<UploadCourseScreen> {
  late final title = TextEditingController(text: widget.initial?['title'] ?? '');
  late final description = TextEditingController(text: widget.initial?['description'] ?? '');
  late final category = TextEditingController(text: widget.initial?['category'] ?? '');
  late final price = TextEditingController(text: widget.initial?['price']?.toString() ?? '');
  bool isFree = true, busy = false;
  Uint8List? imageBytes;
  String? imageName;
  String? imageUrl;

  @override
  void initState() { super.initState(); isFree = widget.initial?['is_free'] != false; imageUrl = widget.initial?['thumbnail_url']; }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    category.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
        imageName = picked.name;
      });
    }
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty || description.text.trim().isEmpty || category.text.trim().isEmpty || (!isFree && (double.tryParse(price.text) ?? 0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all fields and enter a valid paid-course price.'))); return;
    }
    setState(() => busy = true);
    try {
      if (imageBytes != null && imageName != null) {
        imageUrl = await CourseService().uploadThumbnail(imageBytes!, imageName!);
      }
      await CourseService().saveCourse(id: widget.courseId, title: title.text.trim(), description: description.text.trim(), category: category.text.trim(), isFree: isFree, price: double.tryParse(price.text) ?? 0, thumbnailUrl: imageUrl);
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background,
      title: Text(widget.courseId == null ? 'Upload course' : 'Edit course', style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
    ),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      GestureDetector(
        onTap: pickImage,
        child: Container(
          height: 170,
          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.surfaceBorder)),
          child: imageBytes != null ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.memory(imageBytes!, fit: BoxFit.cover))
            : imageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(imageUrl!, fit: BoxFit.cover))
            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_rounded, size: 44, color: AppTheme.yellow),
                SizedBox(height: 8),
                Text('Add course cover image', style: TextStyle(color: AppTheme.purpleLight, fontWeight: FontWeight.w700)),
              ]),
        ),
      ),
      const SizedBox(height: 18),
      TextField(controller: title, style: const TextStyle(color: AppTheme.ink), decoration: const InputDecoration(labelText: 'Course title')),
      const SizedBox(height: 12),
      TextField(controller: category, style: const TextStyle(color: AppTheme.ink), decoration: const InputDecoration(labelText: 'Category')),
      const SizedBox(height: 12),
      TextField(controller: description, maxLines: 4, style: const TextStyle(color: AppTheme.ink), decoration: const InputDecoration(labelText: 'Course description')),
      const SizedBox(height: 20),
      const Text('Course Access', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.ink, fontSize: 16)),
      const SizedBox(height: 8),
      Card(
        child: SwitchListTile(
          activeThumbColor: AppTheme.yellow,
          title: Text(isFree ? 'Free course' : 'Paid course', style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800)),
          subtitle: const Text('Turn off to set a course price', style: TextStyle(color: AppTheme.muted)),
          value: isFree,
          onChanged: (v) => setState(() => isFree = v),
        ),
      ),
      if (!isFree) ...[
        const SizedBox(height: 12),
        TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: AppTheme.ink), decoration: const InputDecoration(labelText: 'Price (USD)', prefixText: '\$')),
      ],
      const SizedBox(height: 24),
      SizedBox(
        height: 54,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.yellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: busy ? null : save,
          child: busy ? const CircularProgressIndicator(color: Colors.black) : const Text('Save Course', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ),
    ]),
  );
}
