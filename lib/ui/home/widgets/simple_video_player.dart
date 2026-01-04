import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const SimpleVideoPlayer({super.key, required this.videoUrl});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

// ১. Mixin যুক্ত করা হলো যাতে স্ক্রল করলে ভিডিও বারবার রিলোড না হয়
class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _showIcon = true;

  @override
  void initState() {
    super.initState();
    // ভিডিও কনফিগারেশন
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // ৩. mounted চেক করা জরুরি (ল্যাগ ও ক্র্যাশ কমায়)
        if (mounted) {
          setState(() {
            _isInitialized = true;
            // ডিফল্ট ভলিউম সেট করা
            _controller.setLooping(true); // ভিডিও লুপে চলবে (ফেসবুকের মতো)
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isInitialized) return; // ইনিশিয়ালাইজ না হলে কাজ করবে না

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showIcon = true;
      } else {
        _controller.play();
        _isPlaying = true;
        _showIcon = false;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  // ২. KeepAlive এর জন্য এটা true করতে হবে
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Mixin এর জন্য এটা কল করতে হবে

    return Container(
      color: Colors.black, // লোড হওয়ার আগে কালো ব্যাকগ্রাউন্ড (Better UX)
      child: _isInitialized
          ? GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ১. ভিডিও লেয়ার (অপটিমাইজড)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                // এখানে ম্যানুয়াল SizedBox দরকার নেই, VideoPlayer নিজেই সাইজ হ্যান্ডেল করে
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

            // ২. প্লে আইকন (ফেসবুক স্টাইল)
            if (_showIcon)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),

            // ৩. সাউন্ড বাটন
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(
        // লোডিং এর সময় হালকা লোডার
        child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54
        ),
      ),
    );
  }
}