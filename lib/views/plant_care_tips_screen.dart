import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantCareTipsScreen extends StatefulWidget {
  final bool showScaffold;
  const PlantCareTipsScreen({super.key, this.showScaffold = true});

  @override
  State<PlantCareTipsScreen> createState() => _PlantCareTipsScreenState();
}

class _PlantCareTipsScreenState extends State<PlantCareTipsScreen> {
  bool _isTomatoActive = true;

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 15,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plant care Tips",
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Health Life for plants",
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleOption(
                    title: "Tomato",
                    emoji: "🍅",
                    isActive: _isTomatoActive,
                    onTap: () => setState(() => _isTomatoActive = true),
                  ),
                  _buildToggleOption(
                    title: "Potato",
                    emoji: "🥔",
                    isActive: !_isTomatoActive,
                    onTap: () => setState(() => _isTomatoActive = false),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: _isTomatoActive
                  ? _buildTomatoContent()
                  : _buildPotatoContent(),
            ),
          ),
        ],
      ),
    );

    if (widget.showScaffold) {
      return Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F6ED)),
        child: Scaffold(backgroundColor: Colors.transparent, body: content),
      );
    } else {
      return Scaffold(backgroundColor: const Color(0xFFF9F6ED), body: content);
    }
  }

  Widget _buildToggleOption({
    required String title,
    required String emoji,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF34C759) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTomatoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("✅", "Care Checklist"),
        const SizedBox(height: 10),
        _buildBulletPoint("Ensure the soil is moist but not waterlogged."),
        _buildBulletPoint("Provide at least 6-8 hours of sunlight daily."),
        _buildBulletPoint("Remove yellow or damaged leaves regularly."),
        _buildBulletPoint(
          "Support the plant with a stake or cage as it grows.",
        ),
        _buildBulletPoint("Apply balanced fertilizer as recommended."),
        _buildBulletPoint(
          "Inspect the plant daily for signs of stress or disease.",
        ),

        const SizedBox(height: 25),
        const Divider(color: Colors.black87, thickness: 1.2),
        const SizedBox(height: 20),

        _buildSectionTitle("🪴", "Growth Tips"),
        const SizedBox(height: 10),
        _buildRichBulletPoint(
          "Germination: ",
          "Seeds sprout and young seedlings begin to grow.",
        ),
        _buildRichBulletPoint(
          "Vegetative Growth: ",
          "The plant develops leaves and stems rapidly.",
        ),
        _buildRichBulletPoint(
          "Flowering: ",
          "Flowers appear, preparing for fruit production.",
        ),
        _buildRichBulletPoint(
          "Fruit Development: ",
          "Tomatoes grow and ripen until ready for harvest.",
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPotatoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("✅", "Care Checklist"),
        const SizedBox(height: 10),
        _buildBulletPoint("Use loose, well-drained soil."),
        _buildBulletPoint("Water consistently without overwatering."),
        _buildBulletPoint("Add soil around the base as the plant grows."),
        _buildBulletPoint("Check leaves regularly for unusual spots."),
        _buildBulletPoint("Ensure sufficient daily sunlight."),

        const SizedBox(height: 25),
        const Divider(color: Colors.black87, thickness: 1.2),
        const SizedBox(height: 20),

        _buildSectionTitle("🪴", "Growth Tips"),
        const SizedBox(height: 10),
        _buildRichBulletPoint(
          "Germination: ",
          "Sprouts emerge from the planted seed potato.",
        ),
        _buildRichBulletPoint(
          "Vegetative Growth: ",
          "Leaves and stems grow to support the plant.",
        ),
        _buildRichBulletPoint(
          "Tuber Formation: ",
          "Underground tubers begin to develop and enlarge.",
        ),
        _buildRichBulletPoint(
          "Maturation: ",
          "The plant slows growth as tubers reach harvest size.",
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22, color: Colors.green)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lora(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichBulletPoint(String boldTitle, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: boldTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
