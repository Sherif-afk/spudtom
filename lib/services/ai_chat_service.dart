import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 
  static final String _url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

  AiChatService() {
    debugPrint('✅ SpudTom AI: Connected via HTTP Direct API (Gemini 2.5 Flash).');
  }

  Future<String> sendMessage(String message, List<Map<String, dynamic>> previousMessages) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('❌ SpudTom AI: API Key is missing in .env file!');
        return 'Configuration Error: API Key not found.';
      }

      List<Map<String, dynamic>> geminiHistory = [];
      String lastRole = "";

      for (var msg in previousMessages) {
        if (msg['text'].toString().contains('Hello! I am your SpudTom AI')) continue;
        
        String currentRole = msg['isUser'] ? "user" : "model";

        if (currentRole == lastRole) continue; 

        geminiHistory.add({
          "role": currentRole,
          "parts": [{"text": msg['text']}]
        });
        lastRole = currentRole;
      }

      if (geminiHistory.isNotEmpty && geminiHistory.last['role'] == 'user') {
        geminiHistory.removeLast();
      }

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