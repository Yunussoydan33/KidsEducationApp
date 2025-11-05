import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class WheelGame extends StatefulWidget {
  const WheelGame({super.key});

  @override
  State<WheelGame> createState() => _WheelGameState();
}

class _WheelGameState extends State<WheelGame> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _bounceController;
  late Animation<double> _spinAnimation;
  late Animation<double> _bounceAnimation;

  double _currentRotation = 0;
  bool _isSpinning = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;

  final List<WheelQuestion> questions = [
    WheelQuestion(
      question: "Türkiye'nin başkenti neresidir?",
      options: ["İstanbul", "Ankara", "İzmir", "Bursa"],
      correctAnswer: 1,
      category: "Coğrafya",
      emoji: "🏛️",
    ),
    WheelQuestion(
      question: "Hangi renk güneşi temsil eder?",
      options: ["Mavi", "Sarı", "Yeşil", "Kırmızı"],
      correctAnswer: 1,
      category: "Renkler",
      emoji: "☀️",
    ),
    WheelQuestion(
      question: "2 + 3 kaç eder?",
      options: ["4", "5", "6", "7"],
      correctAnswer: 1,
      category: "Matematik",
      emoji: "🔢",
    ),
    WheelQuestion(
      question: "Hangi hayvan havada uçar?",
      options: ["Köpek", "Kedi", "Kuş", "Balık"],
      correctAnswer: 2,
      category: "Hayvanlar",
      emoji: "🐦",
    ),
    WheelQuestion(
      question: "Hangi mevsimde kar yağar?",
      options: ["Yaz", "Kış", "İlkbahar", "Sonbahar"],
      correctAnswer: 1,
      category: "Mevsimler",
      emoji: "❄️",
    ),
    WheelQuestion(
      question: "A harfinden sonra hangi harf gelir?",
      options: ["B", "C", "D", "E"],
      correctAnswer: 0,
      category: "Alfabe",
      emoji: "🔤",
    ),
    WheelQuestion(
      question: "Hangi şekil 3 kenarlıdır?",
      options: ["Kare", "Daire", "Üçgen", "Dikdörtgen"],
      correctAnswer: 2,
      category: "Şekiller",
      emoji: "🔺",
    ),
    WheelQuestion(
      question: "Hangi gezegen bizim güneş sistemimizdedir?",
      options: ["Venüs", "Mars", "Jüpiter", "Hepsi"],
      correctAnswer: 3,
      category: "Uzay",
      emoji: "🚀",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _spinAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _currentQuestionIndex = Random().nextInt(questions.length);
        });
        _showQuestionDialog();
      }
    });
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    _spinController.forward().then((_) {
      _spinController.reset();
    });
  }

  void _showQuestionDialog() {
    final question = questions[_currentQuestionIndex];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(
              question.emoji,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question.category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...question.options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(index, question),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(int selectedIndex, WheelQuestion question) {
    Navigator.pop(context);
    
    setState(() {
      _totalQuestions++;
      if (selectedIndex == question.correctAnswer) {
        _correctAnswers++;
        _score += 10;
        _bounceController.forward().then((_) {
          _bounceController.reset();
        });
        _showResultDialog(true, question);
      } else {
        _showResultDialog(false, question);
      }
    });
  }

  void _showResultDialog(bool isCorrect, WheelQuestion question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isCorrect ? "🎉 Doğru!" : "❌ Yanlış!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCorrect) ...[
              Text(
                "Doğru cevap: ${question.options[question.correctAnswer]}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
            Text(
              "Skorunuz: $_score",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4ECDC4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Devam Et",
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

  void _resetGame() {
    setState(() {
      _score = 0;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _currentRotation = 0;
    });
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "📊 İstatistikler",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4ECDC4),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow("Toplam Skor", _score.toString()),
            _buildStatRow("Doğru Cevap", _correctAnswers.toString()),
            _buildStatRow("Toplam Soru", _totalQuestions.toString()),
            _buildStatRow("Başarı Oranı", 
              _totalQuestions > 0 ? "${((_correctAnswers / _totalQuestions) * 100).toInt()}%" : "0%"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tamam",
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎯 Çark Oyunu',
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
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStatsDialog,
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
                      _buildScoreCard('Skor', _score.toString(), Icons.star),
                      _buildScoreCard('Doğru', '$_correctAnswers/$_totalQuestions', Icons.check_circle),
                    ],
                  ),
                ),
                
                // Wheel
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Çarkı Çevir ve Soruları Cevapla!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        AnimatedBuilder(
                          animation: _spinAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _currentRotation + (_spinAnimation.value * 10 * pi),
                              child: GestureDetector(
                                onTap: _isSpinning ? null : _spinWheel,
                                child: AnimatedBuilder(
                                  animation: _bounceAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _bounceAnimation.value,
                                      child: Container(
                                        width: 250,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B6B),
                                              Color(0xFFFF8E8E),
                                              Color(0xFFFFB6C1),
                                              Color(0xFF4ECDC4),
                                              Color(0xFF45B7B8),
                                              Color(0xFF96CEB4),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Çark dilimleri
                                            ...List.generate(8, (index) {
                                              return Transform.rotate(
                                                angle: (index * pi * 2) / 8,
                                                child: Container(
                                                  width: 250,
                                                  height: 250,
                                                  child: CustomPaint(
                                                    painter: WheelSlicePainter(
                                                      index: index,
                                                      totalSlices: 8,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                            // Merkez dairesi
                                            Center(
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Color(0xFFFF6B6B),
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        if (!_isSpinning)
                          ElevatedButton.icon(
                            onPressed: _spinWheel,
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Çarkı Çevir!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF6B6B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WheelQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;
  final String emoji;

  WheelQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.emoji,
  });
}

class WheelSlicePainter extends CustomPainter {
  final int index;
  final int totalSlices;

  WheelSlicePainter({
    required this.index,
    required this.totalSlices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _getSliceColor(index);

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final startAngle = (index * 2 * pi) / totalSlices;
    final sweepAngle = (2 * pi) / totalSlices;

    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  Color _getSliceColor(int index) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFF8E8E),
      const Color(0xFFFFB6C1),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7B8),
      const Color(0xFF96CEB4),
      const Color(0xFFFFE66D),
      const Color(0xFFA8E6CF),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


