import 'package:flutter/material.dart';
import 'package:spudtom/constants/app_colors.dart';
import 'package:spudtom/views/camera_screen.dart';
import 'package:spudtom/views/dashboard_screen.dart';
import 'package:spudtom/views/plant_library_screen.dart';
import 'package:spudtom/views/profile_screen.dart';
import 'package:spudtom/views/scan_history_screen.dart';
import 'package:spudtom/views/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCameraPressed = false;

  // 🛠️ التعديل الأول والوحيد: شيلنا الـ get وخليناها لستة ثابتة بتتخلق مرة واحدة بس في الذاكرة
  late final List<Widget> _screens = [
    DashboardScreen(
      onChangeTab: _onItemTapped,
      showScaffold: false,
      onOpenNotifications: () {},
    ),
    const PlantLibraryScreen(showScaffold: false),
    const CameraScreen(showScaffold: false),
    const ScanHistoryScreen(showScaffold: false),
    const ProfileScreen(showScaffold: false),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowFab = _selectedIndex != 3;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,

        body: IndexedStack(index: _selectedIndex, children: _screens),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: shouldShowFab ? _buildAIChatButton() : null,

        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 70),
                  painter: NotchedBarPainter(),
                ),

                SizedBox(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_filled,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.inventory_2,
                        label: 'Library',
                        index: 1,
                      ),
                      const SizedBox(width: 80),
                      _buildNavItem(
                        icon: Icons.history_rounded,
                        label: 'History',
                        index: 3,
                      ),
                      _buildNavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        index: 4,
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: -25,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isCameraPressed = true),
                    onTapUp: (_) {
                      setState(() => _isCameraPressed = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CameraScreen(showScaffold: true),
                        ),
                      );
                    },
                    onTapCancel: () => setState(() => _isCameraPressed = false),
                    child: AnimatedScale(
                      scale: _isCameraPressed ? 0.85 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOutBack,
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: AppColors.primaryGreen.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIChatButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 0.7),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.white,
            backgroundImage: const AssetImage('assets/ai_logo.png'),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ignore: deprecated_member_use
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: isSelected ? 28 : 35,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class NotchedBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect hostRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Rect guestRect = Rect.fromCircle(
      center: Offset(size.width / 2, 10),
      radius: 43.0,
    );
    final Path notchedPath = const CircularNotchedRectangle().getOuterPath(
      hostRect,
      guestRect,
    );
    final Path roundedPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(hostRect, const Radius.circular(30.0)),
      );
    final Path finalPath = Path.combine(
      PathOperation.intersect,
      notchedPath,
      roundedPath,
    );

    canvas.drawShadow(finalPath, Colors.black.withOpacity(0.15), 15, true);
    final paint = Paint()
      ..color = const Color(0xFF1A331A)
      ..style = PaintingStyle.fill;

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
