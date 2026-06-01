import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 استدعاء مكتبة الحماية
import 'notification_service.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  static List<String> analyzeCropWeather({
    required double temp,
    required String condition,
    required int humidity,
  }) {
    List<String> alerts = [];
    String lowerCondition = condition.toLowerCase();
    bool isRaining = lowerCondition.contains('rain') || lowerCondition.contains('drizzle') || lowerCondition.contains('shower');

    if (temp >= 35) {
      alerts.add("🍅 Tomato Alert: High temperature (${temp.round()}°C). Risk of blossom drop. Ensure deep watering.");
    } else if (temp <= 10) {
      alerts.add("🍅 Tomato Alert: Cold warning (${temp.round()}°C). Risk of frost damage. Cover young plants!");
    }

    if (temp >= 28 && temp < 35) {
      alerts.add("🥔 Potato Alert: Warm temperatures (${temp.round()}°C) may halt tuber growth. Keep soil moist.");
    }

    if (isRaining || humidity > 80) {
      alerts.add("🌧️ Fungal Risk: High moisture detected. Check plants for Late Blight. Avoid overhead watering.");
    }

    return alerts;
  }

  static Future<Map<String, double>> _getSafeLocation() async {
    double lat = 30.0444;
    double lon = 31.2357;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 3),
          );
          lat = position.latitude;
          lon = position.longitude;
        }
      }
    } catch (e) {
      debugPrint("GPS Timeout or Error. Using Fallback (Cairo): $e");
    }

    return {'lat': lat, 'lon': lon};
  }

  static Future<void> checkAndNotifyWeather(BuildContext context) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint("❌ Weather API Key is missing in .env file!");
        return;
      }

      final loc = await _getSafeLocation();
      final url = 'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${loc['lat']},${loc['lon']}';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double temp = data['current']['temp_c'].toDouble();
        String condition = data['current']['condition']['text'];
        int humidity = data['current']['humidity'];

        List<String> alerts = analyzeCropWeather(temp: temp, condition: condition, humidity: humidity);

        for (String alert in alerts) {
           String title = 'SpudTom Alert 🚨';
           if (alert.contains('🍅')) title = 'Tomato Alert 🍅';
           if (alert.contains('🥔')) title = 'Potato Alert 🥔';
           if (alert.contains('🌧️')) title = 'Fungal Risk 🌧️';

          _triggerAlerts(context, title, alert);
        }
      }
    } catch (e) {
      debugPrint("Weather API Exception: $e");
    }
  }

  static void _triggerAlerts(BuildContext context, String title, String message) {
    NotificationService.showAndSaveNotification(title: title, body: message);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  static Future<void> checkAndNotifyWeatherInBackground() async {
    try {
      if (_apiKey.isEmpty) return;

      final loc = await _getSafeLocation();
      final url = 'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${loc['lat']},${loc['lon']}';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double temp = data['current']['temp_c'].toDouble();
        String condition = data['current']['condition']['text'];
        int humidity = data['current']['humidity'];

        List<String> alerts = analyzeCropWeather(temp: temp, condition: condition, humidity: humidity);

        for (String alert in alerts) {
           String title = 'SpudTom Alert 🚨';
           if (alert.contains('🍅')) title = 'Tomato Alert 🍅';
           if (alert.contains('🥔')) title = 'Potato Alert 🥔';
           if (alert.contains('🌧️')) title = 'Fungal Risk 🌧️';

          await NotificationService.showAndSaveNotification(title: title, body: alert);
        }
      }
    } catch (e) {
      debugPrint("Weather API Background Exception: $e");
    }
  }

  static Future<Map<String, dynamic>?> fetchCurrentWeatherForUI() async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint("❌ Weather API Key is missing in .env file!");
        return null;
      }

      final loc = await _getSafeLocation();
      final url = 'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${loc['lat']},${loc['lon']}';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        double temp = data['current']['temp_c'].toDouble();
        String condition = data['current']['condition']['text'];
        int humidity = data['current']['humidity'];

        List<String> cropAlerts = analyzeCropWeather(
          temp: temp,
          condition: condition,
          humidity: humidity,
        );

        data['crop_alerts'] = cropAlerts;

        for (String alert in cropAlerts) {
          String title = 'SpudTom Alert 🚨';
          if (alert.contains('🍅')) title = 'Tomato Alert 🍅';
          if (alert.contains('🥔')) title = 'Potato Alert 🥔';
          if (alert.contains('🌧️')) title = 'Fungal Risk 🌧️';

          await NotificationService.showAndSaveNotification(title: title, body: alert);
        }

        return data; 
      }
    } catch (e) {
      debugPrint("Fetch Weather UI Exception: $e");
    }
    return null;
  }
}