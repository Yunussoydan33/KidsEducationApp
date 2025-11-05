import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'educational_videos_screen.dart';
import 'games_screen.dart';
import 'coloring_screen.dart';
import 'cartoons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playButtonSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/button_click.mp3'));
    } catch (e) {
      // Ses dosyası yoksa sessiz çalış
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF87CEEB), // Sky Blue
              Color(0xFF98FB98), // Pale Green
              Color(0xFFFFB6C1), // Light Pink
              Color(0xFFFFE4B5), // Moccasin
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: const Text(
                            '🌟 Çocuklar İçin Eğitim Platformu 🌟',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Öğren, Oyna, Eğlen!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildMenuCard(
                        icon: '🎥',
                        title: 'Eğitici Videolar',
                        subtitle: 'Öğretici içerikler',
                        color: const Color(0xFFFF6B6B),
                        onTap: () {
                          _playButtonSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EducationalVideosScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuCard(
                        icon: '🎮',
                        title: 'Oyunlar',
                        subtitle: 'Eğlenceli oyunlar',
                        color: const Color(0xFF4ECDC4),
                        onTap: () {
                          _playButtonSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GamesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuCard(
                        icon: '🎨',
                        title: 'Boyama',
                        subtitle: 'Yaratıcılığını göster',
                        color: const Color(0xFFFFE66D),
                        onTap: () {
                          _playButtonSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ColoringScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuCard(
                        icon: '🎬',
                        title: 'Çizgi Filmler',
                        subtitle: 'Eğlenceli animasyonlar',
                        color: const Color(0xFFA8E6CF),
                        onTap: () {
                          _playButtonSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartoonsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
