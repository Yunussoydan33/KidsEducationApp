import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class VoiceQuizGame extends StatefulWidget {
  const VoiceQuizGame({super.key});

  @override
  State<VoiceQuizGame> createState() => _VoiceQuizGameState();
}

class _VoiceQuizGameState extends State<VoiceQuizGame> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _isListening = false;
  bool _showAnswer = false;
  String _userAnswer = "";
  String _correctAnswer = "";

  final List<VoiceQuizQuestion> questions = [
    VoiceQuizQuestion(
      question: "Hangi hayvan 'miyav' der?",
      correctAnswer: "kedi",
      alternatives: ["kedi", "kedi", "kedi"],
      category: "Hayvanlar",
      emoji: "🐱",
      hint: "Evde beslenen, tüylü bir hayvan",
    ),
    VoiceQuizQuestion(
      question: "Hangi renk güneşi temsil eder?",
      correctAnswer: "sarı",
      alternatives: ["sarı", "sarı", "sarı"],
      category: "Renkler",
      emoji: "☀️",
      hint: "Limon rengi",
    ),
    VoiceQuizQuestion(
      question: "Hangi meyve kırmızıdır?",
      correctAnswer: "elma",
      alternatives: ["elma", "elma", "elma"],
      category: "Meyveler",
      emoji: "🍎",
      hint: "Ağaçta yetişen kırmızı meyve",
    ),
    VoiceQuizQuestion(
      question: "Hangi sayı 5'ten büyüktür?",
      correctAnswer: "altı",
      alternatives: ["altı", "yedi", "sekiz"],
      category: "Sayılar",
      emoji: "🔢",
      hint: "5'ten sonra gelen sayı",
    ),
    VoiceQuizQuestion(
      question: "Hangi şekil yuvarlaktır?",
      correctAnswer: "daire",
      alternatives: ["daire", "daire", "daire"],
      category: "Şekiller",
      emoji: "⭕",
      hint: "Yuvarlak şekil",
    ),
    VoiceQuizQuestion(
      question: "Hangi hayvan havada uçar?",
      correctAnswer: "kuş",
      alternatives: ["kuş", "kuş", "kuş"],
      category: "Hayvanlar",
      emoji: "🐦",
      hint: "Kanatları olan hayvan",
    ),
    VoiceQuizQuestion(
      question: "Hangi mevsimde kar yağar?",
      correctAnswer: "kış",
      alternatives: ["kış", "kış", "kış"],
      category: "Mevsimler",
      emoji: "❄️",
      hint: "En soğuk mevsim",
    ),
    VoiceQuizQuestion(
      question: "Hangi harf alfabenin ilk harfidir?",
      correctAnswer: "a",
      alternatives: ["a", "a", "a"],
      category: "Alfabe",
      emoji: "🔤",
      hint: "Alfabenin başlangıcı",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _userAnswer = "";
    });

    // Simüle edilmiş ses tanıma - gerçek uygulamada speech_to_text paketi kullanılabilir
    Future.delayed(const Duration(seconds: 2), () {
      if (_isListening) {
        _processVoiceInput();
      }
    });
  }

  void _processVoiceInput() {
    setState(() {
      _isListening = false;
      _userAnswer = _getSimulatedAnswer();
      _checkAnswer();
    });
  }

  String _getSimulatedAnswer() {
    // Gerçek uygulamada bu kısım speech recognition API'sinden gelecek
    final currentQuestion = questions[_currentQuestionIndex];
    final random = Random();
    
    // %80 doğru cevap, %20 yanlış cevap simülasyonu (daha gerçekçi)
    if (random.nextDouble() < 0.8) {
      return currentQuestion.correctAnswer;
    } else {
      // Daha gerçekçi yanlış cevaplar
      final wrongAnswers = [
        currentQuestion.alternatives[random.nextInt(currentQuestion.alternatives.length)],
        "yanlış",
        "bilmiyorum"
      ];
      return wrongAnswers[random.nextInt(wrongAnswers.length)];
    }
  }

  void _checkAnswer() {
    final currentQuestion = questions[_currentQuestionIndex];
    final isCorrect = _userAnswer.toLowerCase().contains(currentQuestion.correctAnswer.toLowerCase());
    
    setState(() {
      _totalQuestions++;
      if (isCorrect) {
        _correctAnswers++;
        _score += 10;
        _successController.forward().then((_) {
          _successController.reset();
        });
      }
      _showAnswer = true;
      _correctAnswer = currentQuestion.correctAnswer;
    });

    Future.delayed(const Duration(seconds: 3), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % questions.length;
      _showAnswer = false;
      _userAnswer = "";
      _correctAnswer = "";
    });
  }

  void _resetGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _showAnswer = false;
      _userAnswer = "";
      _correctAnswer = "";
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
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎤 Sesli Quiz',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentQuestion.emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    currentQuestion.category,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4ECDC4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                currentQuestion.question,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "💡 İpucu: ${currentQuestion.hint}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Voice Input Section
                        if (!_showAnswer) ...[
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isListening ? _pulseAnimation.value : 1.0,
                                child: GestureDetector(
                                  onTap: _isListening ? null : _startListening,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: _isListening 
                                          ? const Color(0xFFFF6B6B)
                                          : const Color(0xFF4ECDC4),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isListening 
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0xFF4ECDC4)).withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isListening ? "Dinliyorum... Konuşun!" : "Mikrofona Dokunun",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        // Answer Display
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
                                  _userAnswer.toLowerCase().contains(_correctAnswer.toLowerCase())
                                      ? "🎉 Doğru Cevap!"
                                      : "❌ Yanlış Cevap!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _userAnswer.toLowerCase().contains(_correctAnswer.toLowerCase())
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Sizin cevabınız: $_userAnswer",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Doğru cevap: $_correctAnswer",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4ECDC4),
                                  ),
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
          Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ECDC4),
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

class VoiceQuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> alternatives;
  final String category;
  final String emoji;
  final String hint;

  VoiceQuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.alternatives,
    required this.category,
    required this.emoji,
    required this.hint,
  });
}
