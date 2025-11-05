import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'memory_game.dart';
import 'math_game.dart';
import 'puzzle_game.dart';
import 'wheel_game.dart';
import 'voice_quiz_game.dart';
import 'color_matching_game.dart';
import 'animal_sounds_game.dart';
import 'counting_game.dart';
import 'shape_hunt_game.dart';
import 'hidden_toy_game.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    // Ses dosyası yoksa sessiz çalış
    try {
      await _audioPlayer.play(AssetSource('sounds/button_click.mp3'));
    } catch (e) {
      // Ses dosyası bulunamadı, sessiz devam et
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎮 Eğlenceli Oyunlar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4ECDC4),
              Color(0xFF45B7B8),
              Color(0xFF96CEB4),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // Orijinal Oyunlar
              _buildGameCard(
                icon: '🧠',
                title: 'Hafıza Oyunu',
                subtitle: 'Kartları eşleştir',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemoryGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🔢',
                title: 'Matematik Oyunu',
                subtitle: 'Sayıları topla',
                color: const Color(0xFF4ECDC4),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MathGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🧩',
                title: 'Puzzle Oyunu',
                subtitle: 'Parçaları birleştir',
                color: const Color(0xFFFFE66D),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PuzzleGame(),
                    ),
                  );
                },
              ),
              
              // Yeni Oyunlar
              _buildGameCard(
                icon: '🎯',
                title: 'Çark Oyunu',
                subtitle: 'Çarkı çevir, soruları cevapla',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WheelGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🎤',
                title: 'Sesli Quiz',
                subtitle: 'Sesli cevap ver',
                color: const Color(0xFF4ECDC4),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceQuizGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🎨',
                title: 'Renk Eşleştirme',
                subtitle: 'Balonları patlat',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ColorMatchingGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🦁',
                title: 'Hayvan Sesleri',
                subtitle: 'Sesleri tahmin et',
                color: const Color(0xFF4ECDC4),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnimalSoundsGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🔢',
                title: 'Sayı Sayma',
                subtitle: 'Objeleri say',
                color: const Color(0xFF4ECDC4),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CountingGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🔺',
                title: 'Şekil Avı',
                subtitle: 'Şekilleri bul',
                color: const Color(0xFFFFE66D),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShapeHuntGame(),
                    ),
                  );
                },
              ),
              _buildGameCard(
                icon: '🧸',
                title: 'Gizli Oyuncak',
                subtitle: 'Oyuncakları bul',
                color: const Color(0xFFA8E6CF),
                onTap: () {
                  _playButtonSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HiddenToyGame(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
