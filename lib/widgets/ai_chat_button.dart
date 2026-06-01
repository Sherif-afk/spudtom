import 'package:flutter/material.dart';
import 'package:spudtom/views/chat_screen.dart';

Widget buildAIChatButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20, right: 0),
    child: SizedBox(
      height: 60,
      width: 60,
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Image.asset('assets/ai_logo.png'),
      ),
    ),
  );
}
