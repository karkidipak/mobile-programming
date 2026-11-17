import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/course.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final Course course;
  const ChatScreen({super.key, required this.course});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final text = TextEditingController();

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Course Chat', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(widget.course.title, style: const TextStyle(color: AppTheme.purpleLight, fontSize: 12)),
        ],
      ),
    ),
    body: Column(children: [
      Expanded(
        child: StreamBuilder<List<Map<String,dynamic>>>(
          stream: ChatService().watch(widget.course.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.yellow));
            }
            final messages = snap.data ?? [];
            if (messages.isEmpty) {
              return const Center(
                child: Text('No messages yet. Start the conversation!', style: TextStyle(color: AppTheme.muted)),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: messages.map((m) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Text(
                    m['body'] ?? '',
                    style: const TextStyle(color: AppTheme.ink, fontSize: 14),
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ),
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF140D2B),
            border: Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 1)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: text,
                style: const TextStyle(color: AppTheme.ink),
                decoration: const InputDecoration(
                  hintText: 'Write a message...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.yellow,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () async {
                  final value = text.text.trim();
                  if (value.isEmpty) return;
                  await ChatService().send(widget.course.id, value);
                  text.clear();
                },
                icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              ),
            ),
          ]),
        ),
      ),
    ]),
  );
}
