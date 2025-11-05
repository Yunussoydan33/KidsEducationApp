import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _successController;
  late Animation<double> _flipAnimation;
  late Animation<double> _successAnimation;

  List<MemoryCard> cards = [];
  List<int> flippedCards = [];
  int matchedPairs = 0;
  int moves = 0;
  bool gameWon = false;

  final List<String> emojis = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
    '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔'
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    _successAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _initializeGame();
  }

  void _initializeGame() {
    List<String> gameEmojis = List.from(emojis.take(8));
    gameEmojis.addAll(List.from(gameEmojis)); // Çiftler oluştur
    gameEmojis.shuffle(Random());
    
    cards = gameEmojis.asMap().entries.map((entry) {
      return MemoryCard(
        id: entry.key,
        emoji: entry.value,
        isFlipped: false,
        isMatched: false,
      );
    }).toList();
    
    setState(() {
      flippedCards = [];
      matchedPairs = 0;
      moves = 0;
      gameWon = false;
    });
  }

  void _flipCard(int index) {
    if (flippedCards.length >= 2 || cards[index].isFlipped || cards[index].isMatched) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
      flippedCards.add(index);
    });

    _flipController.forward().then((_) {
      _flipController.reset();
    });

    if (flippedCards.length == 2) {
      setState(() {
        moves++;
      });

      if (cards[flippedCards[0]].emoji == cards[flippedCards[1]].emoji) {
        // Eşleşme bulundu
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            cards[flippedCards[0]].isMatched = true;
            cards[flippedCards[1]].isMatched = true;
            matchedPairs++;
            flippedCards = [];
          });
          
          _successController.forward().then((_) {
            _successController.reset();
          });

          if (matchedPairs == 8) {
            _showWinDialog();
          }
        });
      } else {
        // Eşleşme bulunamadı
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            cards[flippedCards[0]].isFlipped = false;
            cards[flippedCards[1]].isFlipped = false;
            flippedCards = [];
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '🎉 Tebrikler!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4ECDC4),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tüm kartları başarıyla eşleştirdiniz!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Toplam hamle: $moves',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
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
    _flipController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧠 Hafıza Oyunu',
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
            onPressed: _initializeGame,
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
                  _buildScoreCard('Hamle', moves.toString(), Icons.touch_app),
                  _buildScoreCard('Eşleşme', '$matchedPairs/8', Icons.star),
                ],
              ),
            ),
            
            // Game Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: () => _flipCard(index),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(cards[index].isFlipped ? 0 : 3.14159),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cards[index].isFlipped || cards[index].isMatched
                                    ? Colors.white
                                    : const Color(0xFF4ECDC4),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: cards[index].isFlipped || cards[index].isMatched
                                    ? Text(
                                        cards[index].emoji,
                                        style: const TextStyle(fontSize: 30),
                                      )
                                    : const Icon(
                                        Icons.help_outline,
                                        color: Colors.white,
                                        size: 30,
                                      ),
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

class MemoryCard {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    required this.isFlipped,
    required this.isMatched,
  });
}
