import 'dart:async';
import 'dart:math'; // 🔹 Random() ব্যবহারের জন্য
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/home/controllers/get_post_controllers.dart';

class ReelScreens extends StatefulWidget {
  final bool isTabActive; // 🔹 নতুন প্যারামিটার: ট্যাবটি বর্তমানে ওপেন আছে কিনা তা চেক করার জন্য

  const ReelScreens({super.key, this.isTabActive = true});

  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  late final GetPostController _postController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<GetPostModel> _shuffledReels = []; // র‍্যান্ডম রিলস রাখার লিস্ট
  bool _isShuffled = false; // বারবার যেন শাফেল না হয় তার ফ্ল্যাগ

  @override
  void initState() {
    super.initState();
    _postController = Get.isRegistered<GetPostController>() ? Get.find<GetPostController>() : Get.put(GetPostController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 900;
          double feedWidth = isWideScreen ? 450 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: isWideScreen ? 1000 : constraints.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: feedWidth,
                    height: constraints.maxHeight,
                    child: Obx(() {
                      if (_postController.isLoading.value && _postController.posts.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      // 🔹 শুধুমাত্র ভিডিও ফিল্টার করা
                      List<GetPostModel> currentVideos = _postController.posts.where((post) {
                        String url = post.directUrl ?? post.image_url ?? "";
                        return url.toLowerCase().endsWith('.mp4') || post.isDirectLink == true;
                      }).toList();

                      if (currentVideos.isEmpty) {
                        _isShuffled = false;
                        return const Center(child: Text("No reels found.", style: TextStyle(color: Colors.white)));
                      }

                      // 🔹 ভিডিওগুলো র‍্যান্ডমলি সাজানো (শুধু একবার শাফেল হবে)
                      if (!_isShuffled && currentVideos.isNotEmpty) {
                        currentVideos.shuffle(Random());
                        _shuffledReels = currentVideos;
                        _isShuffled = true;
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await _postController.refreshPosts();
                          setState(() => _isShuffled = false); // রিফ্রেশ করলে আবার নতুন করে শাফেল হবে
                        },
                        color: Colors.white,
                        backgroundColor: Colors.black,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.vertical,
                              itemCount: _shuffledReels.length + (_postController.isMoreDataLoading.value ? 1 : 0),
                              onPageChanged: (index) {
                                setState(() => _currentIndex = index);
                                if (index == _shuffledReels.length - 1 && _postController.hasMoreData) {
                                  _postController.loadMorePosts();
                                }
                              },
                              itemBuilder: (context, index) {
                                if (index == _shuffledReels.length) {
                                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                                }
                                return TikTokVideoCard(
                                  key: ValueKey(_shuffledReels[index].post_id),
                                  postData: _shuffledReels[index],
                                  // 🔹 ট্যাব অ্যাক্টিভ থাকলে এবং বর্তমান পেজ হলেই ভিডিও প্লে হবে
                                  isVisible: widget.isTabActive && _currentIndex == index,
                                );
                              },
                            ),

                            // --- Top App Bar Overlay ---
                            Positioned(
                              top: 0, left: 0, right: 0,
                              child: Container(
                                height: 100,
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black54, Colors.transparent],
                                    )
                                ),
                                child: SafeArea(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(width: 48),
                                      Text("Reels", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                      IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.white), onPressed: () {})
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  ),

                  // --- RIGHT SIDEBAR (Web Only) ---
                  if (isWideScreen)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 20),
                      color: Colors.white,
                      child: const Center(child: Text("Suggestions Here")),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 🔹 TIKTOK STYLE VIDEO CARD
// ==========================================
class TikTokVideoCard extends StatefulWidget {
  final GetPostModel postData;
  final bool isVisible;

  const TikTokVideoCard({
    super.key,
    required this.postData,
    required this.isVisible,
  });

  @override
  State<TikTokVideoCard> createState() => _TikTokVideoCardState();
}

class _TikTokVideoCardState extends State<TikTokVideoCard> with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBroken = false;
  bool _isLiked = false;
  bool _isPlaying = false;
  bool _showPauseIcon = false;

  late AnimationController _heartAnimationController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.postData.isLiked;
    _initializeVideo();
    _setupAnimation();
  }

  // 🔹 ট্যাব পরিবর্তন বা সোয়াইপ করার সময় প্লে/পজ লজিক
  @override
  void didUpdateWidget(covariant TikTokVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && _isInitialized) {
      if (widget.isVisible && !oldWidget.isVisible) {
        _controller?.play();
        setState(() => _isPlaying = true);
      } else if (!widget.isVisible && oldWidget.isVisible) {
        _controller?.pause();
        setState(() => _isPlaying = false);
      }
    }
  }

  void _setupAnimation() {
    _heartAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _heartScale = Tween<double>(begin: 0.0, end: 1.2).animate(CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut));
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showHeart = false);
          _heartAnimationController.reset();
        });
      }
    });
  }

  void _initializeVideo() {
    String videoUrl = widget.postData.directUrl ?? widget.postData.image_url ?? "";
    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isBroken = false;
          });
          _controller?.setLooping(true);
          // শুধুমাত্র যদি ট্যাবটি অ্যাক্টিভ থাকে তবেই ভিডিও প্লে শুরু হবে
          if (widget.isVisible) {
            _controller?.play();
            setState(() => _isPlaying = true);
          }
        }
      }).catchError((e) {
        debugPrint("Video Error: $e");
        if (mounted) setState(() => _isBroken = true);
      });
    } else {
      setState(() => _isBroken = true);
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller?.pause();
          _isPlaying = false;
          _showPauseIcon = true;
        } else {
          _controller?.play();
          _isPlaying = true;
          _showPauseIcon = false;
        }
      });

      if (!_isPlaying) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _showPauseIcon = false);
        });
      }
    }
  }

  void _onDoubleTapLike() {
    setState(() {
      _showHeart = true;
      _isLiked = true;
    });
    _heartAnimationController.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller?.pause(); // ডিসপোজ করার আগে নিশ্চিত পজ করে দেওয়া
    _controller?.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBroken) {
      return Container(color: Colors.black, child: const Center(child: Text("Video Unavailable", style: TextStyle(color: Colors.white54))));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          onDoubleTap: _onDoubleTapLike,
          child: _isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
              : const Center(child: CircularProgressIndicator(color: Colors.white30)),
        ),

        if (!_isPlaying && _isInitialized)
          IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 60),
              ),
            ),
          ),

        if (_showHeart)
          IgnorePointer(
            child: Center(
              child: ScaleTransition(
                scale: _heartScale,
                child: const Icon(Icons.favorite, color: Colors.redAccent, size: 120),
              ),
            ),
          ),

        if (_isInitialized)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: const VideoProgressColors(playedColor: Colors.white, bufferedColor: Colors.white24, backgroundColor: Colors.transparent),
              padding: const EdgeInsets.symmetric(vertical: 2),
            ),
          ),

        Positioned(
          bottom: 20, left: 15, right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("@${widget.postData.username ?? "user"}", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (widget.postData.post_content != null)
                Text(widget.postData.post_content!, style: GoogleFonts.inter(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),

        Positioned(
          bottom: 40, right: 10,
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: CachedNetworkImageProvider(widget.postData.profile_picture_url ?? "https://via.placeholder.com/150"),
              ),
              const SizedBox(height: 25),
              _ActionIcon(icon: Icons.favorite, color: _isLiked ? Colors.redAccent : Colors.white, label: "${widget.postData.like_count}", onTap: () {
                setState(() => _isLiked = !_isLiked);
                HapticFeedback.lightImpact();
              }),
              const SizedBox(height: 20),
              _ActionIcon(icon: Icons.chat_bubble_rounded, color: Colors.white, label: "${widget.postData.comment_count}", onTap: () {}),
              const SizedBox(height: 20),
              _ActionIcon(icon: Icons.reply_rounded, color: Colors.white, label: "Share", onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 36, shadows: const [Shadow(color: Colors.black45, blurRadius: 5)]),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black54, blurRadius: 3)])),
        ],
      ),
    );
  }
}