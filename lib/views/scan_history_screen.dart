import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spudtom/views/home_screen.dart';
import 'package:spudtom/views/diagnose_result_screen.dart';
import 'package:spudtom/views/growth_progress_screen.dart';

class ScanHistoryScreen extends StatefulWidget {
  final bool showScaffold;
  const ScanHistoryScreen({super.key, this.showScaffold = true});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      final user = FirebaseAuth.instance.currentUser;
      final String userKey = user != null
          ? 'scan_history_${user.uid}'
          : 'scan_history';

      final String? historyString = prefs.getString(userKey);

      if (historyString != null) {
        final List<dynamic> decodedData = json.decode(historyString);

        final List<Map<String, dynamic>> uniqueHistory = [];
        final Set<String> seenRecords = {};

        for (var item in decodedData) {
          final String recordSignature =
              "${item['title']}_${item['date']}_${item['time']}";

          if (!seenRecords.contains(recordSignature)) {
            seenRecords.add(recordSignature);
            uniqueHistory.add(Map<String, dynamic>.from(item));
          }
        }

        await prefs.setString(userKey, json.encode(uniqueHistory));

        setState(() {
          _historyData = uniqueHistory;
        });
      } else {
        setState(() => _historyData = []);
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            "Clear History",
            style: GoogleFonts.lora(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete all scan records?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                final user = FirebaseAuth.instance.currentUser;
                final String userKey = user != null
                    ? 'scan_history_${user.uid}'
                    : 'scan_history';

                await prefs.remove(userKey);

                setState(() {
                  _historyData = [];
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "History cleared successfully",
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
    Widget content = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Scan History",
                      style: GoogleFonts.lora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (_historyData.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: _clearHistory,
                    tooltip: "Clear All History",
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Recent History",
                  style: GoogleFonts.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Container(height: 1.5, width: 150, color: Colors.black87),
                const SizedBox(height: 20),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : _historyData.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: _historyData.length,
                    itemBuilder: (context, index) {
                      final item = _historyData[index];
                      return _buildHistoryCard(item);
                    },
                  ),
          ),
        ],
      ),
    );

    return _wrapWithScaffold(content);
  }

  Widget _wrapWithScaffold(Widget content) {
    if (widget.showScaffold) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(backgroundColor: Colors.transparent, body: content),
      );
    }
    return Scaffold(backgroundColor: Colors.transparent, body: content);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            "No Scan History Yet",
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Your plant diagnosis results\nwill appear here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        if (data['title'] == 'Growth Update') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GrowthProgressScreen(),
            ),
          ).then((_) {
            _loadHistory();
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiagnoseResultScreen(
                result:
                    data['full_result'] ??
                    {
                      'diagnosis': data['title'],
                      'risk_level': data['status'] == 'danger'
                          ? 'severe'
                          : (data['status'] == 'warning' ? 'moderate' : 'safe'),
                      'severity': data['percentage'],
                      'treatment':
                          "Detailed treatment plan is not available in older history records. Please scan again for full instructions.",
                    },
                fromHistory: true,
              ),
            ),
          ).then((_) {
            _loadHistory();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            _buildStatusIcon(data['status'] ?? 'safe'),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Unknown',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${data['plant']} · ${data['time']}",
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    data['date'] ?? '',
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              data['percentage'] ?? '',
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    if (status == 'danger') {
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (status == 'warning') {
      icon = Icons.error_outline;
      color = Colors.orange;
    } else {
      icon = Icons.check_circle_outline;
      color = Colors.green;
    }
    return Icon(icon, color: color, size: 30);
  }
}
