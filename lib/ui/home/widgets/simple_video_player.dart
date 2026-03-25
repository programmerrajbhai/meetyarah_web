import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const SimpleVideoPlayer({super.key, required this.videoUrl});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // 🚀 URL e kono space ba vul thakle seta auto-fix korbe Uri.encodeFull
      String safeUrl = Uri.encodeFull(widget.videoUrl.trim());

      // ignore: deprecated_member_use
      _controller = VideoPlayerController.network(safeUrl);

      await _controller.initialize();
      _controller.setLooping(true); // Video shesh hole abar shuru hobe

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("🎥 Video Init Error: $e");
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // 🚀 Scroll kore chole gele video pause & dispose hoye jabe (Memory save korbe)
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ❌ Jodi video link e kono problem thake (Error State)
    if (_isError) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, color: Colors.white54, size: 40),
              SizedBox(height: 8),
              Text("Video not available", style: TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    // ⏳ Video Initial Load (Shimmer/Loading State)
    if (!_isInitialized) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[200], // Facebook er moton halka grey loading
        child: const Center(
          child: SizedBox(
            height: 30, width: 30,
            child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2.5),
          ),
        ),
      );
    }

    // ✅ Video Play State
    return Container(
      color: Colors.black, // Video background kalo
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: VideoPlayer(_controller),
            ),

            // Play Button Overlay (Jodi pause thake tokhon dekhabe)
            if (!_controller.value.isPlaying)
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
              ),
          ],
        ),
      ),
    );
  }
}