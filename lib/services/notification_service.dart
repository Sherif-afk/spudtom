import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showAndSaveNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weather_alerts_channel', 'Weather Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notificationsPlugin.show(
      DateTime.now().millisecond, title, body, const NotificationDetails(android: androidDetails)
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      
      final bool isGuest = user == null || user.isAnonymous;
      final String key = isGuest ? 'app_notifications_guest' : 'app_notifications_${user.uid}';

      final String? encodedNotifications = prefs.getString(key); 
      List<dynamic> notifications = encodedNotifications != null ? json.decode(encodedNotifications) : [];

      final now = DateTime.now();
      String period = now.hour >= 12 ? 'PM' : 'AM';
      int hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      String minute = now.minute.toString().padLeft(2, '0');
      String formattedTime = "$hour:$minute $period";

      notifications.insert(0, {
        'title': title,
        'body': body,
        'time': formattedTime, 
        'isRead': false,
      });

      if (notifications.length > 20) {
        notifications = notifications.sublist(0, 20);
      }

      await prefs.setString(key, json.encode(notifications));
      
    } catch (e) {
      debugPrint("Error saving notification: $e");
    }
  }
}