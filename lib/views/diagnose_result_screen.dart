import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spudtom/views/camera_screen.dart';
import 'package:spudtom/views/home_screen.dart';

class DiagnoseResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final bool fromHistory;

  const DiagnoseResultScreen({
    super.key,
    required this.result,
    this.fromHistory = false,
  });

  @override
  State<DiagnoseResultScreen> createState() => _DiagnoseResultScreenState();
}

class _DiagnoseResultScreenState extends State<DiagnoseResultScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.fromHistory) {
      _saveDiagnosisToHistory();
    }
  }

  Future<void> _saveDiagnosisToHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String diagnosis = widget.result['diagnosis'] ?? 'Unknown Disease';
      final String severity = widget.result['severity'] ?? '0%';
      final String riskLevel = widget.result['risk_level'] ?? 'safe';

      final user = FirebaseAuth.instance.currentUser;
      final String userKey = user != null
          ? 'scan_history_${user.uid}'
          : 'scan_history';

      final String? historyString = prefs.getString(userKey);
      List<dynamic> historyList = historyString != null
          ? json.decode(historyString)
          : [];

      Map<String, dynamic> newRecord = {
        'title': diagnosis,
        'plant': "Tomato / Potato",
        'percentage': severity,
        'status': _getStatusKey(riskLevel),
        'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
        'time': DateFormat('hh:mm a').format(DateTime.now()),
        'full_result': widget.result,
      };

      historyList.insert(0, newRecord);

      await prefs.setString(userKey, json.encode(historyList));
      debugPrint("✅ Diagnosis saved to history");
    } catch (e) {
      debugPrint("❌ Error saving to history: $e");
    }
  }

  String _getStatusKey(String risk) {
    if (risk.toLowerCase() == 'severe') return 'danger';
    if (risk.toLowerCase() == 'moderate') return 'warning';
    return 'safe';
  }

  String capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  String _formatTreatment(dynamic rawTreatment) {
    if (rawTreatment == null) return "No treatment plan available.";
    if (rawTreatment is String) return rawTreatment;
    if (rawTreatment is Map) {
      String formatted = "";
      final List<dynamic> pesticides = rawTreatment['pesticides'] ?? [];
      final List<dynamic> homeRemedies = rawTreatment['home_remedies'] ?? [];
      final String application = rawTreatment['application'] ?? '';
      final String duration = rawTreatment['duration'] ?? '';

      if (pesticides.isNotEmpty) {
        formatted += "Pesticides:\n• ${pesticides.join('\n• ')}\n\n";
      }
      if (homeRemedies.isNotEmpty) {
        formatted += "Home Remedies:\n• ${homeRemedies.join('\n• ')}\n\n";
      }
      if (application.isNotEmpty && application != 'No instructions specified.') {
        formatted += "Application:\n$application\n\n";
      }
      if (duration.isNotEmpty && duration != 'No duration specified.') {
        formatted += "Duration:\n$duration";
      }

      return formatted.trim().isEmpty
          ? "No specific treatment plan provided."
          : formatted.trim();
    }
    return "No treatment plan available.";
  }

  @override
  Widget build(BuildContext context) {
    final String diagnosis = widget.result['diagnosis'] ?? 'Unknown Disease';
    final String riskLevel = capitalize(
      widget.result['risk_level'] ?? 'Unknown',
    );
    final String severity = widget.result['severity'] ?? 'N/A';
    final String formattedTreatmentText = _formatTreatment(
      widget.result['treatment'],
    );

    Color riskBgColor = riskLevel.toLowerCase() == 'severe'
        ? const Color(0xFFFADCDC)
        : (riskLevel.toLowerCase() == 'moderate'
              ? const Color(0xFFFDE8C4)
              : const Color(0xFFD4F3DD));
    Color riskTextColor = riskLevel.toLowerCase() == 'severe'
        ? const Color(0xFFC44A4A)
        : (riskLevel.toLowerCase() == 'moderate'
              ? const Color(0xFFC78222)
              : const Color(0xFF2E7D32));
    IconData mainIcon = riskLevel.toLowerCase() == 'safe'
        ? Icons.eco_rounded
        : Icons.coronavirus_rounded;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6ED),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Diagnose Result",
                        style: GoogleFonts.lora(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(mainIcon, color: riskTextColor, size: 55),
                        const SizedBox(height: 15),
                        Text(
                          diagnosis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: riskTextColor,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPillBadge(
                              "Risk",
                              riskLevel,
                              riskBgColor,
                              riskTextColor,
                            ),
                            _buildPillBadge(
                              "Severity",
                              severity,
                              const Color(0xFFFDF5CC),
                              const Color(0xFFA48520),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Treatment Plan",
                    style: GoogleFonts.lora(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      formattedTreatmentText,
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  ),
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: Text(
                    "Scan New Plant",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.3), width: 1),
          ),
          child: Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
