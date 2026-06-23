import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spudtom/services/ml_service.dart';
import 'package:spudtom/views/home_screen.dart';

class GrowthProgressScreen extends StatefulWidget {
  const GrowthProgressScreen({super.key});

  @override
  State<GrowthProgressScreen> createState() => _GrowthProgressScreenState();
}

class _GrowthProgressScreenState extends State<GrowthProgressScreen> {
  List<Map<String, dynamic>> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final String key = user != null
          ? 'growth_plants_${user.uid}'
          : 'growth_plants_guest';

      final String? dataString = prefs.getString(key);
      if (dataString != null) {
        setState(() {
          _plants = List<Map<String, dynamic>>.from(json.decode(dataString));
        });
      }
    } catch (e) {
      debugPrint("Error loading plants: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePlants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final String key = user != null
          ? 'growth_plants_${user.uid}'
          : 'growth_plants_guest';
      await prefs.setString(key, json.encode(_plants));
    } catch (e) {
      debugPrint("Error saving plants: $e");
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Text(
          "Delete Plant",
          style: GoogleFonts.lora(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove '${_plants[index]['name']}'?",
          style: GoogleFonts.lora(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _plants.removeAt(index));
              _savePlants();
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllPlants() {
    if (_plants.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Text(
          "Clear All Data",
          style: GoogleFonts.lora(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "This will delete all tracked plants.",
          style: GoogleFonts.lora(color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _plants.clear());
              _savePlants();
              Navigator.pop(context);
            },
            child: Text(
              "Clear All",
              style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(int index) {
    final TextEditingController editNameController =
        TextEditingController(text: _plants[index]['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3F5EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            "Edit Plant Name",
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3A2C),
            ),
          ),
          content: TextField(
            controller: editNameController,
            decoration: InputDecoration(
              hintText: "Enter New Plant Name",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (editNameController.text.trim().isNotEmpty) {
                  setState(() {
                    _plants[index]['name'] = editNameController.text.trim();
                  });
                  _savePlants();
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Save",
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF34C759),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updatePlantImage(int index) {
    final ImagePicker picker = ImagePicker();

    Future<void> processUpdateImage(ImageSource source) async {
      Navigator.pop(context);

      try {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 256,
          maxHeight: 256,
          imageQuality: 100,
        );

        if (image != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );

          final directory = await getApplicationDocumentsDirectory();
          final String newPath =
              '${directory.path}/growth_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final File permanentImage = await File(image.path).copy(newPath);

          var result = await MLService.uploadImageForGrowth(permanentImage);

          if (mounted) Navigator.pop(context);

          if (result != null && result['status'] != 'error') {
            setState(() {
              _plants[index]['image_path'] = permanentImage.path;
              _plants[index]['result'] = result;
              _plants[index]['last_analysis_date'] = DateTime.now()
                  .toIso8601String();
            });
            _savePlants();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Plant updated successfully",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF34C759),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                margin: const EdgeInsets.only(bottom: 20, right: 50, left: 50),
                duration: const Duration(seconds: 2),
                elevation: 0,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${result?['message'] ?? 'Failed to update'}',
                ),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 15),
                  child: Text(
                    "Update Plant Status",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF34C759),
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.lora(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => processUpdateImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF34C759),
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.lora(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => processUpdateImage(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPlantDialog() {
    final TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    File? tempImage;
    bool isUploading = false;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF3F5EC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              title: Text(
                "Track New Plant",
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B3A2C),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter Plant Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF34C759),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setDialogState(() => selectedDate = pickedDate);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Planting Date",
                                  style: GoogleFonts.lora(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(selectedDate),
                                  style: GoogleFonts.lora(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () async {
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 256,
                          maxHeight: 256,
                        );
                        if (pickedFile != null) {
                          setDialogState(() {
                            tempImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: tempImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  tempImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.grey.shade400,
                                    size: 35,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Add Photo (Optional)",
                                    style: GoogleFonts.lora(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Plant name is required!',
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                  right: 50,
                                  left: 50,
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isUploading = true);

                          Map<String, dynamic>? result = {};
                          String finalImagePath = "";

                          if (tempImage != null) {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            final String newPath =
                                '${directory.path}/growth_${DateTime.now().millisecondsSinceEpoch}.jpg';
                            final File permanentImage = await tempImage!.copy(
                              newPath,
                            );
                            finalImagePath = permanentImage.path;

                            result = await MLService.uploadImageForGrowth(
                              permanentImage,
                            );
                          }

                          setState(() {
                            _plants.insert(0, {
                              'id': DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              'name': nameController.text.trim(),
                              'date': DateFormat(
                                'dd MMM yyyy',
                              ).format(selectedDate),
                              'raw_date': selectedDate.toIso8601String(),
                              'image_path': finalImagePath,
                              'result': result,
                              'last_analysis_date': tempImage != null
                                  ? DateTime.now().toIso8601String()
                                  : selectedDate.toIso8601String(),
                            });
                          });

                          await _savePlants();
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF34C759),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Save",
                          style: GoogleFonts.lora(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                ),
              ],
            );
          },
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          title: Text(
            "Growth Progress",
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          actions: [
            if (_plants.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.redAccent,
                  size: 28,
                ),
                onPressed: _clearAllPlants,
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: _showAddPlantDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF34C759),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF34C759),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Track New Plant",
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                    : _plants.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 50,
                          left: 20,
                          right: 20,
                        ),
                        itemCount: _plants.length,
                        itemBuilder: (context, index) {
                          return _buildPlantCard(_plants[index], index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_florist_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            "No Plants Tracked",
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add a plant to monitor\nits growth progress.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant, int index) {
    final result = plant['result'] ?? {};
    final String status = result['status'] ?? 'Growing';
    bool hasImage =
        plant['image_path'] != null &&
        plant['image_path'].toString().isNotEmpty &&
        File(plant['image_path']).existsSync();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrowthDetailScreen(plantData: plant),
          ),
        ).then((_) {
          // تحديث الشاشة بعد الرجوع لو حصل تعديل جوا الشاشة
          setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? Image.file(
                      File(plant['image_path']),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.eco, color: Colors.green),
                    ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant['name'] ?? 'Unknown Plant',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Planted: ${plant['date']}",
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Status: $status",
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF34C759),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () => _showEditNameDialog(index),
                  tooltip: "Edit Plant Name",
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF34C759),
                  ),
                  onPressed: () => _updatePlantImage(index),
                  tooltip: "Update Photo & Status",
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(index),
                  tooltip: "Delete Plant",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GrowthDetailScreen extends StatelessWidget {
  final Map<String, dynamic> plantData;

  const GrowthDetailScreen({super.key, required this.plantData});

  Map<String, dynamic> _calculateHarvestData() {
    try {
      final result = plantData['result'] ?? {};
      final String rawDateStr = plantData['raw_date'] ?? "";

      if (rawDateStr.isEmpty) {
        return {
          "text": "Date Error",
          "color": Colors.grey,
          "isDone": false,
          "dynamic_rate": "0%",
          "dynamic_stage": "Unknown",
        };
      }

      double mlGrowth =
          double.tryParse(result['growth_rate']?.toString() ?? "0") ?? 0;

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      DateTime startDate = DateTime.parse(rawDateStr);
      DateTime startDay = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      String analysisDateStr = plantData['last_analysis_date'] ?? rawDateStr;
      DateTime analysisDate = DateTime.parse(analysisDateStr);
      DateTime analysisDay = DateTime(
        analysisDate.year,
        analysisDate.month,
        analysisDate.day,
      );

      int daysToAnalysis = analysisDay.difference(startDay).inDays;
      if (daysToAnalysis <= 0) daysToAnalysis = 1;

      double growthPerDayAtAnalysis = mlGrowth / daysToAnalysis;

      int predictedTotalDays =
          (100 / (growthPerDayAtAnalysis > 0 ? growthPerDayAtAnalysis : 1.42))
              .round();
      if (predictedTotalDays < 70) predictedTotalDays = 70;
      if (predictedTotalDays > 110) predictedTotalDays = 110;

      double realDailyGrowth = 100.0 / predictedTotalDays;

      int daysSinceAnalysis = today.difference(analysisDay).inDays;
      if (daysSinceAnalysis < 0) daysSinceAnalysis = 0;

      double currentDynamicGrowth =
          mlGrowth + (daysSinceAnalysis * realDailyGrowth);
      if (currentDynamicGrowth > 100) currentDynamicGrowth = 100;

      DateTime targetDate = startDay.add(Duration(days: predictedTotalDays));
      int daysLeft = targetDate.difference(today).inDays;

      if (daysLeft < 0) daysLeft = 0;

      String formattedGrowth = currentDynamicGrowth.toStringAsFixed(1);
      if (formattedGrowth.endsWith('.0')) {
        formattedGrowth = formattedGrowth.substring(
          0,
          formattedGrowth.length - 2,
        );
      }
      String dynamicRateStr = "$formattedGrowth%";

      String dynamicStage = "Green Stage";
      if (currentDynamicGrowth < 25) {
        dynamicStage = "Green Stage";
      } else if (currentDynamicGrowth >= 25 && currentDynamicGrowth < 50) {
        dynamicStage = "Breaker/Turning";
      } else if (currentDynamicGrowth >= 50 && currentDynamicGrowth < 80) {
        dynamicStage = "Orange/Light Red";
      } else {
        dynamicStage = "Mature Red";
      }
      if (currentDynamicGrowth >= 100 || daysLeft <= 0) {
        return {
          "text": "Ready for Harvest! 🍅",
          "color": Colors.redAccent,
          "isDone": true,
          "dynamic_rate": "100%",
          "dynamic_stage": "Harvest Ready",
        };
      }

      Color statusColor = daysLeft > 14
          ? const Color(0xFF34C759)
          : (daysLeft > 7 ? Colors.orange : Colors.redAccent);

      return {
        "text":
            "${DateFormat('dd MMM yyyy').format(targetDate)}\n($daysLeft Days Remaining)",
        "color": statusColor,
        "isDone": false,
        "dynamic_rate": dynamicRateStr,
        "dynamic_stage": dynamicStage,
      };
    } catch (e) {
      return {
        "text": "Add photo to predict",
        "color": Colors.blue,
        "isDone": false,
        "dynamic_rate": "0%",
        "dynamic_stage": "Unknown",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = plantData['result'] ?? {};
    final harvest = _calculateHarvestData();

    final String rate = harvest['dynamic_rate'] ?? "0%";
    final String stage =
        harvest['dynamic_stage'] ??
        result['growth_stage']?.toString() ??
        "Planted";
    final String health = result['health_score'] != null
        ? "${result['health_score']}%"
        : "0%";

    bool hasImage =
        plantData['image_path'] != null &&
        plantData['image_path'].toString().isNotEmpty &&
        File(plantData['image_path']).existsSync();
    final File? imageFile = hasImage ? File(plantData['image_path']) : null;

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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            plantData['name'] ?? "Plant Details",
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                  image: imageFile != null
                      ? DecorationImage(
                          image: FileImage(imageFile),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: imageFile == null
                    ? const Center(
                        child: Icon(
                          Icons.eco,
                          size: 50,
                          color: Color(0xFF34C759),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Added on ${plantData['date']}",
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              if (hasImage) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: harvest['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: harvest['color'], width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            harvest['isDone']
                                ? Icons.shopping_basket_rounded
                                : Icons.hourglass_bottom_rounded,
                            color: harvest['color'],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "AI Harvest Prediction",
                            style: TextStyle(
                              color: harvest['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        harvest['text'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: harvest['color'],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _buildMonitorCard("Growth Progress", rate),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallCard(
                      "Growth Stage",
                      stage,
                      Icons.grass_rounded,
                      isStatus: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSmallCard(
                      "Health Score",
                      health,
                      Icons.favorite_rounded,
                      hasProgress: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonitorCard(String title, String value) {
    double progress = double.tryParse(value.replaceAll('%', '')) ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF34C759)),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF34C759),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(
    String title,
    String value,
    IconData icon, {
    bool isStatus = false,
    bool hasProgress = false,
  }) {
    double progress = double.tryParse(value.replaceAll('%', '')) ?? 0;
    return Container(
      height: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isStatus ? const Color(0xFF34C759) : Colors.black,
            ),
          ),
          if (hasProgress) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF34C759),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}