import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class MathGame extends StatefulWidget {
  const MathGame({super.key});

  @override
  State<MathGame> createState() => _MathGameState();
}

class _MathGameState extends State<MathGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _successController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _successAnimation;

  int num1 = 0;
  int num2 = 0;
  int correctAnswer = 0;
  int score = 0;
  int level = 1;
  int lives = 3;
  List<int> options = [];
  bool gameOver = false;
  String operation = '+';

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    final random = Random();
    
    // Zorluk seviyesine göre sayı aralığı
    int maxNumber = 5 + (level * 3);
    
    num1 = random.nextInt(maxNumber) + 1;
    num2 = random.nextInt(maxNumber) + 1;
    
    // Rastgele işlem seç
    final operations = ['+', '-', '×'];
    operation = operations[random.nextInt(operations.length)];
    
    switch (operation) {
      case '+':
        correctAnswer = num1 + num2;
        break;
      case '-':
        // Negatif sonuç olmaması için
        if (num1 < num2) {
          int temp = num1;
          num1 = num2;
          num2 = temp;
        }
        correctAnswer = num1 - num2;
        break;
      case '×':
        // Çarpma için daha küçük sayılar
        num1 = random.nextInt(5) + 1;
        num2 = random.nextInt(5) + 1;
        correctAnswer = num1 * num2;
        break;
    }
    
    _generateOptions();
  }

  void _generateOptions() {
    final random = Random();
    options = [correctAnswer];
    
    while (options.length < 4) {
      int wrongAnswer;
      if (operation == '×') {
        wrongAnswer = correctAnswer + random.nextInt(10) - 5;
      } else {
        wrongAnswer = correctAnswer + random.nextInt(6) - 3;
      }
      
      if (wrongAnswer >= 0 && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    
    options.shuffle();
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == correctAnswer) {
      setState(() {
        score += 10;
        // Her 5 doğru cevapta seviye atla
        if (score % 50 == 0) {
          level++;
        }
      });
      
      _successController.forward().then((_) {
        _successController.reset();
        _generateNewQuestion();
      });
    } else {
      setState(() {
        lives--;
        if (lives <= 0) {
          gameOver = true;
        }
      });
      
      _bounceController.forward().then((_) {
        _bounceController.reset();
        if (!gameOver) {
          _generateNewQuestion();
        }
      });
    }
  }

  void _resetGame() {
    setState(() {
      score = 0;
      level = 1;
      lives = 3;
      gameOver = false;
    });
    _generateNewQuestion();
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
            color: Color(0xFF4ECDC4),
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
                color: Color(0xFF4ECDC4),
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
                color: Color(0xFF4ECDC4),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Ana Menü',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4ECDC4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _successController.dispose();
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
          '🔢 Matematik Oyunu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4ECDC4),
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
              Color(0xFF4ECDC4),
              Color(0xFF45B7B8),
              Color(0xFF96CEB4),
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
            
            // Question
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Hangi sayı doğru?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '$num1 $operation $num2 = ?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Answer Options
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2,
                      ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return GestureDetector(
                              onTap: () => _checkAnswer(options[index]),
                              child: Transform.scale(
                                scale: _bounceAnimation.value,
                                child: Container(
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
                                  child: Center(
                                    child: Text(
                                      options[index].toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4ECDC4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
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
          Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4ECDC4),
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
