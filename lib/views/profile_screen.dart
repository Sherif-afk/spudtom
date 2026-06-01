import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spudtom/constants/app_colors.dart';
import 'package:spudtom/views/home_screen.dart';
import 'package:spudtom/views/login_screen.dart';
import 'package:spudtom/views/signup_screen.dart';
import 'package:spudtom/views/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.showScaffold});

  final bool showScaffold;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      setState(() => _imagePath = null);
      return;
    }

    final String key = 'profile_image_${user.uid}';
    setState(() {
      _imagePath = prefs.getString(key);
    });
  }

  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();

        final String newPath =
            '${directory.path}/profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.png';

        final File permanentFile = await File(pickedFile.path).copy(newPath);

        final prefs = await SharedPreferences.getInstance();
        final String key = 'profile_image_${user.uid}';

        await prefs.setString(key, permanentFile.path);

        setState(() {
          _imagePath = permanentFile.path;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoUrl': permanentFile.path});
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _deleteImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'profile_image_${user.uid}';

      await prefs.remove(key);

      setState(() {
        _imagePath = null;
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'photoUrl': FieldValue.delete()},
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error deleting image: $e");
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF34C759),
                ),
                title: Text(
                  'Pick from Gallery',
                  style: GoogleFonts.lora(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_imagePath != null && File(_imagePath!).existsSync())
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Current Photo',
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: _deleteImage,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in");

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            "Logout",
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.lora(color: Colors.grey.shade700, fontSize: 16),
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('scan_history_guest');
                await prefs.remove('app_notifications_guest');
                await prefs.remove('profile_image_guest');
                await prefs.remove('growth_plants_guest');

                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Text(
                "Logout",
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
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
          title: Text(
            "Profile",
            style: GoogleFonts.lora(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildGuestOrErrorUI(context);
            }

            final data = snapshot.data!.data()!;
            final fullName = data['fullName'] ?? 'User';
            final email =
                FirebaseAuth.instance.currentUser?.email ?? 'No Email';
            final phone = data['phoneNumber'] ?? 'Not set';

            String memberSince = "Unknown";
            if (data['memberSince'] != null) {
              DateTime date = (data['memberSince'] as Timestamp).toDate();
              memberSince = "${date.day}\\${date.month}\\${date.year}";
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAvatarSection(fullName, email, isGuest: false),
                  const SizedBox(height: 30),
                  _buildInfoCard(fullName, email, phone, memberSince),
                  const SizedBox(height: 20),
                  _buildSettingsCard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    String name,
    String email, {
    bool isGuest = false,
  }) {
    bool hasImage =
        !isGuest && _imagePath != null && File(_imagePath!).existsSync();

    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 3.0),
              ),
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFC4C4C4),
                backgroundImage: hasImage ? FileImage(File(_imagePath!)) : null,
                child: !hasImage
                    ? const Icon(Icons.person, size: 70, color: Colors.white)
                    : null,
              ),
            ),
            if (!isGuest)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF34C759),
                    child: Icon(Icons.edit, size: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          name,
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          email,
          style: GoogleFonts.lora(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String name, String email, String phone, String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildInfoTile(Icons.person_outline, "Full Name", name),
          const Divider(),
          _buildInfoTile(Icons.email_outlined, "Email", email),
          const Divider(),
          _buildInfoTile(Icons.phone_outlined, "Phone Number", phone),
          const Divider(),
          _buildInfoTile(Icons.calendar_today_outlined, "Member Since", date),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildActionTile(
            Icons.notifications_none,
            "Notification",
            const Color(0xFF34C759),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildActionTile(Icons.logout, "Logout", Colors.red, () {
            _showLogoutDialog(context);
          }),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lora(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.lora(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildGuestOrErrorUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatarSection(
            "Guest User",
            "Sign in to save data",
            isGuest: true,
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: 220,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('profile_image_guest');
                await prefs.remove('growth_plants_guest');
                await prefs.remove('scan_history_guest');
                await prefs.remove('app_notifications_guest');

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759),
                elevation: 5,
                shadowColor: const Color(0xFF34C759).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                "Login",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: 220,
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('profile_image_guest');
                await prefs.remove('growth_plants_guest');
                await prefs.remove('scan_history_guest');
                await prefs.remove('app_notifications_guest');

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF34C759), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                "Sign Up",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF34C759),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
