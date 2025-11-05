import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  Color selectedColor = Colors.black;
  double brushSize = 5.0;
  List<ColoringPage> coloringPages = [];
  int selectedPageIndex = 0;
  bool showColorPicker = false;

  @override
  void initState() {
    super.initState();
    _initializeColoringPages();
  }

  void _initializeColoringPages() {
    coloringPages = [
      ColoringPage(
        name: 'Kedi',
        emoji: '🐱',
        imagePath: 'assets/images/coloring/cat.svg',
        difficulty: 'Kolay',
      ),
      ColoringPage(
        name: 'Köpek',
        emoji: '🐶',
        imagePath: 'assets/images/coloring/dog.svg',
        difficulty: 'Kolay',
      ),
      ColoringPage(
        name: 'Kelebek',
        emoji: '🦋',
        imagePath: 'assets/images/coloring/butterfly.svg',
        difficulty: 'Orta',
      ),
      ColoringPage(
        name: 'Çiçek',
        emoji: '🌸',
        imagePath: 'assets/images/coloring/flower.svg',
        difficulty: 'Orta',
      ),
      ColoringPage(
        name: 'Ev',
        emoji: '🏠',
        imagePath: 'assets/images/coloring/house.svg',
        difficulty: 'Zor',
      ),
      ColoringPage(
        name: 'Araba',
        emoji: '🚗',
        imagePath: 'assets/images/coloring/car.svg',
        difficulty: 'Zor',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎨 Boyama Kitabı',
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
            icon: const Icon(Icons.palette),
            onPressed: () {
              setState(() {
                showColorPicker = !showColorPicker;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetColoring,
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
        child: Column(
          children: [
            // Color Palette
            if (showColorPicker) _buildColorPicker(),
            
            // Coloring Pages Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: coloringPages.length,
                  itemBuilder: (context, index) {
                    return _buildColoringPageCard(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Renk Seçin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hslWithSaturation,
            labelTypes: const [],
            portraitOnly: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorButton(Colors.red, 'Kırmızı'),
              _buildColorButton(Colors.blue, 'Mavi'),
              _buildColorButton(Colors.green, 'Yeşil'),
              _buildColorButton(Colors.yellow, 'Sarı'),
              _buildColorButton(Colors.purple, 'Mor'),
              _buildColorButton(Colors.orange, 'Turuncu'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorButton(Colors.pink, 'Pembe'),
              _buildColorButton(Colors.brown, 'Kahverengi'),
              _buildColorButton(Colors.grey, 'Gri'),
              _buildColorButton(Colors.black, 'Siyah'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColor == color ? Colors.black : Colors.grey,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoringPageCard(int index) {
    final page = coloringPages[index];
    return GestureDetector(
      onTap: () => _openColoringPage(index),
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
        child: Column(
          children: [
            // Preview Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        page.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 10),
                      SvgPicture.asset(
                        page.imagePath,
                        width: 80,
                        height: 80,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Page Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      page.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(page.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        page.difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getDifficultyColor(page.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Kolay':
        return Colors.green;
      case 'Orta':
        return Colors.orange;
      case 'Zor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openColoringPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColoringCanvas(
          page: coloringPages[index],
          selectedColor: selectedColor,
          brushSize: brushSize,
        ),
      ),
    );
  }

  void _resetColoring() {
    setState(() {
      selectedColor = Colors.black;
      brushSize = 5.0;
    });
  }
}

class ColoringPage {
  final String name;
  final String emoji;
  final String imagePath;
  final String difficulty;

  ColoringPage({
    required this.name,
    required this.emoji,
    required this.imagePath,
    required this.difficulty,
  });
}

class ColoringCanvas extends StatefulWidget {
  final ColoringPage page;
  final Color selectedColor;
  final double brushSize;

  const ColoringCanvas({
    super.key,
    required this.page,
    required this.selectedColor,
    required this.brushSize,
  });

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  List<ColoringStroke> strokes = [];
  Color currentColor = Colors.black;
  double currentBrushSize = 5.0;
  bool showTools = true;

  @override
  void initState() {
    super.initState();
    currentColor = widget.selectedColor;
    currentBrushSize = widget.brushSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎨 ${widget.page.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFFE66D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoLastStroke,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCanvas,
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
        child: Column(
          children: [
            // Tools Panel
            if (showTools) _buildToolsPanel(),
            
            // Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                  child: Stack(
                    children: [
                      // SVG Arka Plan
                      Center(
                        child: SvgPicture.asset(
                          widget.page.imagePath,
                          width: 300,
                          height: 300,
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      // Boyama Katmanı
                      CustomPaint(
                        painter: ColoringPainter(strokes),
                        size: Size.infinite,
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showTools = !showTools;
          });
        },
        backgroundColor: const Color(0xFFFFE66D),
        child: Icon(
          showTools ? Icons.close : Icons.palette,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToolsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Color Palette
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorButton(Colors.red),
              _buildColorButton(Colors.blue),
              _buildColorButton(Colors.green),
              _buildColorButton(Colors.yellow),
              _buildColorButton(Colors.purple),
              _buildColorButton(Colors.orange),
              _buildColorButton(Colors.pink),
              _buildColorButton(Colors.black),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Brush Size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Fırça Boyutu:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Slider(
                value: currentBrushSize,
                min: 2.0,
                max: 20.0,
                divisions: 18,
                activeColor: const Color(0xFFFFE66D),
                onChanged: (value) {
                  setState(() {
                    currentBrushSize = value;
                  });
                },
              ),
              Text(
                '${currentBrushSize.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: currentColor == color ? Colors.black : Colors.grey,
            width: 3,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    strokes.add(ColoringStroke(
      points: [details.localPosition],
      color: currentColor,
      brushSize: currentBrushSize,
    ));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    strokes.last.points.add(details.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {});
  }

  void _undoLastStroke() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokes.removeLast();
      });
    }
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temizle'),
        content: const Text('Tüm çizimleri silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                strokes.clear();
              });
            },
            child: const Text('Evet'),
          ),
        ],
      ),
    );
  }
}

class ColoringStroke {
  List<Offset> points;
  Color color;
  double brushSize;

  ColoringStroke({
    required this.points,
    required this.color,
    required this.brushSize,
  });
}

class ColoringPainter extends CustomPainter {
  final List<ColoringStroke> strokes;

  ColoringPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(
          stroke.points[i],
          stroke.points[i + 1],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
