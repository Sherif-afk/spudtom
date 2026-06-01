import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spudtom/constants/app_colors.dart';
import 'package:spudtom/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spudtom/services/notification_service.dart';
import 'package:spudtom/services/weather_service.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.initialize();
    await WeatherService.checkAndNotifyWeatherInBackground();
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.initialize();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "weather_check_task",
    "checkWeatherTask",
    frequency: const Duration(hours: 3),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (FirebaseAuth.instance.currentUser == null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scan_history');
  }

  runApp(const SpudTomApp());
}

class SpudTomApp extends StatelessWidget {
  const SpudTomApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.loraTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.lora(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.lora(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      displaySmall: GoogleFonts.lora(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.lora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.lora(
        fontSize: 26,
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.lora(
        fontSize: 22,
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.lora(
        fontSize: 18,
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.lora(fontSize: 16, color: AppColors.textDark),
      bodyMedium: GoogleFonts.lora(fontSize: 14, color: AppColors.textGrey),
      bodySmall: GoogleFonts.lora(fontSize: 12, color: AppColors.textGrey),
      labelLarge: GoogleFonts.lora(
        fontSize: 14,
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
      ),
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primaryGreen,
          secondary: AppColors.primaryDark,
          surface: AppColors.surface,
          error: AppColors.diseaseRed,
        );

    return MaterialApp(
      title: 'SpudTom',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        canvasColor: AppColors.scaffoldBackground,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: textTheme.titleLarge,
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textDark,
          contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: AppColors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
