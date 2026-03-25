import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard এর জন্য
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const SimpleVideoPlayer({super.key, required this.videoUrl});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      String cleanUrl = widget.videoUrl.trim();
      Uri uri = Uri.parse(cleanUrl);

      // 🚀 THE MAGIC FIX: Hostinger ফায়ারওয়াল বাইপাস করার জন্য Fake Chrome User-Agent
      _controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-A205U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      );

      await _controller!.initialize();
      _controller!.setLooping(true);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isError = false;
        });
      }
    } catch (e) {
      debugPrint("🎥 Video Init Error: $e");
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ❌ Error State
    if (_isError) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, color: Colors.redAccent, size: 40),
            const SizedBox(height: 8),
            const Text("Video failed to load", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.videoUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Link copied! Paste in Chrome to test.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue)
                );
              },
              icon: const Icon(Icons.copy, size: 16, color: Colors.white),
              label: const Text("Copy Link", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    // ⏳ Loading State
    if (!_isInitialized || _controller == null) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            height: 30, width: 30,
            child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2.5),
          ),
        ),
      );
    }

    // ✅ Playing State
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: VideoPlayer(_controller!),
            ),
            if (!_controller!.value.isPlaying)
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