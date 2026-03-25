import 'dart:async';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ API Model & Controller
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/home/controllers/get_post_controllers.dart';

// ==========================================
// 1. REEL SCREENS (TIKTOK STYLE)
// ==========================================
class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  final GetPostController _postController = Get.put(GetPostController());
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // TikTok style background
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 900;

          // ওয়েবের জন্য সেন্টার ফিডের সাইজ একটু ছোট রাখবো যেন ফোনের মতো লাগে
          double feedWidth = isWideScreen ? 450 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: isWideScreen ? 1000 : constraints.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CENTER FEED (TIKTOK PAGE VIEW) ---
                  SizedBox(
                    width: feedWidth,
                    height: constraints.maxHeight, // Full Height
                    child: Obx(() {
                      if (_postController.isLoading.value && _postController.posts.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (_postController.hasError.value && _postController.posts.isEmpty) {
                        return Center(
                          child: Text(
                            _postController.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      // 🔹 শুধুমাত্র ভিডিও পোস্ট ফিল্টার করা
                      List<GetPostModel> videoPosts = _postController.posts.where((post) {
                        String url = post.directUrl ?? post.image_url ?? "";
                        return url.toLowerCase().endsWith('.mp4') || post.isDirectLink == true;
                      }).toList();

                      if (videoPosts.isEmpty) {
                        return const Center(child: Text("No reels found.", style: TextStyle(color: Colors.white)));
                      }

                      return RefreshIndicator(
                        onRefresh: _postController.refreshPosts,
                        color: Colors.white,
                        backgroundColor: Colors.black,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.vertical, // 🔹 Vertical Swipe (TikTok style)
                              itemCount: videoPosts.length + (_postController.isMoreDataLoading.value ? 1 : 0),
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                                // 🔹 একদম শেষে চলে আসলে নতুন ডেটা লোড করবে
                                if (index == videoPosts.length - 1 && _postController.hasMoreData) {
                                  _postController.loadMorePosts();
                                }
                              },
                              itemBuilder: (context, index) {
                                if (index == videoPosts.length) {
                                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                                }
                                return TikTokVideoCard(
                                  key: ValueKey(videoPosts[index].post_id),
                                  postData: videoPosts[index],
                                  isVisible: _currentIndex == index, // 🔹 শুধু দৃশ্যমান ভিডিওটি প্লে হবে
                                );
                              },
                            ),

                            // --- Top Gradient & App Bar Overlay ---
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
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
                                      const SizedBox(width: 48), // Balancing space
                                      Text(
                                        "Reels",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                                        onPressed: () {}, // ক্যামেরা বা ক্রিয়েট অপশন
                                      )
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Suggested Creators",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 24),
                            const Divider(),
                            // ডামি সাজেশন লিস্ট
                            ...List.generate(3, (index) => ListTile(
                              leading: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=${index + 20}")),
                              title: Text("Creator ${index + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              subtitle: const Text("Verified Creator"),
                              trailing: TextButton(onPressed: () {}, child: const Text("Follow")),
                            ))
                          ],
                        ),
                      ),
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
// 2. TIKTOK STYLE VIDEO CARD (Overlay UI)
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
  bool _isPlaying = true;

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

  // 🔹 PageView-এ স্ক্রল করার সময় ভিডিও প্লে/পজ করার লজিক
  @override
  void didUpdateWidget(covariant TikTokVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null && _isInitialized) {
      if (widget.isVisible && !oldWidget.isVisible) {
        _controller?.play();
        _isPlaying = true;
      } else if (!widget.isVisible && oldWidget.isVisible) {
        _controller?.pause();
        _controller?.seekTo(Duration.zero); // অপশনাল: ভিডিও শুরুতে নিয়ে আসা
        _isPlaying = false;
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
          // যদি প্রথমে স্ক্রিনে থাকে তবেই প্লে হবে
          if (widget.isVisible) {
            _controller?.play();
            _isPlaying = true;
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
        } else {
          _controller?.play();
          _isPlaying = true;
        }
      });
    }
  }

  void _onDoubleTapLike() {
    setState(() {
      _showHeart = true;
      _isLiked = true;
    });
    // API Call for Like here
    _heartAnimationController.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBroken) {
      return Container(
        color: Colors.black,
        child: const Center(child: Text("Video Unavailable", style: TextStyle(color: Colors.white54))),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _onDoubleTapLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. VIDEO PLAYER ---
          _isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover, // TikTok-এর মতো পুরো স্ক্রিন জুড়ে থাকবে
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
              : const Center(child: CircularProgressIndicator(color: Colors.white30)),

          // --- Play/Pause Indicator Overlay ---
          if (!_isPlaying && _isInitialized)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 80),
              ),
            ),

          // --- Double Tap Heart Animation ---
          if (_showHeart)
            Center(
              child: ScaleTransition(
                scale: _heartScale,
                child: const Icon(Icons.favorite, color: Colors.redAccent, size: 120, shadows: [Shadow(color: Colors.black45, blurRadius: 15)]),
              ),
            ),

          // --- Bottom Gradient (For readable text) ---
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 250,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // --- 2. BOTTOM LEFT (INFO) ---
          Positioned(
            bottom: 20,
            left: 15,
            right: 80, // ডানদিকের আইকনগুলোর জন্য জায়গা রাখা
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${widget.postData.username ?? "user"}",
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (widget.postData.post_content != null && widget.postData.post_content!.isNotEmpty)
                  Text(
                    widget.postData.post_content!,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text("Original Audio - ${widget.postData.username ?? "user"}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                )
              ],
            ),
          ),

          // --- 3. BOTTOM RIGHT (ACTIONS) ---
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                // Profile Picture
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(widget.postData.profile_picture_url ?? "https://via.placeholder.com/150"),
                  ),
                ),
                const SizedBox(height: 20),

                // Like
                _ActionIcon(
                  icon: Icons.favorite,
                  color: _isLiked ? Colors.redAccent : Colors.white,
                  label: "${widget.postData.like_count}",
                  onTap: () {
                    setState(() => _isLiked = !_isLiked);
                    HapticFeedback.lightImpact();
                  },
                ),
                const SizedBox(height: 20),

                // Comment
                _ActionIcon(
                  icon: Icons.chat_bubble_rounded,
                  color: Colors.white,
                  label: "${widget.postData.comment_count}",
                  onTap: () {
                    // Show Comment Bottom Sheet
                  },
                ),
                const SizedBox(height: 20),

                // Share
                _ActionIcon(
                  icon: Icons.reply_rounded, // TikTok style share icon
                  color: Colors.white,
                  label: "Share",
                  onTap: () {
                    Share.share("Check out this reel: https://meetyarah.com/?post_id=${widget.postData.post_id}");
                  },
                ),
                const SizedBox(height: 20),

                // Music Disc Animation (Static for now)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Action Icon Widget
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