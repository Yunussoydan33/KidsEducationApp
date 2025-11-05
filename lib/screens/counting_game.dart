import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class CountingGame extends StatefulWidget {
  const CountingGame({super.key});

  @override
  State<CountingGame> createState() => _CountingGameState();
}

class _CountingGameState extends State<CountingGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _successController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _successAnimation;

  int _currentCount = 0;
  int _targetCount = 0;
  int _score = 0;
  int _level = 1;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _showAnswer = false;
  List<CountableObject> _objects = [];
  List<int> _answerOptions = [];

  final List<ObjectType> objectTypes = [
    ObjectType("🍎", "Elma", Colors.red),
    ObjectType("🍊", "Portakal", Colors.orange),
    ObjectType("🍌", "Muz", Colors.yellow),
    ObjectType("🍇", "Üzüm", Colors.purple),
    ObjectType("🍓", "Çilek", Colors.pink),
    ObjectType("🥕", "Havuç", Colors.orange),
    ObjectType("🍄", "Mantar", Colors.brown),
    ObjectType("🌻", "Ayçiçeği", Colors.yellow),
    ObjectType("🐱", "Kedi", Colors.orange),
    ObjectType("🐶", "Köpek", Colors.brown),
    ObjectType("🐰", "Tavşan", Colors.grey),
    ObjectType("🐸", "Kurbağa", Colors.green),
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
    
    // Zorluk seviyesine göre sayı aralığı
    int maxCount = 3 + (_level * 2);
    _targetCount = random.nextInt(maxCount) + 1;
    
    // Rastgele obje türü seç
    final objectType = objectTypes[random.nextInt(objectTypes.length)];
    
    // Objeleri oluştur
    _objects.clear();
    for (int i = 0; i < _targetCount; i++) {
      _objects.add(CountableObject(
        id: i,
        type: objectType,
        x: 0.1 + (i * 0.8 / _targetCount),
        y: 0.3 + random.nextDouble() * 0.4,
        size: 50 + random.nextInt(20),
      ));
    }
    
    // Cevap seçeneklerini oluştur
    _generateAnswerOptions();
    
    setState(() {
      _currentCount = 0;
      _showAnswer = false;
    });
  }

  void _generateAnswerOptions() {
    final random = Random();
    _answerOptions = [_targetCount];
    
    // Yanlış seçenekler ekle
    while (_answerOptions.length < 4) {
      int wrongAnswer;
      if (_targetCount <= 3) {
        wrongAnswer = _targetCount + random.nextInt(3) - 1;
      } else {
        wrongAnswer = _targetCount + random.nextInt(5) - 2;
      }
      
      if (wrongAnswer > 0 && !_answerOptions.contains(wrongAnswer)) {
        _answerOptions.add(wrongAnswer);
      }
    }
    
    _answerOptions.shuffle();
  }

  void _selectAnswer(int answer) {
    if (_showAnswer) return;

    setState(() {
      _showAnswer = true;
      _totalQuestions++;
      _currentCount = answer; // Seçilen cevabı kaydet
      
      if (answer == _targetCount) {
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
    _bounceController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🔢 Sayı Sayma',
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
                      _buildScoreCard('Skor', _score.toString(), Icons.star),
                      _buildScoreCard('Seviye', _level.toString(), Icons.trending_up),
                      _buildScoreCard('Doğru', '$_correctAnswers/$_totalQuestions', Icons.check_circle),
                    ],
                  ),
                ),
                
                // Question
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                              Text(
                                "Kaç tane ${_objects.isNotEmpty ? _objects.first.type.name : 'obje'} var?",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              if (_objects.isNotEmpty)
                                Text(
                                  _objects.first.type.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Objects Display
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: _objects.map((obj) {
                              return Positioned(
                                left: obj.x * (MediaQuery.of(context).size.width - 40),
                                top: obj.y * 200,
                                child: AnimatedBuilder(
                                  animation: _bounceAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _bounceAnimation.value,
                                      child: Container(
                                        width: obj.size.toDouble(),
                                        height: obj.size.toDouble(),
                                        decoration: BoxDecoration(
                                          color: obj.type.color.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: obj.type.color.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            obj.type.emoji,
                                            style: const TextStyle(fontSize: 30),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Answer Options
                        if (!_showAnswer) ...[
                          Text(
                            "Doğru sayıyı seçin:",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2,
                            ),
                            itemCount: _answerOptions.length,
                            itemBuilder: (context, index) {
                              final answer = _answerOptions[index];
                              return GestureDetector(
                                onTap: () => _selectAnswer(answer),
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
                                      answer.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4ECDC4),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        
                        // Result Display
                        if (_showAnswer) ...[
                          Container(
                            width: double.infinity,
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
                                  _currentCount == _targetCount
                                      ? "🎉 Doğru Cevap!"
                                      : "❌ Yanlış Cevap!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _currentCount == _targetCount
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Doğru cevap: $_targetCount",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4ECDC4),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Toplam ${_objects.length} tane ${_objects.isNotEmpty ? _objects.first.type.name : 'obje'} vardı!",
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

class CountableObject {
  final int id;
  final ObjectType type;
  final double x;
  final double y;
  final int size;

  CountableObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.size,
  });
}

class ObjectType {
  final String emoji;
  final String name;
  final Color color;

  ObjectType(this.emoji, this.name, this.color);
}
