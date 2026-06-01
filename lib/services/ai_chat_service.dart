// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class AiChatService {
//   static const String _apiKey = ''; 
  
//   static const String _url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

//   final List<Map<String, dynamic>> _chatHistory = [];

//   AiChatService() {
//     debugPrint('✅ SpudTom AI: Connected via HTTP Direct API (Gemini 2.5 Flash).');
//   }

//   Future<String> sendMessage(String message, List<Map<String, dynamic>> previousMessages) async {
//     try {
//       _chatHistory.add({
//         "role": "user",
//         "parts": [{"text": message}]
//       });

//       final response = await http.post(
//         Uri.parse(_url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "system_instruction": {
//             "parts": [
//               {
//                 "text": "You are SpudTom AI, a world-class agricultural expert assistant specializing in tomato and potato crops. Provide helpful, accurate, friendly, and concise advice to farmers about plant diseases, irrigation, soil health, and general plant care. Respond in the same language the user uses (Arabic or English)."
//               }
//             ]
//           },
//           "contents": _chatHistory,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final botReply = data['candidates'][0]['content']['parts'][0]['text'];
        
//         _chatHistory.add({
//           "role": "model",
//           "parts": [{"text": botReply}]
//         });

//         return botReply;
//       } else {
//         debugPrint('❌ HTTP API Error: ${response.body}');
//         _chatHistory.removeLast(); 
//         return 'API Error: ${response.statusCode}. Please try again.';
//       }
//     } catch (e) {
//       debugPrint('❌ HTTP Exception: $e');
//       if (_chatHistory.isNotEmpty) _chatHistory.removeLast();
//       return 'Error connecting to the server. Please check your internet connection.';
//     }
//   }
// }




















import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 استدعاء مكتبة الحماية

class AiChatService {
  // 👇 قراءة المفتاح السري بأمان من ملف .env
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 
  
  // استخدام الموديل المستقر 2.5-flash
  static final String _url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

  AiChatService() {
    debugPrint('✅ SpudTom AI: Connected via HTTP Direct API (Gemini 2.5 Flash).');
  }

  // الدالة بتاخد الرسايل القديمة عشان تفهم سياق الكلام
  Future<String> sendMessage(String message, List<Map<String, dynamic>> previousMessages) async {
    try {
      // التأكد من وجود المفتاح
      if (_apiKey.isEmpty) {
        debugPrint('❌ SpudTom AI: API Key is missing in .env file!');
        return 'Configuration Error: API Key not found.';
      }

      List<Map<String, dynamic>> geminiHistory = [];
      String lastRole = "";

      // فلترة وتجهيز الرسايل القديمة لصيغة جوجل
      for (var msg in previousMessages) {
        // بنتجاهل رسالة الترحيب الأولى عشان متعملش لغبطة
        if (msg['text'].toString().contains('Hello! I am your SpudTom AI')) continue;
        
        String currentRole = msg['isUser'] ? "user" : "model";

        // سيرفر جوجل بيرفض لو في رسالتين ورا بعض من نفس الشخص، فبنتأكد إنهم بالتبادل
        if (currentRole == lastRole) continue; 

        geminiHistory.add({
          "role": currentRole,
          "parts": [{"text": msg['text']}]
        });
        lastRole = currentRole;
      }

      // لو آخر رسالة في السجل المفلتر كانت من اليوزر، بنشيلها عشان هنضيف الجديدة دلوقتي
      if (geminiHistory.isNotEmpty && geminiHistory.last['role'] == 'user') {
        geminiHistory.removeLast();
      }

      // إضافة رسالة المستخدم الجديدة
      geminiHistory.add({
        "role": "user",
        "parts": [{"text": message}]
      });

      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "system_instruction": {
            "parts": [
              {
                "text": "You are SpudTom AI, a world-class agricultural expert assistant specializing in tomato and potato crops. Provide helpful, accurate, friendly, and concise advice to farmers about plant diseases, irrigation, soil health, and general plant care. Respond in the same language the user uses (Arabic or English)."
              }
            ]
          },
          "contents": geminiHistory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        debugPrint('❌ HTTP API Error: ${response.body}');
        return 'API Error: ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      debugPrint('❌ HTTP Exception: $e');
      return 'Error connecting to the server. Please check your internet connection.';
    }
  }
}