import 'package:ar_kids_zoo/ar_scene_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR Kids Zoo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E676),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

// ── Master animal data ────────────────────────────────────────────────────────
final List<AnimalData> allAnimals = [
  AnimalData(
    name: 'Lion',
    emoji: '🦁',
    tagline: 'King of the Savanna',
    fact: 'Lions can sleep up to 20 hours a day!',
    habitat: 'African Savanna',
    weight: '190 kg',
    lifespan: '10–14 years',
    color: const Color(0xFFFF8F00),
    glbPath: 'assets/models/lion.glb',
    initialScale: 0.07,
    scientificName: 'Panthera leo',
    conservationStatus: 'Vulnerable',
    conservationStatusColor: const Color(0xFFFFB300),
    facts: [
      'Lions can sleep up to 20 hours a day',
      'A lion\'s roar can be heard from 5 miles away',
      'Female lions do most of the hunting',
    ],
  ),
  AnimalData(
    name: 'Elephant',
    emoji: '🐘',
    tagline: "World's Largest Land Animal",
    fact: 'Elephants are the only animals that cannot jump!',
    habitat: 'Grasslands',
    weight: '5,400 kg',
    lifespan: '60–70 years',
    color: const Color(0xFF78909C),
    glbPath: 'assets/models/Elephant.glb',
    initialScale: 0.04,
    scientificName: 'Loxodonta africana',
    conservationStatus: 'Endangered',
    conservationStatusColor: const Color(0xFFFF6B6B),
    facts: [
      'Elephants are the only animals that cannot jump',
      'An elephant\'s trunk has over 40,000 muscles',
      'They can recognize themselves in a mirror',
    ],
  ),
  AnimalData(
    name: 'Horse',
    emoji: '🐴',
    tagline: 'Born to Run Free',
    fact: 'Horses can sleep both lying down and standing up!',
    habitat: 'Open Plains',
    weight: '500 kg',
    lifespan: '25–30 years',
    color: const Color(0xFF8D6E63),
    glbPath: 'assets/models/Horse.glb',
    initialScale: 0.05,
    scientificName: 'Equus ferus caballus',
    conservationStatus: 'Domesticated',
    conservationStatusColor: const Color(0xFF4CAF50),
    facts: [
      'Horses can sleep both lying down and standing up',
      'They can run shortly after birth',
      'Horses have nearly 360-degree vision',
    ],
  ),
  AnimalData(
    name: 'Cow',
    emoji: '🐄',
    tagline: 'Gentle Giant of the Farm',
    fact: 'Cows have an almost 360-degree panoramic vision!',
    habitat: 'Farmlands',
    weight: '720 kg',
    lifespan: '18–22 years',
    color: const Color(0xFF546E7A),
    glbPath: 'assets/models/Cow.glb',
    initialScale: 0.05,
    scientificName: 'Bos taurus',
    conservationStatus: 'Domesticated',
    conservationStatusColor: const Color(0xFF4CAF50),
    facts: [
      'Cows have an almost 360-degree panoramic vision',
      'They have best friends and can become stressed when separated',
      'Cows can smell scents up to 6 miles away',
    ],
  ),
  AnimalData(
    name: 'Penguin',
    emoji: '🐧',
    tagline: 'Master Swimmer',
    fact: 'Penguins can swim at speeds of up to 25 km/h!',
    habitat: 'Antarctica',
    weight: '3.5 kg',
    lifespan: '15–20 years',
    color: const Color(0xFF1565C0),
    glbPath: 'assets/models/Penguin.glb',
    initialScale: 0.15,
    scientificName: 'Spheniscidae',
    conservationStatus: 'Near Threatened',
    conservationStatusColor: const Color(0xFFFFB300),
    facts: [
      'Penguins can swim at speeds of up to 25 km/h',
      'They can hold their breath for up to 20 minutes',
      'Male penguins give pebbles to females as gifts',
    ],
  ),
  AnimalData(
    name: 'Flamingo',
    emoji: '🦩',
    tagline: 'Pink Beauty of the Wetlands',
    fact: 'Flamingos get their pink color from the food they eat!',
    habitat: 'Wetlands',
    weight: '3.5 kg',
    lifespan: '20–30 years',
    color: const Color(0xFFE91E8C),
    glbPath: 'assets/models/Flamingo.glb',
    initialScale: 0.12,
    scientificName: 'Phoenicopterus',
    conservationStatus: 'Least Concern',
    conservationStatusColor: const Color(0xFF4CAF50),
    facts: [
      'Flamingos get their pink color from the food they eat',
      'They can sleep standing on one leg',
      'Baby flamingos are born gray or white',
    ],
  ),
];

// ── Animal data model ─────────────────────────────────────────────────────────
class AnimalData {
  final String name;
  final String emoji;
  final String tagline;
  final String fact;
  final String habitat;
  final String weight;
  final String lifespan;
  final Color color;
  final String glbPath;
  final String scientificName;
  final String conservationStatus;
  final Color conservationStatusColor;
  final List<String> facts;
  final double initialScale;

  const AnimalData({
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.fact,
    required this.habitat,
    required this.weight,
    required this.lifespan,
    required this.color,
    required this.glbPath,
    required this.scientificName,
    required this.conservationStatus,
    required this.conservationStatusColor,
    required this.facts,
    this.initialScale = 0.2,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _openAR(AnimalData animal) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => ARScenePage(animal: animal),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF00E676)),
            SizedBox(width: 12),
            Text('How to Use', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _helpStep(
                  '1', 'Choose Animal', 'Tap any animal card to select it'),
              const SizedBox(height: 16),
              _helpStep(
                  '2', 'Scan Surface', 'Move phone slowly over a flat surface'),
              const SizedBox(height: 16),
              _helpStep(
                  '3', 'Place Animal', 'Tap on the dots to place your animal'),
              const SizedBox(height: 16),
              _helpStep('4', 'Interact', 'Pinch to resize • Tap for fun facts'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF00E676).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: Color(0xFF00E676), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Works best in well-lit rooms with plain floors or tables',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(
                  color: Color(0xFF00E676), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helpStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF00E676),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF0A0E1A),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection(context)),

          // Quick tips banner
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: _showHelpDialog,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00E676).withOpacity(0.15),
                      const Color(0xFF1E88E5).withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF00E676)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'First time? Tap here for quick instructions!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF00E676), size: 16),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Meet the Animals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${allAnimals.length} animals',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _buildAnimalCard(allAnimals[i]),
                childCount: allAnimals.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildHowItWorksSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF0A0E1A)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_in_ar_rounded,
                            color: Color(0xFF00E676), size: 16),
                        SizedBox(width: 6),
                        Text('AR Experience',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showHelpDialog,
                    icon: const Icon(Icons.help_outline,
                        color: Color(0xFF00E676)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Title
              AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatAnimation.value), child: child),
                  child: const Text('Wild Animals\nin AR Reality',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -1.0,
                      ))),
              const SizedBox(height: 8),
              Text(
                'Point your camera at any flat surface\nand watch wild animals appear!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) =>
                    Transform.scale(scale: _pulseAnimation.value, child: child),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _openAR(allAnimals[0]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: const Color(0xFF0A0E1A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_in_ar_rounded, size: 20),
                        SizedBox(width: 10),
                        Text('Launch AR Experience',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalCard(AnimalData animal) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: animal.color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openAR(animal),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: animal.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(animal.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.view_in_ar_rounded,
                          color: Color(0xFF00E676), size: 10),
                      SizedBox(width: 4),
                      Text('View in AR',
                          style: TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(animal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 3),
                Text(animal.tagline,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                      height: 1.4,
                    )),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: animal.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('📍 ${animal.habitat}',
                      style: TextStyle(
                        color: animal.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    final steps = [
      {
        'icon': Icons.touch_app_rounded,
        'title': 'Pick an Animal',
        'desc': 'Tap any card to choose your AR animal',
        'color': const Color(0xFFFF8F00),
      },
      {
        'icon': Icons.grid_on_rounded,
        'title': 'Find a Surface',
        'desc': 'Point at any flat floor or table',
        'color': const Color(0xFFFF6D00),
      },
      {
        'icon': Icons.view_in_ar_rounded,
        'title': 'Place & Explore',
        'desc': 'Tap dots to place • Pinch to resize',
        'color': const Color(0xFF00E676),
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How it works',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              )),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (step['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(step['icon'] as IconData,
                      color: step['color'] as Color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${step['title']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(step['desc'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}
