import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class ColorMatchingGame extends StatefulWidget {
  const ColorMatchingGame({super.key});

  @override
  State<ColorMatchingGame> createState() => _ColorMatchingGameState();
}

class _ColorMatchingGameState extends State<ColorMatchingGame> with TickerProviderStateMixin {
  late AnimationController _popController;
  late AnimationController _floatController;
  late Animation<double> _popAnimation;
  late Animation<double> _floatAnimation;

  List<Balloon> balloons = [];
  Color targetColor = Colors.red;
  int score = 0;
  int level = 1;
  int lives = 3;
  bool gameOver = false;
  String targetColorName = "Kırmızı";

  final List<ColorInfo> colors = [
    ColorInfo(Colors.red, "Kırmızı", "🔴"),
    ColorInfo(Colors.blue, "Mavi", "🔵"),
    ColorInfo(Colors.green, "Yeşil", "🟢"),
    ColorInfo(Colors.yellow, "Sarı", "🟡"),
    ColorInfo(Colors.purple, "Mor", "🟣"),
    ColorInfo(Colors.orange, "Turuncu", "🟠"),
    ColorInfo(Colors.pink, "Pembe", "🩷"),
    ColorInfo(Colors.brown, "Kahverengi", "🤎"),
  ];

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _popAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
    ));

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _floatController.repeat(reverse: true);
    _generateBalloons();
  }

  void _generateBalloons() {
    final random = Random();
    balloons.clear();
    
    // Hedef renk için 3-5 balon
    int targetCount = 3 + (level ~/ 2);
    for (int i = 0; i < targetCount; i++) {
      balloons.add(Balloon(
        id: i,
        color: targetColor,
        x: random.nextDouble() * 0.8 + 0.1,
        y: random.nextDouble() * 0.6 + 0.2,
        size: 60 + random.nextInt(20),
        isPopped: false,
      ));
    }

    // Diğer renkler için balonlar
    int otherCount = 8 + level;
    for (int i = 0; i < otherCount; i++) {
      Color balloonColor;
      do {
        balloonColor = colors[random.nextInt(colors.length)].color;
      } while (balloonColor == targetColor);

      balloons.add(Balloon(
        id: targetCount + i,
        color: balloonColor,
        x: random.nextDouble() * 0.8 + 0.1,
        y: random.nextDouble() * 0.6 + 0.2,
        size: 60 + random.nextInt(20),
        isPopped: false,
      ));
    }

    balloons.shuffle();
  }

  void _popBalloon(int index) async {
    if (balloons[index].isPopped) return;

    setState(() {
      balloons[index].isPopped = true;
    });

    _popController.forward().then((_) {
      _popController.reset();
    });

    // Balon patlama sesi - iOS'ta simüle et
    try {
      // Ses dosyası yoksa sessiz devam et
    } catch (e) {
      // Ses dosyası yoksa sessiz devam et
    }

    if (balloons[index].color == targetColor) {
      setState(() {
        score += 10;
      });
      _checkLevelComplete();
    } else {
      setState(() {
        lives--;
        if (lives <= 0) {
          gameOver = true;
          _showGameOverDialog();
        }
      });
    }
  }

  void _checkLevelComplete() {
    bool allTargetPopped = true;
    for (var balloon in balloons) {
      if (balloon.color == targetColor && !balloon.isPopped) {
        allTargetPopped = false;
        break;
      }
    }

    if (allTargetPopped) {
      setState(() {
        level++;
        // Yeni hedef renk seç (mevcut renkten farklı olsun)
        Color newTargetColor;
        do {
          newTargetColor = colors[Random().nextInt(colors.length)].color;
        } while (newTargetColor == targetColor);
        
        targetColor = newTargetColor;
        targetColorName = colors.firstWhere((c) => c.color == targetColor).name;
      });
      _showLevelCompleteDialog();
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🎉 Seviye Tamamlandı!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B6B),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tüm hedef renkli balonları patlattınız!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Yeni Seviye: $level',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Yeni Hedef Renk: $targetColorName',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateBalloons();
            },
            child: const Text(
              'Devam Et',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🎮 Oyun Bitti!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B6B),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skorunuz: $score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ulaştığınız Seviye: $level',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text(
              'Tekrar Oyna',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Ana Menü',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      level = 1;
      lives = 3;
      gameOver = false;
      targetColor = colors[Random().nextInt(colors.length)].color;
      targetColorName = colors.firstWhere((c) => c.color == targetColor).name;
    });
    _generateBalloons();
  }

  @override
  void dispose() {
    _popController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎨 Renk Eşleştirme',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF8E8E),
              Color(0xFFFFB6C1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Arka Plan SVG
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/games/game_backgrounds.svg',
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            // Ana İçerik
            Column(
              children: [
                // Score Board
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreCard('Skor', score.toString(), Icons.star),
                      _buildScoreCard('Seviye', level.toString(), Icons.trending_up),
                      _buildScoreCard('Can', '❤️' * lives, Icons.favorite),
                    ],
                  ),
                ),
                
                // Target Color Display
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: targetColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$targetColorName renkli balonları patlatın!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Balloons
                Expanded(
                  child: Stack(
                    children: balloons.asMap().entries.map((entry) {
                      int index = entry.key;
                      Balloon balloon = entry.value;
                      
                      return AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: balloon.x * MediaQuery.of(context).size.width,
                            top: balloon.y * MediaQuery.of(context).size.height + 
                                 (balloon.isPopped ? 0 : 10 * _floatAnimation.value),
                            child: AnimatedBuilder(
                              animation: _popAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: balloon.isPopped ? _popAnimation.value : 1.0,
                                  child: GestureDetector(
                                    onTap: () => _popBalloon(index),
                                    child: Container(
                                      width: balloon.size.toDouble(),
                                      height: balloon.size.toDouble(),
                                      decoration: BoxDecoration(
                                        color: balloon.color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: balloon.color.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: balloon.isPopped
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 30,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B6B),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class Balloon {
  final int id;
  final Color color;
  final double x;
  final double y;
  final int size;
  bool isPopped;

  Balloon({
    required this.id,
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.isPopped,
  });
}

class ColorInfo {
  final Color color;
  final String name;
  final String emoji;

  ColorInfo(this.color, this.name, this.emoji);
}
