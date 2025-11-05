import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _successController;
  late Animation<double> _moveAnimation;
  late Animation<double> _successAnimation;

  List<List<int>> puzzle = [];
  List<List<int>> solvedPuzzle = [];
  int emptyRow = 2;
  int emptyCol = 2;
  int moves = 0;
  bool isSolved = false;
  final List<String> puzzleImages = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨'
  ];

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _moveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    ));
    
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
    
    _initializePuzzle();
  }

  void _initializePuzzle() {
    // Çözülmüş puzzle oluştur
    solvedPuzzle = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 0], // 0 = boş kare
    ];
    
    // Karışık puzzle oluştur
    puzzle = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 0],
    ];
    
    // Puzzle'ı karıştır
    _shufflePuzzle();
    
    setState(() {
      moves = 0;
      isSolved = false;
      emptyRow = 2;
      emptyCol = 2;
    });
  }

  void _shufflePuzzle() {
    final random = Random();
    for (int i = 0; i < 100; i++) {
      List<int> possibleMoves = [];
      
      // Mümkün hamleleri bul
      if (emptyRow > 0) possibleMoves.add(0); // Yukarı
      if (emptyRow < 2) possibleMoves.add(1); // Aşağı
      if (emptyCol > 0) possibleMoves.add(2); // Sol
      if (emptyCol < 2) possibleMoves.add(3); // Sağ
      
      if (possibleMoves.isNotEmpty) {
        int move = possibleMoves[random.nextInt(possibleMoves.length)];
        _makeMove(move, false);
      }
    }
  }

  void _makeMove(int direction, bool countMove) {
    int newRow = emptyRow;
    int newCol = emptyCol;
    
    switch (direction) {
      case 0: // Yukarı
        newRow = emptyRow - 1;
        break;
      case 1: // Aşağı
        newRow = emptyRow + 1;
        break;
      case 2: // Sol
        newCol = emptyCol - 1;
        break;
      case 3: // Sağ
        newCol = emptyCol + 1;
        break;
    }
    
    if (newRow >= 0 && newRow < 3 && newCol >= 0 && newCol < 3) {
      // Parçaları değiştir
      puzzle[emptyRow][emptyCol] = puzzle[newRow][newCol];
      puzzle[newRow][newCol] = 0;
      
      emptyRow = newRow;
      emptyCol = newCol;
      
      if (countMove) {
        setState(() {
          moves++;
        });
        
        _moveController.forward().then((_) {
          _moveController.reset();
          _checkIfSolved();
        });
      }
    }
  }

  void _checkIfSolved() {
    bool solved = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (puzzle[i][j] != solvedPuzzle[i][j]) {
          solved = false;
          break;
        }
      }
      if (!solved) break;
    }
    
    if (solved && !isSolved) {
      setState(() {
        isSolved = true;
      });
      
      _successController.forward().then((_) {
        _showWinDialog();
      });
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
            color: Color(0xFFFFE66D),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Puzzle\'ı başarıyla tamamladınız!',
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
              _initializePuzzle();
            },
            child: const Text(
              'Tekrar Oyna',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFE66D),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Ana Menü',
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

  @override
  void dispose() {
    _moveController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧩 Puzzle Oyunu',
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
            onPressed: _initializePuzzle,
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
                  _buildScoreCard('Hamle', moves.toString(), Icons.touch_app),
                      _buildScoreCard('Durum', isSolved ? 'Tamamlandı!' : 'Devam Ediyor', Icons.extension),
                ],
              ),
            ),
            
            // Instructions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Parçaları doğru sıraya getirin! Boş kareye dokunarak hareket ettirin.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Puzzle Grid
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _successAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSolved ? 1.0 + (_successAnimation.value * 0.1) : 1.0,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            int row = index ~/ 3;
                            int col = index % 3;
                            int value = puzzle[row][col];
                            
                            return GestureDetector(
                              onTap: () {
                                if (!isSolved) {
                                  _handleTileTap(row, col);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: value == 0 
                                      ? Colors.grey[300]
                                      : const Color(0xFFFFE66D),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: value == 0 
                                        ? Colors.grey[400]!
                                        : const Color(0xFFFFD54F),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: value == 0
                                      ? const Icon(
                                          Icons.drag_indicator,
                                          color: Colors.grey,
                                          size: 30,
                                        )
                                      : Text(
                                          puzzleImages[value - 1],
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTileTap(int row, int col) {
    // Sadece boş kareye komşu parçalar hareket edebilir
    if ((row == emptyRow && (col == emptyCol - 1 || col == emptyCol + 1)) ||
        (col == emptyCol && (row == emptyRow - 1 || row == emptyRow + 1))) {
      _makeMove(_getMoveDirection(row, col), true);
    }
  }

  int _getMoveDirection(int row, int col) {
    if (row == emptyRow) {
      return col < emptyCol ? 2 : 3; // Sol veya Sağ
    } else {
      return row < emptyRow ? 0 : 1; // Yukarı veya Aşağı
    }
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
          Icon(icon, color: const Color(0xFFFFE66D), size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
