import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class HiddenToyGame extends StatefulWidget {
  const HiddenToyGame({super.key});

  @override
  State<HiddenToyGame> createState() => _HiddenToyGameState();
}

class _HiddenToyGameState extends State<HiddenToyGame> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _successController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _successAnimation;

  int _currentToyIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _level = 1;
  bool _showAnswer = false;
  List<RoomObject> _roomObjects = [];
  List<HiddenToy> _hiddenToys = [];
  int _selectedObjectIndex = -1;
  int _foundToys = 0;
  int _totalToys = 0;

  final List<ToyInfo> toys = [
    ToyInfo("🧸", "Ayıcık", "Yumuşak ve sarı renkli"),
    ToyInfo("🚗", "Araba", "Kırmızı renkli oyuncak araba"),
    ToyInfo("🏀", "Top", "Turuncu renkli basketbol topu"),
    ToyInfo("🧩", "Puzzle", "Renkli parçalardan oluşan"),
    ToyInfo("🎈", "Balon", "Renkli ve yuvarlak"),
    ToyInfo("🤖", "Robot", "Metalik ve parlak"),
    ToyInfo("🎯", "Hedef", "Daire şeklinde ve renkli"),
    ToyInfo("🎪", "Sirk", "Renkli ve eğlenceli"),
  ];

  final List<RoomObjectInfo> roomObjects = [
    RoomObjectInfo("🛏️", "Yatak", "Yatak odasında"),
    RoomObjectInfo("🪑", "Sandalye", "Oturma odasında"),
    RoomObjectInfo("📚", "Kitaplık", "Çalışma odasında"),
    RoomObjectInfo("🪞", "Ayna", "Banyoda"),
    RoomObjectInfo("🪟", "Pencere", "Her odada"),
    RoomObjectInfo("🚪", "Kapı", "Girişte"),
    RoomObjectInfo("💡", "Lamba", "Aydınlatma için"),
    RoomObjectInfo("🖼️", "Tablo", "Duvarda asılı"),
    RoomObjectInfo("🌱", "Çiçek", "Pencere kenarında"),
    RoomObjectInfo("📱", "Telefon", "Masa üstünde"),
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

    _generateNewRoom();
  }

  void _generateNewRoom() {
    final random = Random();
    
    // Hedef oyuncak seç
    _currentToyIndex = random.nextInt(toys.length);
    final targetToy = toys[_currentToyIndex];
    
    // Oda objelerini oluştur
    _roomObjects.clear();
    _hiddenToys.clear();
    
    // 8-12 oda objesi
    int objectCount = 8 + _level;
    for (int i = 0; i < objectCount; i++) {
      final roomObject = roomObjects[random.nextInt(roomObjects.length)];
      _roomObjects.add(RoomObject(
        id: i,
        object: roomObject,
        x: 0.1 + random.nextDouble() * 0.8,
        y: 0.1 + random.nextDouble() * 0.8,
        size: 60 + random.nextInt(20),
        hasHiddenToy: false,
        isRevealed: false,
      ));
    }
    
    // 2-4 gizli oyuncak yerleştir
    _totalToys = 2 + (_level ~/ 2);
    _foundToys = 0;
    
    List<int> toyPositions = [];
    while (toyPositions.length < _totalToys) {
      int pos = random.nextInt(_roomObjects.length);
      if (!toyPositions.contains(pos)) {
        toyPositions.add(pos);
        _roomObjects[pos].hasHiddenToy = true;
        _hiddenToys.add(HiddenToy(
          id: toyPositions.length - 1,
          toy: targetToy,
          objectIndex: pos,
        ));
      }
    }
    
    setState(() {
      _showAnswer = false;
      _selectedObjectIndex = -1;
    });
  }

  void _selectObject(int index) {
    if (_showAnswer) return;

    setState(() {
      _selectedObjectIndex = index;
      _showAnswer = true;
      _totalQuestions++;
      
      if (_roomObjects[index].hasHiddenToy) {
        _roomObjects[index].isRevealed = true;
        _foundToys++;
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
      if (_foundToys >= _totalToys) {
        _showLevelCompleteDialog();
      } else {
        // Sadece yanlış seçimde yeni oda oluştur
        if (!_roomObjects[_selectedObjectIndex].hasHiddenToy) {
          _generateNewRoom();
        }
      }
    });
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
            color: Color(0xFFA8E6CF),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tüm gizli oyuncakları buldunuz!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Bulunan Oyuncak: $_foundToys/$_totalToys',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA8E6CF),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Yeni Seviye: ${_level + 1}',
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
              _generateNewRoom();
            },
            child: const Text(
              'Devam Et',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFA8E6CF),
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
      _level = 1;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _showAnswer = false;
      _selectedObjectIndex = -1;
      _foundToys = 0;
      _totalToys = 0;
    });
    _generateNewRoom();
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
            color: Color(0xFFA8E6CF),
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
                color: Color(0xFFA8E6CF),
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
              color: Color(0xFFA8E6CF),
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
    final targetToy = toys[_currentToyIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧸 Gizli Oyuncak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFA8E6CF),
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
              Color(0xFFA8E6CF),
              Color(0xFF88D8A3),
              Color(0xFF7FCDCD),
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
                      _buildScoreCard('Bulunan', '$_foundToys/$_totalToys', Icons.search),
                    ],
                  ),
                ),
                
                // Target Toy Display
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
                        targetToy.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            targetToy.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            targetToy.description,
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
                    "Oda objeleri arasında gizlenmiş ${targetToy.name} oyuncaklarını bulun!",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Room Objects
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
                      itemCount: _roomObjects.length,
                      itemBuilder: (context, index) {
                        final roomObject = _roomObjects[index];
                        final isSelected = _selectedObjectIndex == index;
                        final isRevealed = roomObject.isRevealed;
                        final hasToy = roomObject.hasHiddenToy;
                        
                        return AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isSelected ? _bounceAnimation.value : 1.0,
                              child: GestureDetector(
                                onTap: () => _selectObject(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isRevealed && hasToy
                                        ? Colors.green
                                        : isSelected && !hasToy
                                            ? Colors.red
                                            : isRevealed
                                                ? Colors.blue
                                                : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isRevealed && hasToy
                                          ? Colors.green
                                          : isSelected && !hasToy
                                              ? Colors.red
                                              : isRevealed
                                                  ? Colors.blue
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
                                      if (isRevealed && hasToy)
                                        Text(
                                          targetToy.emoji,
                                          style: const TextStyle(fontSize: 30),
                                        )
                                      else
                                        Text(
                                          roomObject.object.emoji,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        roomObject.object.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isRevealed && hasToy
                                              ? Colors.white
                                              : isSelected && !hasToy
                                                  ? Colors.white
                                                  : isRevealed
                                                      ? Colors.white
                                                      : const Color(0xFF333333),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (isRevealed && hasToy)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      if (isSelected && !hasToy)
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
                          _roomObjects[_selectedObjectIndex].hasHiddenToy
                              ? "🎉 Oyuncak Bulundu!"
                              : "❌ Burada Oyuncak Yok!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _roomObjects[_selectedObjectIndex].hasHiddenToy
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _roomObjects[_selectedObjectIndex].hasHiddenToy
                              ? "Tebrikler! ${targetToy.name} oyuncak buldunuz!"
                              : "Devam edin, oyuncak başka yerde!",
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
          Icon(icon, color: const Color(0xFFA8E6CF), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA8E6CF),
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

class RoomObject {
  final int id;
  final RoomObjectInfo object;
  final double x;
  final double y;
  final int size;
  bool hasHiddenToy;
  bool isRevealed;

  RoomObject({
    required this.id,
    required this.object,
    required this.x,
    required this.y,
    required this.size,
    required this.hasHiddenToy,
    required this.isRevealed,
  });
}

class RoomObjectInfo {
  final String emoji;
  final String name;
  final String location;

  RoomObjectInfo(this.emoji, this.name, this.location);
}

class HiddenToy {
  final int id;
  final ToyInfo toy;
  final int objectIndex;

  HiddenToy({
    required this.id,
    required this.toy,
    required this.objectIndex,
  });
}

class ToyInfo {
  final String emoji;
  final String name;
  final String description;

  ToyInfo(this.emoji, this.name, this.description);
}
