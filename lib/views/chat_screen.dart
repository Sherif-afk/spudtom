// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:spudtom/constants/app_colors.dart';
// import 'package:spudtom/views/home_screen.dart';
// import 'package:spudtom/services/ai_chat_service.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<Map<String, dynamic>> _messages = [];
//   bool _isLoading = false;

//   final AiChatService _chatService = AiChatService();

//   @override
//   void initState() {
//     super.initState();
//     _messages.add({
//       'text':
//           'Hello! I am your SpudTom AI assistant. How can I help you with your plants today?',
//       'isUser': false,
//     });
//   }

//   Future<void> _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty) return;

//     setState(() {
//       _messages.add({'text': text, 'isUser': true});
//       _messageController.clear();
//       _isLoading = true;
//     });

//     final responseText = await _chatService.sendMessage(text);

//     setState(() {
//       _messages.add({
//         'text': responseText,
//         'isUser': false,
//       });
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (route) => false,
//             );
//           },
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFFE8F5E9), Color(0xFFFDFBF7)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   itemCount: _messages.length,
//                   itemBuilder: (context, index) {
//                     final message = _messages[index];
//                     return _buildMessageBubble(
//                       message['text'],
//                       message['isUser'],
//                     );
//                   },
//                 ),
//               ),

//               if (_isLoading)
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: CircularProgressIndicator(
//                     color: AppColors.primaryGreen,
//                   ),
//                 ),

//               _buildInputArea(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageBubble(String text, bool isUser) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 25),
//       child: Column(
//         crossAxisAlignment: isUser
//             ? CrossAxisAlignment.end
//             : CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(
//               bottom: 8,
//               left: isUser ? 0 : 5,
//               right: isUser ? 5 : 0,
//             ),
//             child: isUser
//                 ? const Icon(Icons.person, color: Color(0xFF2E7D32), size: 30)
//                 : Image.asset('assets/ai_logo.png', height: 30),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.82,
//             ),
//             decoration: BoxDecoration(
//               color: const Color(0xFFEAEAEA),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Text(
//               text,
//               style: GoogleFonts.lora(
//                 color: Colors.black87,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputArea() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFFEAEAEA),
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(color: Colors.grey.shade400, width: 1),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _messageController,
//                 style: GoogleFonts.lora(fontSize: 16),
//                 decoration: InputDecoration(
//                   hintText: "Enter Your Message",
//                   hintStyle: GoogleFonts.lora(
//                     color: Colors.grey.shade600,
//                     fontSize: 16,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 18,
//                   ),
//                 ),
//                 onSubmitted: (_) => _sendMessage(),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.send_rounded,
//                   color: Color(0xFF5A5A5A),
//                   size: 28,
//                 ),
//                 onPressed: _sendMessage,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



























import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spudtom/constants/app_colors.dart';
import 'package:spudtom/views/home_screen.dart';
import 'package:spudtom/services/ai_chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // للتحكم في النزول التلقائي
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  final AiChatService _chatService = AiChatService();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // 1. جلب السجل من الذاكرة
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final String key = user != null ? 'chat_history_${user.uid}' : 'chat_history_guest';

    final String? storedChat = prefs.getString(key);
    
    if (storedChat != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(json.decode(storedChat));
      });
      _scrollToBottom();
    } else {
      setState(() {
        _messages.add({
          'text': 'Hello! I am your SpudTom AI assistant. How can I help you with your plants today?',
          'isUser': false,
        });
      });
    }
  }

  // 2. حفظ السجل في الذاكرة
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final String key = user != null ? 'chat_history_${user.uid}' : 'chat_history_guest';
    await prefs.setString(key, json.encode(_messages));
  }

  // 3. مسح الشات بالكامل (زرار في الـ AppBar)
  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final String key = user != null ? 'chat_history_${user.uid}' : 'chat_history_guest';
    await prefs.remove(key);

    setState(() {
      _messages.clear();
      _messages.add({
        'text': 'Hello! I am your SpudTom AI assistant. How can I help you with your plants today?',
        'isUser': false,
      });
    });
  }

  // 4. النزول لآخر رسالة
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _messageController.clear();
      _isLoading = true;
    });
    
    _scrollToBottom();
    await _saveChatHistory();

    // نبعت الرسايل القديمة كلها للموديل ما عدا الأخيرة اللي لسه ضايفينها
    final previousMessages = List<Map<String, dynamic>>.from(_messages)..removeLast();

    final responseText = await _chatService.sendMessage(text, previousMessages);

    setState(() {
      _messages.add({
        'text': responseText,
        'isUser': false,
      });
      _isLoading = false;
    });
    
    _scrollToBottom();
    await _saveChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          // 👇 زرار جديد لمسح السجل لو اليوزر حب يبدأ من الصفر
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onPressed: _clearChat,
            tooltip: "Clear Chat History",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFFDFBF7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // ربطنا السكرول هنا
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(
                      message['text'],
                      message['isUser'],
                    );
                  },
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),

              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 8,
              left: isUser ? 0 : 5,
              right: isUser ? 5 : 0,
            ),
            child: isUser
                ? const Icon(Icons.person, color: Color(0xFF2E7D32), size: 30)
                : Image.asset('assets/ai_logo.png', height: 30),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              text,
              style: GoogleFonts.lora(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.lora(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Enter Your Message",
                  hintStyle: GoogleFonts.lora(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Color(0xFF5A5A5A),
                  size: 28,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}