import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CartoonsScreen extends StatefulWidget {
  const CartoonsScreen({super.key});

  @override
  State<CartoonsScreen> createState() => _CartoonsScreenState();
}

class _CartoonsScreenState extends State<CartoonsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<CartoonItem> cartoons = [
    CartoonItem(
      title: 'Sevimli Hayvanlar',
      description: 'Orman hayvanlarının maceraları',
      thumbnail: '🐻',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      duration: '5:30',
      ageRating: '3+',
      category: 'Hayvanlar',
    ),
    CartoonItem(
      title: 'Renkli Dünya',
      description: 'Renklerin büyülü dünyası',
      thumbnail: '🌈',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      duration: '4:15',
      ageRating: '2+',
      category: 'Eğitici',
    ),
    CartoonItem(
      title: 'Matematik Macerası',
      description: 'Sayılarla eğlenceli yolculuk',
      thumbnail: '🔢',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
      duration: '6:45',
      ageRating: '4+',
      category: 'Matematik',
    ),
    CartoonItem(
      title: 'Alfabe Şarkıları',
      description: 'Harfleri öğrenelim',
      thumbnail: '🔤',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      duration: '7:20',
      ageRating: '3+',
      category: 'Dil',
    ),
    CartoonItem(
      title: 'Doğa Keşfi',
      description: 'Doğanın güzelliklerini keşfedelim',
      thumbnail: '🌿',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      duration: '8:10',
      ageRating: '4+',
      category: 'Doğa',
    ),
    CartoonItem(
      title: 'Uzay Macerası',
      description: 'Yıldızlar arası yolculuk',
      thumbnail: '🚀',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
      duration: '9:30',
      ageRating: '5+',
      category: 'Bilim',
    ),
  ];

  String selectedCategory = 'Tümü';
  final List<String> categories = ['Tümü', 'Hayvanlar', 'Eğitici', 'Matematik', 'Dil', 'Doğa', 'Bilim'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCartoons = selectedCategory == 'Tümü'
        ? cartoons
        : cartoons.where((cartoon) => cartoon.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎬 Çizgi Filmler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFA8E6CF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: Column(
          children: [
            // Category Filter
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFA8E6CF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFA8E6CF),
                      checkmarkColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
            
            // Cartoons List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredCartoons.length,
                itemBuilder: (context, index) {
                  final cartoon = filteredCartoons[index];
                  return AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: CartoonCard(cartoon: cartoon),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartoonItem {
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final String duration;
  final String ageRating;
  final String category;

  CartoonItem({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.duration,
    required this.ageRating,
    required this.category,
  });
}

class CartoonCard extends StatefulWidget {
  final CartoonItem cartoon;

  const CartoonCard({super.key, required this.cartoon});

  @override
  State<CartoonCard> createState() => _CartoonCardState();
}

class _CartoonCardState extends State<CartoonCard> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.cartoon.videoUrl));
    await _controller!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFA8E6CF),
        handleColor: const Color(0xFFA8E6CF),
        backgroundColor: Colors.grey[300]!,
        bufferedColor: Colors.grey[200]!,
      ),
    );
    
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          if (_chewieController != null && _isExpanded)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 200,
                child: Chewie(controller: _chewieController!),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFA8E6CF).withOpacity(0.8),
                      const Color(0xFF88D8A3).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.cartoon.thumbnail,
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.play_circle_filled,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Cartoon Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.cartoon.thumbnail,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.cartoon.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFFA8E6CF),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.cartoon.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      '⏱️ ${widget.cartoon.duration}',
                      const Color(0xFFA8E6CF),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      '👶 ${widget.cartoon.ageRating}',
                      const Color(0xFF88D8A3),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      widget.cartoon.category,
                      const Color(0xFF7FCDCD),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
