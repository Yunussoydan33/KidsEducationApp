import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class EducationalVideosScreen extends StatefulWidget {
  const EducationalVideosScreen({super.key});

  @override
  State<EducationalVideosScreen> createState() => _EducationalVideosScreenState();
}

class _EducationalVideosScreenState extends State<EducationalVideosScreen> {
  final List<VideoItem> videos = [
    VideoItem(
      title: 'Sayıları Öğrenelim',
      description: '1\'den 10\'a kadar sayıları eğlenceli şekilde öğren',
      thumbnail: '🔢',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      category: 'Matematik',
    ),
    VideoItem(
      title: 'Renkleri Tanıyalım',
      description: 'Temel renkleri öğren ve tanı',
      thumbnail: '🌈',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      category: 'Renkler',
    ),
    VideoItem(
      title: 'Hayvanlar Dünyası',
      description: 'Farklı hayvanları tanı ve seslerini öğren',
      thumbnail: '🐶',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
      category: 'Doğa',
    ),
    VideoItem(
      title: 'Alfabe Şarkısı',
      description: 'A\'dan Z\'ye harfleri şarkıyla öğren',
      thumbnail: '🔤',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      category: 'Dil',
    ),
    VideoItem(
      title: 'Şekiller ve Geometri',
      description: 'Temel şekilleri öğren',
      thumbnail: '🔺',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
      category: 'Matematik',
    ),
    VideoItem(
      title: 'Mevsimler',
      description: 'Dört mevsimi tanı ve öğren',
      thumbnail: '🍂',
      videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
      category: 'Doğa',
    ),
  ];

  String selectedCategory = 'Tümü';
  final List<String> categories = ['Tümü', 'Matematik', 'Renkler', 'Doğa', 'Dil'];

  @override
  Widget build(BuildContext context) {
    final filteredVideos = selectedCategory == 'Tümü'
        ? videos
        : videos.where((video) => video.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎥 Eğitici Videolar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                          color: isSelected ? Colors.white : const Color(0xFFFF6B6B),
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
                      selectedColor: const Color(0xFFFF6B6B),
                      checkmarkColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
            
            // Videos List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = filteredVideos[index];
                  return VideoCard(video: video);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoItem {
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final String category;

  VideoItem({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.category,
  });
}

class VideoCard extends StatefulWidget {
  final VideoItem video;

  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
    await _controller!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFFF6B6B),
        handleColor: const Color(0xFFFF6B6B),
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
          if (_chewieController != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 200,
                child: Chewie(controller: _chewieController!),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                ),
              ),
            ),
          
          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.video.thumbnail,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.video.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.video.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.video.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
