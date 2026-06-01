import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spudtom/constants/app_colors.dart';
import 'package:spudtom/services/weather_service.dart';
import 'package:spudtom/views/growth_progress_screen.dart';
import 'package:spudtom/views/plant_care_tips_screen.dart';
import 'package:spudtom/views/scan_history_screen.dart';
import 'package:spudtom/views/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onChangeTab,
    required this.showScaffold,
    required this.onOpenNotifications,
  });

  final ValueChanged<int>? onChangeTab;
  final bool showScaffold;
  final void Function() onOpenNotifications;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _firstName = '';
  String _temperature = '--';
  String _weatherCondition = 'Loading';
  bool _isLoadingWeather = true;
  int _notificationCount = 0;
  String? _profileImagePath;

  static bool _isGuestSessionCleared = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadWeatherData();
    _loadNotificationCount();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'profile_image_${user.uid}';
      setState(() {
        _profileImagePath = prefs.getString(key);
      });
    } catch (e) {
      debugPrint("Error loading profile image in Dashboard: $e");
    }
  }

  Future<void> _loadNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      final bool isGuest = user == null || user.isAnonymous;
      final String key = isGuest
          ? 'app_notifications_guest'
          : 'app_notifications_${user.uid}';

      if (isGuest && !_isGuestSessionCleared) {
        await prefs.remove(key);
        _isGuestSessionCleared = true;
      }

      final String? notificationsString = prefs.getString(key);

      if (notificationsString != null) {
        final List<dynamic> decodedData = json.decode(notificationsString);
        int unreadCount = decodedData
            .where((n) => n['isRead'] == false || n['isRead'] == null)
            .length;

        setState(() {
          _notificationCount = unreadCount;
        });
      } else {
        setState(() {
          _notificationCount = 0;
        });
      }
    } catch (e) {
      debugPrint("Error loading notifications count: $e");
    }
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          _firstName = user.displayName!.split(' ')[0];
        } else {
          _firstName = '';
        }
      });
    }
  }

  Future<void> _loadWeatherData() async {
    final weatherData = await WeatherService.fetchCurrentWeatherForUI();
    if (mounted) {
      setState(() {
        if (weatherData != null) {
          _temperature = weatherData['current']['temp_c'].round().toString();
          _weatherCondition = weatherData['current']['condition']['text'];
        } else {
          _temperature = "N/A";
          _weatherCondition = "Error";
        }
        _isLoadingWeather = false;
      });
    }
  }

  Widget _getWeatherIcon(String condition) {
    String lowerCondition = condition.toLowerCase();

    if (lowerCondition.contains('partly cloudy') ||
        lowerCondition.contains('mostly sunny')) {
      return const Icon(
        Icons.cloud_queue,
        color: Colors.orangeAccent,
        size: 16,
      );
    } else if (lowerCondition.contains('clear') ||
        lowerCondition.contains('sunny')) {
      return const Icon(Icons.wb_sunny, color: Colors.orange, size: 16);
    } else if (lowerCondition.contains('cloud') ||
        lowerCondition.contains('overcast')) {
      return const Icon(Icons.cloud, color: Colors.blueGrey, size: 16);
    } else if (lowerCondition.contains('rain') ||
        lowerCondition.contains('drizzle') ||
        lowerCondition.contains('shower')) {
      return const Icon(Icons.water_drop, color: Colors.lightBlue, size: 16);
    } else if (lowerCondition.contains('snow')) {
      return const Icon(Icons.ac_unit, color: Colors.lightBlueAccent, size: 16);
    } else if (lowerCondition.contains('thunder') ||
        lowerCondition.contains('storm')) {
      return const Icon(Icons.flash_on, color: Colors.deepPurple, size: 16);
    } else if (lowerCondition.contains('fog') ||
        lowerCondition.contains('mist')) {
      return const Icon(Icons.foggy, color: Colors.grey, size: 16);
    } else {
      return const Icon(Icons.wb_cloudy_outlined, color: Colors.grey, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onChangeTab != null) {
                      widget.onChangeTab!(4);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFE0E0E0),
                      backgroundImage:
                          _profileImagePath != null &&
                              File(_profileImagePath!).existsSync()
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child:
                          (_profileImagePath == null ||
                              !File(_profileImagePath!).existsSync())
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 30,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _firstName.isEmpty ? 'Welcome!' : 'Welcome, $_firstName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    ).then((_) {
                      _loadNotificationCount();
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      if (_notificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _notificationCount > 9
                                  ? '10+'
                                  : '$_notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            GestureDetector(
              onTap: () {
                WeatherService.checkAndNotifyWeather(context).then((_) {
                  _loadNotificationCount();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EBE0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoadingWeather
                        ? const Icon(Icons.sync, color: Colors.grey, size: 16)
                        : _getWeatherIcon(_weatherCondition),
                    const SizedBox(width: 5),
                    _isLoadingWeather
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange,
                            ),
                          )
                        : Text(
                            '$_temperature°C, $_weatherCondition',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Action',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Container(height: 2, width: 125, color: AppColors.textDark),
              ],
            ),
            const SizedBox(height: 25),

            _buildActionCard(
              title: 'Scan History',
              subtitle: 'View past Results',
              icon: Icons.history,
              bgColor: AppColors.primaryGreen,
              textColor: Colors.white,
              iconBgColor: Colors.white.withOpacity(0.2),
              iconColor: Colors.white,
              onTap: () {
                if (widget.onChangeTab != null) {
                  widget.onChangeTab!(3);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanHistoryScreen(),
                    ),
                  );
                }
              },
            ),

            _buildActionCard(
              title: 'Growth Progress',
              subtitle: 'View Leaf States',
              icon: Icons.trending_up,
              bgColor: Colors.white,
              textColor: AppColors.textDark,
              iconBgColor: const Color(0xFFF5EFE7),
              iconColor: AppColors.primaryGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GrowthProgressScreen(),
                  ),
                );
              },
            ),

            _buildActionCard(
              title: 'Plant Care Tips',
              subtitle: 'Health life for plants',
              icon: Icons.local_florist,
              bgColor: Colors.white,
              textColor: AppColors.textDark,
              iconBgColor: const Color(0xFFF5EFE7),
              iconColor: Colors.orange[300]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlantCareTipsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor == Colors.white
                        ? Colors.white70
                        : AppColors.textGrey,
                  ),
                ),
              ],
            ),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
