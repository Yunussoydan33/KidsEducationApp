import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class AnimalSoundsGame extends StatefulWidget {
  const AnimalSoundsGame({super.key});

  @override
  State<AnimalSoundsGame> createState() => _AnimalSoundsGameState();
}

class _AnimalSoundsGameState extends State<AnimalSoundsGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _successController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _successAnimation;

  int _currentAnimalIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  bool _isPlayingSound = false;
  bool _showAnswer = false;
  List<int> _selectedOptions = [];

  final List<AnimalSound> animals = [
    AnimalSound(
      name: "Kedi",
      emoji: "🐱",
      sound: "Miyav",
      soundDescription: "Miyav miyav",
      category: "Ev Hayvanları",
      soundFile: "sounds/animals/cat_meow.mp3",
    ),
    AnimalSound(
      name: "Köpek",
      emoji: "🐶",
      sound: "Hav",
      soundDescription: "Hav hav",
      category: "Ev Hayvanları",
      soundFile: "sounds/animals/dog_bark.mp3",
    ),
    AnimalSound(
      name: "İnek",
      emoji: "🐄",
      sound: "Möö",
      soundDescription: "Möö möö",
      category: "Çiftlik Hayvanları",
      soundFile: "sounds/animals/cow_moo.mp3",
    ),
    AnimalSound(
      name: "Koyun",
      emoji: "🐑",
      sound: "Mee",
      soundDescription: "Mee mee",
      category: "Çiftlik Hayvanları",
      soundFile: "sounds/animals/sheep_baa.mp3",
    ),
    AnimalSound(
      name: "At",
      emoji: "🐴",
      sound: "Kişneme",
      soundDescription: "Kişne kişne",
      category: "Çiftlik Hayvanları",
      soundFile: "sounds/animals/horse_neigh.mp3",
    ),
    AnimalSound(
      name: "Tavuk",
      emoji: "🐔",
      sound: "Gıdak",
      soundDescription: "Gıdak gıdak",
      category: "Çiftlik Hayvanları",
      soundFile: "sounds/animals/chicken_cluck.mp3",
    ),
    AnimalSound(
      name: "Aslan",
      emoji: "🦁",
      sound: "Kükreme",
      soundDescription: "Roar roar",
      category: "Vahşi Hayvanlar",
      soundFile: "sounds/animals/lion_roar.mp3",
    ),
    AnimalSound(
      name: "Kuş",
      emoji: "🐦",
      sound: "Cıvıltı",
      soundDescription: "Cik cik cik",
      category: "Kuşlar",
      soundFile: "sounds/animals/bird_chirp.mp3",
    ),
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
    setState(() {
      _currentAnimalIndex = Random().nextInt(animals.length);
      _showAnswer = false;
      _selectedOptions.clear();
    });
  }

  void _playSound() async {
    setState(() {
      _isPlayingSound = true;
    });

    try {
      final currentAnimal = animals[_currentAnimalIndex];
      // iOS'ta ses dosyası yoksa simüle et
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      // Ses dosyası yoksa simüle et
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      setState(() {
        _isPlayingSound = false;
      });
    }
  }

  void _selectOption(int optionIndex) {
    if (_showAnswer) return;

    setState(() {
      _selectedOptions.clear();
      _selectedOptions.add(optionIndex);
    });

    _checkAnswer(optionIndex);
  }

  void _checkAnswer(int selectedIndex) {
    final currentAnimal = animals[_currentAnimalIndex];
    final isCorrect = selectedIndex == 0; // İlk seçenek her zaman doğru cevap

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
    });

    Future.delayed(const Duration(seconds: 2), () {
      _generateNewQuestion();
    });
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _showAnswer = false;
      _selectedOptions.clear();
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
    final currentAnimal = animals[_currentAnimalIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🦁 Hayvan Sesleri',
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
                        // Animal Display
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
                                currentAnimal.emoji,
                                style: const TextStyle(fontSize: 80),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Hangi hayvanın sesi bu?",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              if (_showAnswer) ...[
                                Text(
                                  "Ses: ${currentAnimal.soundDescription}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4ECDC4),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Sound Button
                        if (!_showAnswer) ...[
                          AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isPlayingSound ? _bounceAnimation.value : 1.0,
                                child: GestureDetector(
                                  onTap: _isPlayingSound ? null : _playSound,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: _isPlayingSound 
                                          ? const Color(0xFFFF6B6B)
                                          : const Color(0xFF4ECDC4),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isPlayingSound 
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0xFF4ECDC4)).withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isPlayingSound ? Icons.volume_up : Icons.volume_up_outlined,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isPlayingSound ? "Ses çalıyor..." : "Sesi dinlemek için dokunun",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        const SizedBox(height: 30),
                        
                        // Answer Options
                        if (!_showAnswer) ...[
                          Text(
                            "Hangi hayvanın sesi olduğunu tahmin edin:",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ..._getAnswerOptions().asMap().entries.map((entry) {
                            int index = entry.key;
                            String option = entry.value;
                            bool isSelected = _selectedOptions.contains(index);
                            bool isCorrect = index == 0;
                            
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ElevatedButton(
                                onPressed: () => _selectOption(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : const Color(0xFF4ECDC4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  _selectedOptions.isNotEmpty && _selectedOptions.first == 0
                                      ? "🎉 Doğru Cevap!"
                                      : "❌ Yanlış Cevap!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedOptions.isNotEmpty && _selectedOptions.first == 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Bu ses ${currentAnimal.name} hayvanına aittir!",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF666666),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Ses: ${currentAnimal.sound}",
                                  style: const TextStyle(
                                    fontSize: 18,
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

  List<String> _getAnswerOptions() {
    final currentAnimal = animals[_currentAnimalIndex];
    List<String> options = [currentAnimal.name];
    
    // Rastgele 3 yanlış seçenek ekle
    List<AnimalSound> otherAnimals = List.from(animals);
    otherAnimals.removeAt(_currentAnimalIndex);
    otherAnimals.shuffle();
    
    for (int i = 0; i < 3 && i < otherAnimals.length; i++) {
      options.add(otherAnimals[i].name);
    }
    
    options.shuffle();
    return options;
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

class AnimalSound {
  final String name;
  final String emoji;
  final String sound;
  final String soundDescription;
  final String category;
  final String soundFile;

  AnimalSound({
    required this.name,
    required this.emoji,
    required this.sound,
    required this.soundDescription,
    required this.category,
    required this.soundFile,
  });
}
