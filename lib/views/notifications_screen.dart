import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spudtom/views/home_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  String _getNotificationKey() {
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null || user.isAnonymous;
    return isGuest
        ? 'app_notifications_guest'
        : 'app_notifications_${user.uid}';
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getNotificationKey();
    final String? encoded = prefs.getString(key);

    if (encoded != null) {
      setState(() {
        _notifications = json.decode(encoded);
        _isLoading = false;
      });

      List<dynamic> markedAsRead = _notifications.map((n) {
        n['isRead'] = true;
        return n;
      }).toList();

      await prefs.setString(key, json.encode(markedAsRead));
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearNotifications() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Clear Notifications",
            style: GoogleFonts.lora(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete all notifications?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final String key = _getNotificationKey();

                await prefs.remove(key);

                setState(() {
                  _notifications.clear();
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Notifications cleared successfully",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF2B3A2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 50,
                      left: 50,
                    ),
                    duration: const Duration(seconds: 2),
                    elevation: 0,
                  ),
                );
              },
              child: const Text(
                "Clear All",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ),
          title: Text(
            "Notification",
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            if (_notifications.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.red,
                  size: 28,
                ),
                onPressed: _clearNotifications,
                tooltip: "Clear All Notifications",
              ),
            const SizedBox(width: 10),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF34C759)),
              )
            : _notifications.isEmpty
            ? Center(
                child: Text(
                  "No notifications yet",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return _buildNotificationItem(
                    title: item['title'] ?? 'Alert',
                    body: item['body'] ?? '',
                    time: item['time'] ?? '',
                    isRead: item['isRead'] ?? false,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String body,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: isRead
            ? null
            : Border.all(color: const Color(0xFF34C759), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isRead
                ? Colors.grey[300]
                : const Color(0xFFE8F5E9),
            child: Icon(
              Icons.notifications_active_outlined,
              color: isRead ? Colors.grey[600] : const Color(0xFF34C759),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
