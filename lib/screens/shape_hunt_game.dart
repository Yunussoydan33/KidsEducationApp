import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class ShapeHuntGame extends StatefulWidget {
  const ShapeHuntGame({super.key});

  @override
  State<ShapeHuntGame> createState() => _ShapeHuntGameState();
}

class _ShapeHuntGameState extends State<ShapeHuntGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _successController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _successAnimation;

  int _currentShapeIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _level = 1;
  bool _showAnswer = false;
  List<ShapeObject> _shapes = [];
  List<ShapeInfo> _targetShapes = [];
  int _selectedShapeIndex = -1;

  final List<ShapeInfo> allShapes = [
    ShapeInfo("Kare", "⬜", Colors.blue, "Dört eşit kenarı olan şekil"),
    ShapeInfo("Üçgen", "🔺", Colors.red, "Üç kenarı olan şekil"),
    ShapeInfo("Daire", "⭕", Colors.green, "Yuvarlak şekil"),
    ShapeInfo("Dikdörtgen", "▭", Colors.orange, "İki uzun, iki kısa kenarı olan şekil"),
    ShapeInfo("Elips", "🔵", Colors.purple, "Yumurta şekli"),
    ShapeInfo("Altıgen", "⬡", Colors.pink, "Altı kenarı olan şekil"),
    ShapeInfo("Beşgen", "⬟", Colors.teal, "Beş kenarı olan şekil"),
    ShapeInfo("Yıldız", "⭐", Colors.yellow, "Beş köşeli yıldız şekli"),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    // Hedef şekil seç
    _currentShapeIndex = random.nextInt(allShapes.length);
    final targetShape = allShapes[_currentShapeIndex];
    
    // Şekilleri oluştur
    _shapes.clear();
    _targetShapes.clear();
    
    // Hedef şekil için 2-4 adet
    int targetCount = 2 + (_level ~/ 2);
    for (int i = 0; i < targetCount; i++) {
      _shapes.add(ShapeObject(
        id: i,
        shape: targetShape,
        x: 0.1 + (i * 0.8 / targetCount),
        y: 0.2 + random.nextDouble() * 0.6,
        size: 60 + random.nextInt(20),
        isTarget: true,
      ));
    }
    
    // Diğer şekiller için 4-8 adet
    int otherCount = 4 + _level;
    for (int i = 0; i < otherCount; i++) {
      ShapeInfo otherShape;
      do {
        otherShape = allShapes[random.nextInt(allShapes.length)];
      } while (otherShape == targetShape);
      
      _shapes.add(ShapeObject(
        id: targetCount + i,
        shape: otherShape,
        x: 0.1 + random.nextDouble() * 0.8,
        y: 0.2 + random.nextDouble() * 0.6,
        size: 50 + random.nextInt(20),
        isTarget: false,
      ));
    }
    
    _shapes.shuffle();
    
    setState(() {
      _showAnswer = false;
      _selectedShapeIndex = -1;
    });
  }

  void _selectShape(int index) {
    if (_showAnswer) return;

    setState(() {
      _selectedShapeIndex = index;
      _showAnswer = true;
      _totalQuestions++;
      
      if (_shapes[index].isTarget) {
        _correctAnswers++;
        _score += 10;
        _successController.forward().then((_) {
          _successController.reset();
        });
        
        // Seviye atlama kontrolü
        if (_correctAnswers % 5 == 0) {
          _level++;
        }
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      _generateNewQuestion();
    });
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _showAnswer = false;
      _selectedShapeIndex = -1;
    });
    _generateNewQuestion();
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
            color: Color(0xFFFFE66D),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow("Toplam Skor", _score.toString()),
            _buildStatRow("Doğru Cevap", _correctAnswers.toString()),
            _buildStatRow("Toplam Soru", _totalQuestions.toString()),
            _buildStatRow("Seviye", _level.toString()),
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
                color: Color(0xFFFFE66D),
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
              color: Color(0xFFFFE66D),
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
    final targetShape = allShapes[_currentShapeIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🔺 Şekil Avı',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFFE66D),
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
              Color(0xFFFFE66D),
              Color(0xFFFFF176),
              Color(0xFFFFF59D),
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
                      _buildScoreCard('Seviye', _level.toString(), Icons.trending_up),
                      _buildScoreCard('Doğru', '$_correctAnswers/$_totalQuestions', Icons.check_circle),
                    ],
                  ),
                ),
                
                // Target Shape Display
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
                      Text(
                        targetShape.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            targetShape.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            targetShape.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Instructions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Aşağıdaki şekiller arasından ${targetShape.name} şeklini bulun!",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Shapes Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _shapes.length,
                      itemBuilder: (context, index) {
                        final shape = _shapes[index];
                        final isSelected = _selectedShapeIndex == index;
                        final isCorrect = _showAnswer && shape.isTarget;
                        final isWrong = _showAnswer && isSelected && !shape.isTarget;
                        
                        return AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isSelected ? _bounceAnimation.value : 1.0,
                              child: GestureDetector(
                                onTap: () => _selectShape(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green
                                        : isWrong
                                            ? Colors.red
                                            : isSelected
                                                ? const Color(0xFFFFE66D)
                                                : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green
                                          : isWrong
                                              ? Colors.red
                                              : isSelected
                                                  ? const Color(0xFFFFE66D)
                                                  : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        shape.shape.emoji,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        shape.shape.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect || isWrong
                                              ? Colors.white
                                              : const Color(0xFF333333),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_showAnswer && shape.isTarget)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      if (_showAnswer && isSelected && !shape.isTarget)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                
                // Result Display
                if (_showAnswer) ...[
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        Text(
                          _shapes[_selectedShapeIndex].isTarget
                              ? "🎉 Doğru Cevap!"
                              : "❌ Yanlış Cevap!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _shapes[_selectedShapeIndex].isTarget
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _shapes[_selectedShapeIndex].isTarget
                              ? "Tebrikler! Doğru şekli buldunuz!"
                              : "Doğru cevap: ${targetShape.name}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
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
          Icon(icon, color: const Color(0xFFFFE66D), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFE66D),
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

class ShapeObject {
  final int id;
  final ShapeInfo shape;
  final double x;
  final double y;
  final int size;
  final bool isTarget;

  ShapeObject({
    required this.id,
    required this.shape,
    required this.x,
    required this.y,
    required this.size,
    required this.isTarget,
  });
}

class ShapeInfo {
  final String name;
  final String emoji;
  final Color color;
  final String description;

  ShapeInfo(this.name, this.emoji, this.color, this.description);
}


