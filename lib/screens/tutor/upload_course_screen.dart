import 'dart:io';
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
  File? image;
  String? imageUrl;
  @override
  void initState() { super.initState(); isFree = widget.initial?['is_free'] != false; imageUrl = widget.initial?['thumbnail_url']; }
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => image = File(picked.path));
  }
  Future<void> save() async {
    if (title.text.trim().isEmpty || description.text.trim().isEmpty || category.text.trim().isEmpty || (!isFree && (double.tryParse(price.text) ?? 0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all fields and enter a valid paid-course price.'))); return;
    }
    setState(() => busy = true);
    try {
      if (image != null) imageUrl = await CourseService().uploadThumbnail(image!);
      await CourseService().saveCourse(id: widget.courseId, title: title.text.trim(), description: description.text.trim(), category: category.text.trim(), isFree: isFree, price: double.tryParse(price.text) ?? 0, thumbnailUrl: imageUrl);
      if (mounted) Navigator.pop(context);
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.courseId == null ? 'Upload course' : 'Edit course')), body: ListView(padding: const EdgeInsets.all(18), children: [
    GestureDetector(onTap: pickImage, child: Container(height: 160, decoration: BoxDecoration(color: const Color(0xFFEAF3F5), borderRadius: BorderRadius.circular(18)), child: image != null ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(image!, fit: BoxFit.cover)) : imageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.network(imageUrl!, fit: BoxFit.cover)) : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, size: 42, color: AppTheme.navy), Text('Add course cover image')]))),
    const SizedBox(height: 16),
    TextField(controller: title, decoration: const InputDecoration(labelText: 'Course title')),
    const SizedBox(height: 12), TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
    const SizedBox(height: 12), TextField(controller: description, maxLines: 5, decoration: const InputDecoration(labelText: 'Course description')),
    const SizedBox(height: 18), const Text('Course access', style: TextStyle(fontWeight: FontWeight.bold)),
    SwitchListTile(title: Text(isFree ? 'Free course' : 'Paid course'), subtitle: const Text('Turn off to set a course price'), value: isFree, onChanged: (v) => setState(() => isFree = v)),
    if (!isFree) TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (USD)', prefixText: '\$')),
    const SizedBox(height: 20), SizedBox(height: 52, child: FilledButton(onPressed: busy ? null : save, child: busy ? const CircularProgressIndicator() : const Text('Save course'))),
  ]));
}
