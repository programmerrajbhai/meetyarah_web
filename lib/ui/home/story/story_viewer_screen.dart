import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryViewerScreen extends StatefulWidget {
  final List stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  late int index;
  Timer? _timer;

  // per story duration (image/text)
  static const Duration storyDuration = Duration(seconds: 6);
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
    _pageController = PageController(initialPage: index);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    progress = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      setState(() {
        progress += 0.01;
        if (progress >= 1) {
          progress = 1;
          _next();
        }
      });
    });
  }

  void _pause() => _timer?.cancel();
  void _resume() => _startTimer();

  void _next() {
    if (index >= widget.stories.length - 1) {
      Get.back();
      return;
    }
    index++;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
    _startTimer();
  }

  void _prev() {
    if (index <= 0) return;
    index--;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _pause(),
      onLongPressEnd: (_) => _resume(),
      onVerticalDragUpdate: (d) {
        if (d.primaryDelta != null && d.primaryDelta! > 12) Get.back(); // swipe down close
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.stories.length,
                onPageChanged: (i) {
                  index = i;
                  _startTimer();
                },
                itemBuilder: (context, i) {
                  final story = widget.stories[i];

                  final String mediaType =
                  (story['media_type'] ?? "image").toString(); // image/video/text
                  final String mediaUrl =
                  (story['media_url'] ?? story['image_url'] ?? "").toString();
                  final String thumb =
                  (story['thumbnail_url'] ?? "").toString();
                  final String text =
                  (story['text'] ?? story['story_text'] ?? "").toString();

                  if (mediaType == "text") {
                    return _TextStoryView(text: text);
                  }

                  if (mediaType == "video") {
                    return _VideoThumbView(
                      thumbnailUrl: thumb,
                      videoUrl: mediaUrl,
                    );
                  }

                  // default image
                  return _ImageStoryView(url: mediaUrl);
                },
              ),

              // tap zones (prev/next)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _prev,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _next,
                      ),
                    ),
                  ],
                ),
              ),

              // top UI (progress + header)
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    _ProgressBars(
                      count: widget.stories.length,
                      activeIndex: index,
                      activeProgress: progress,
                    ),
                    const SizedBox(height: 10),
                    _HeaderBar(story: widget.stories[index]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double activeProgress;

  const _ProgressBars({
    required this.count,
    required this.activeIndex,
    required this.activeProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final double value = i < activeIndex
            ? 1
            : (i == activeIndex ? activeProgress : 0);

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final dynamic story;
  const _HeaderBar({required this.story});

  @override
  Widget build(BuildContext context) {
    final String name = (story['username'] ?? "User").toString();
    final String userImg = (story['profile_picture_url'] ?? "").toString();

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[800],
          backgroundImage: userImg.isNotEmpty ? NetworkImage(userImg) : null,
          child: userImg.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}

class _ImageStoryView extends StatelessWidget {
  final String url;
  const _ImageStoryView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: url.isEmpty
          ? const Icon(Icons.broken_image, color: Colors.white, size: 70)
          : Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (ctx, child, p) {
          if (p == null) return child;
          return const CircularProgressIndicator(color: Colors.white);
        },
        errorBuilder: (ctx, e, s) =>
        const Icon(Icons.broken_image, color: Colors.white, size: 70),
      ),
    );
  }
}

/// ✅ Video = show thumbnail only + play button overlay (FB like)
class _VideoThumbView extends StatelessWidget {
  final String thumbnailUrl;
  final String videoUrl;

  const _VideoThumbView({
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: thumbnailUrl.isNotEmpty
              ? Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _fallback(),
          )
              : _fallback(),
        ),
        Center(
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 2),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 45),
          ),
        ),
        // optional: tap play -> you can open video player screen
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // If you want, here you can navigate to a video player screen.
                // For now just show a message.
                Get.snackbar("Video", "Video URL: $videoUrl",
                    backgroundColor: Colors.black87,
                    colorText: Colors.white);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white70, size: 90),
      ),
    );
  }
}

class _TextStoryView extends StatelessWidget {
  final String text;
  const _TextStoryView({required this.text});

  @override
  Widget build(BuildContext context) {
    final showText = text.trim().isEmpty ? "Text Story" : text.trim();

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFFC837)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          showText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 28,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
