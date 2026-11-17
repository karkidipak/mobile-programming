import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Course chat')),
    body: Column(children: [
      Expanded(child: StreamBuilder<List<Map<String,dynamic>>>(
        stream: ChatService().watch(widget.course.id),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(padding: const EdgeInsets.all(12), children: snap.data!.map((m) => Align(alignment: Alignment.centerLeft, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(m['body'] ?? ''))))).toList());
        },
      )),
      SafeArea(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
        Expanded(child: TextField(controller: text, decoration: const InputDecoration(hintText: 'Write a message'))),
        IconButton(onPressed: () async { final value = text.text.trim(); if (value.isEmpty) return; await ChatService().send(widget.course.id, value); text.clear(); }, icon: const Icon(Icons.send)),
      ]))),
    ]),
  );
}
