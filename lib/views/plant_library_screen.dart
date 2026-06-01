import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spudtom/views/home_screen.dart';

class PlantLibraryScreen extends StatefulWidget {
  final bool showScaffold;
  const PlantLibraryScreen({super.key, this.showScaffold = true});

  @override
  State<PlantLibraryScreen> createState() => _PlantLibraryScreenState();
}

class _PlantLibraryScreenState extends State<PlantLibraryScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Solanaceae', 'Fabaceae', 'Apiaceae'];

  final List<Map<String, String>> _solanaceaePlants = [
    {
      'emoji': '🍅',
      'name': 'Tomato',
      'desc':
          'A fruiting plant that needs strong sunlight and regular watering for healthy growth.',
      'disease': 'Early / Late blight',
      'cause':
          'Fungal infection that spreads in humid conditions and poor airflow.',
    },
    {
      'emoji': '🥔',
      'name': 'Potato',
      'desc':
          'A tuber plant that requires well-drained soil and balanced watering.',
      'disease': 'Late blight',
      'cause': 'Fungus that thrives in cool, moist environments.',
    },
    {
      'emoji': '🍆',
      'name': 'Eggplant',
      'desc':
          'A warm-season fruiting plant that prefers sunlight and steady watering.',
      'disease': 'Fusarium wilt',
      'cause': 'Soil-borne fungi encouraged by excess moisture.',
    },
    {
      'emoji': '🫑',
      'name': 'Bell Pepper',
      'desc': 'A heat-loving plant that grows best with direct sunlight.',
      'disease': 'Leaf spot',
      'cause': 'Bacterial or fungal infection in wet conditions.',
    },
    {
      'emoji': '🌶️',
      'name': 'Chili Pepper',
      'desc': 'A fast-growing fruiting plant needing well-drained soil.',
      'disease': 'Powdery mildew',
      'cause': 'High humidity and poor ventilation.',
    },
  ];

  final List<Map<String, String>> _fabaceaePlants = [
    {
      'emoji': '🫛',
      'name': 'Fava Bean',
      'desc': 'A cool-season legume that needs moderate watering.',
      'disease': 'Powdery mildew',
      'cause': 'Moist air and limited airflow.',
    },
    {
      'emoji': '🫘',
      'name': 'Bean',
      'desc':
          'A fast-growing plant that requires sunlight and regular watering.',
      'disease': 'Bean rust',
      'cause': 'Fungal spores spread in humid weather.',
    },
    {
      'emoji': '🟠',
      'name': 'Lentil',
      'desc':
          'A small legume that tolerates dry conditions and needs good drainage.',
      'disease': 'Lentil blight',
      'cause': 'Fungal infection supported by moisture.',
    },
    {
      'emoji': '🥜',
      'name': 'Chickpea',
      'desc': 'A warm-season legume that prefers light, airy soil.',
      'disease': 'Chickpea blight',
      'cause': 'Excess humidity and poorly drained soil.',
    },
  ];

  final List<Map<String, String>> _apiaceaePlants = [
    {
      'emoji': '🥕',
      'name': 'Carrot',
      'desc': 'A root vegetable that needs loose soil and steady watering.',
      'disease': 'Leaf spot',
      'cause': 'Fungal infection spread by moisture.',
    },
    {
      'emoji': '🌿',
      'name': 'Parsley',
      'desc':
          'A leafy herb that grows best with partial sunlight and regular watering.',
      'disease': 'Powdery mildew',
      'cause': 'Humid air and crowded planting.',
    },
    {
      'emoji': '🥬',
      'name': 'Celery',
      'desc': 'A moisture-loving leafy plant that needs rich soil.',
      'disease': 'Celery blight',
      'cause': 'Fungi that develop in wet soil.',
    },
    {
      'emoji': '🌱',
      'name': 'Dill',
      'desc':
          'A fast-growing herb that prefers sunlight and moderate watering.',
      'disease': 'Powdery mildew',
      'cause': 'High humidity and poor airflow.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentPlants;
    if (_selectedCategoryIndex == 0) {
      currentPlants = _solanaceaePlants;
    } else if (_selectedCategoryIndex == 1) {
      currentPlants = _fabaceaePlants;
    } else {
      currentPlants = _apiaceaePlants;
    }

    Widget content = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                const SizedBox(width: 15),
                Text(
                  "Plant Library",
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: AssetImage(
                            _categoryImages[_selectedCategoryIndex],
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: List.generate(_categories.length, (index) {
                        return _buildCategoryTab(index, _categories[index]);
                      }),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_categories[_selectedCategoryIndex]} Family",
                          style: GoogleFonts.lora(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(height: 2, width: 200, color: Colors.black87),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: currentPlants.length,
                    itemBuilder: (context, index) {
                      return _buildPlantItem(
                        currentPlants[index],
                        index == currentPlants.length - 1,
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );

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
    } else {
      return Scaffold(backgroundColor: Colors.transparent, body: content);
    }
  }

  final List<String> _categoryImages = [
    'assets/library_1.png',
    'assets/library_2.png',
    'assets/library_3.png',
  ];

  Widget _buildCategoryTab(int index, String title) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF34C759) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: GoogleFonts.lora(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Widget _buildPlantItem(Map<String, String> plant, bool isLast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(plant['emoji']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              plant['name']!,
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        Text(
          plant['desc']!,
          style: GoogleFonts.lora(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 5),

        RichText(
          text: TextSpan(
            style: GoogleFonts.lora(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'Common disease: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: plant['disease']),
            ],
          ),
        ),
        const SizedBox(height: 2),

        RichText(
          text: TextSpan(
            style: GoogleFonts.lora(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'Cause: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: plant['cause']),
            ],
          ),
        ),

        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Divider(
              color: Colors.grey.shade400,
              thickness: 1,
              indent: 40,
              endIndent: 40,
            ),
          ),
        if (isLast) const SizedBox(height: 20),
      ],
    );
  }
}
