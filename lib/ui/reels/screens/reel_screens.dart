import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';
import '../profile_screens/screens/view_profile_screens.dart';

// ==========================================
// 1. DATA MODEL
// ==========================================
class VideoDataModel {
  final String url;
  final String title;
  final String channelName;
  final String views;
  final String likes;
  final String comments;
  final String timeAgo;
  final String duration;
  final String profileImage;
  final String bio;
  final String subscribers;
  final bool isVerified;
  final String premiumSubscribers;
  final String serviceOverview;
  final String clientFeedback;
  final String contactPrice;
  final List<String> freeContentImages;
  final List<String> premiumContentImages;

  VideoDataModel({
    required this.url,
    required this.title,
    required this.channelName,
    required this.views,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.duration,
    required this.profileImage,
    required this.bio,
    required this.subscribers,
    required this.freeContentImages,
    required this.premiumContentImages,
    required this.premiumSubscribers,
    required this.serviceOverview,
    required this.clientFeedback,
    required this.contactPrice,
    this.isVerified = false,
  });
}

// ==========================================
// 2. DATA HELPER
// ==========================================
class VideoDataHelper {
  static final List<String> _profileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  static final List<String> _girlNames = ["Sofia Rose", "Anika Vlogz", "Misty Night", "Bella X", "Desi Queen"];
  static final List<String> _titles = ["Viral Video 🔥", "Late night fun 🤫", "My new dance cover 💃", "Behind the scenes...", "Must Watch! 😱"];

  static List<String> _generateContentImages(int count, int seed) {
    return List.generate(count, (i) => "https://source.unsplash.com/random/300x400?sig=${seed + i}");
  }

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;
      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: _titles[random.nextInt(_titles.length)],
        channelName: _girlNames[random.nextInt(_girlNames.length)],
        profileImage: _profileImages[random.nextInt(_profileImages.length)],
        bio: "Content Creator ✨",
        views: "${(random.nextDouble() * 5 + 0.1).toStringAsFixed(1)}M",
        likes: "${random.nextInt(50) + 5}K",
        comments: "${random.nextInt(1000) + 100}",
        timeAgo: "${random.nextInt(23) + 1}h",
        duration: "0:30",
        subscribers: "1.2M",
        premiumSubscribers: "100K",
        serviceOverview: "Available for shoutouts",
        clientFeedback: "Great work!",
        contactPrice: "\$${random.nextInt(50) + 20}",
        isVerified: random.nextBool(),
        freeContentImages: _generateContentImages(5, index),
        premiumContentImages: _generateContentImages(5, index + 100),
      );
    });
  }
}

// ==========================================
// 3. REEL SCREENS (SMART FEED UI)
// ==========================================
class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  List<VideoDataModel> _allVideos = [];
  bool _isLoading = true;

  // Autoplay Logic
  int _focusedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  // ওয়েব এবং মোবাইলের জন্য আলাদা হাইট এস্টিমেশন
  double get _itemHeight => kIsWeb ? 600.0 : 500.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    // ডাইনামিক হাইট ক্যালকুলেশন করে ইনডেক্স বের করা
    final index = (offset / _itemHeight).round();

    if (_focusedIndex != index) {
      setState(() {
        _focusedIndex = index;
      });
    }
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    var list = VideoDataHelper.generateVideos(kIsWeb ? 30 : 50);
    list.shuffle();
    if (mounted) {
      setState(() {
        _allVideos = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildResponsiveAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF1877F2),
            child: _isLoading
                ? _buildShimmerLoading()
                : ListView.builder(
              controller: _scrollController,
              itemCount: _allVideos.length,
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: kIsWeb ? 800 : 1500,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FacebookVideoCard(
                    key: ValueKey(_allVideos[index].url),
                    videoData: _allVideos[index],
                    allVideosList: _allVideos.map((e) => e.url).toList(),
                    shouldPlay: index == _focusedIndex,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildResponsiveAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      titleSpacing: kIsWeb ? 20 : 0,
      title: const Text(
        "facebook",
        style: TextStyle(
          color: Color(0xFF1877F2),
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: -1.2,
        ),
      ),
      actions: [
        if (kIsWeb) ...[
          _webNavIcon(Icons.home, true),
          _webNavIcon(Icons.ondemand_video, false),
          _webNavIcon(Icons.storefront, false),
          _webNavIcon(Icons.group, false),
          const SizedBox(width: 20),
        ],
        _circleButton(Icons.search),
        _circleButton(Icons.chat_bubble),
        if(kIsWeb) _circleButton(Icons.refresh, onTap: _onRefresh),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _webNavIcon(IconData icon, bool isActive) {
    return Container(
      width: 80,
      height: double.infinity,
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Color(0xFF1877F2), width: 3)) : null,
      ),
      child: Icon(
        icon,
        color: isActive ? const Color(0xFF1877F2) : Colors.grey[600],
        size: 28,
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(height: 60, margin: const EdgeInsets.all(10), color: Colors.white),
                Container(height: 300, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. FACEBOOK VIDEO CARD (PRO FEATURES)
// ==========================================
class FacebookVideoCard extends StatefulWidget {
  final VideoDataModel videoData;
  final List<String> allVideosList;
  final bool shouldPlay;

  const FacebookVideoCard({
    super.key,
    required this.videoData,
    required this.allVideosList,
    required this.shouldPlay,
  });

  @override
  State<FacebookVideoCard> createState() => _FacebookVideoCardState();
}

class _FacebookVideoCardState extends State<FacebookVideoCard> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = true;

  // Animation States
  bool _showHeart = false; // Double tap heart
  bool _controlsVisible = true; // Auto hide controls
  Timer? _hideTimer;

  // Like Animation
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Heart Animation Setup
    _heartAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _heartScale = Tween<double>(begin: 0.0, end: 1.2).animate(
        CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut)
    );

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if(mounted) setState(() => _showHeart = false);
          _heartAnimationController.reset();
        });
      }
    });
  }

  @override
  void didUpdateWidget(FacebookVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldPlay != widget.shouldPlay) {
      if (widget.shouldPlay) {
        _controller?.play();
        _startHideTimer();
      } else {
        _controller?.pause();
      }
    }
  }

  void _initializeVideo() {
    String url = widget.videoData.url.replaceFirst("http://", "https://");
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          if (widget.shouldPlay) {
            _controller?.setVolume(_isMuted ? 0 : 1);
            _controller?.play();
            _controller?.setLooping(true);
            _startHideTimer();
          }
        }
      }).catchError((e) {
        debugPrint("Video Error: $e");
      });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if(mounted) setState(() => _controlsVisible = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller!.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _onDoubleTapLike() {
    // Show Heart Animation
    setState(() => _showHeart = true);
    _heartAnimationController.forward();

    // Haptic Feedback
    HapticFeedback.mediumImpact();

    // TODO: Call your Like API here
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0 : 1);
      _startHideTimer(); // Reset timer on interaction
    });
  }

  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller?.pause();
      setState(() => _controlsVisible = true); // Pause করলে কন্ট্রোল দেখাবে
    } else {
      _controller?.play();
      _startHideTimer();
    }
    setState(() {});
  }

  void _openFullScreen() {
    _controller?.pause();
    Get.to(() => AdWebViewScreen(
      adLink: AdsterraConfigs.monetagHomeLink,
      targetVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ))?.then((_) {
      if (widget.shouldPlay) _controller?.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _heartAnimationController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videoData;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: kIsWeb ? BorderRadius.circular(8) : null,
        boxShadow: kIsWeb ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))] : null,
      ),
      margin: EdgeInsets.only(bottom: kIsWeb ? 15 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: InkWell(
              onTap: () => Get.to(() => ProfileViewScreen(userData: video)),
              child: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
            ),
            title: InkWell(
              onTap: () => Get.to(() => ProfileViewScreen(userData: video)),
              child: Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            subtitle: Text("${video.timeAgo} · 🌎", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
              splashRadius: 20,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(video.title, style: const TextStyle(fontSize: 15)),
          ),

          const SizedBox(height: 5),

          // ✅ PRO VIDEO PLAYER AREA
          GestureDetector(
            onDoubleTap: _onDoubleTapLike,
            onTap: () {
              if(!_controlsVisible) {
                _startHideTimer(); // ট্যাপ করলে কন্ট্রোল আসবে
              } else {
                if(kIsWeb) _togglePlayPause(); // ওয়েবে ক্লিক করলে পজ
              }
            },
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _isInitialized
                  ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio > 1 ? _controller!.value.aspectRatio : 16/9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),

                    // 1. Big Animated Heart (Like)
                    if (_showHeart)
                      ScaleTransition(
                        scale: _heartScale,
                        child: const Icon(Icons.favorite, color: Colors.white, size: 100, shadows: [Shadow(color: Colors.black54, blurRadius: 10)]),
                      ),

                    // 2. Center Controls (Play/Pause) - Auto Hide
                    AnimatedOpacity(
                      opacity: _controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black26,
                        child: Center(
                          child: IconButton(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              size: 60,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Bottom Controls (Mute, Fullscreen, Progress)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Control Buttons Row
                          AnimatedOpacity(
                            opacity: _controlsVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Sound Button
                                  GestureDetector(
                                    onTap: _toggleMute,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                                      child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  // Fullscreen Button
                                  GestureDetector(
                                    onTap: _openFullScreen,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 4. Video Progress Bar (Thin Line)
                          VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.redAccent,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.transparent,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(
                  height: 350,
                  child: Center(child: CircularProgressIndicator(color: Colors.white))
              ),
            ),
          ),

          // Footer Actions
          _buildActionFooter(),
        ],
      ),
    );
  }

  Widget _buildActionFooter() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.thumb_up, size: 14, color: Color(0xFF1877F2)),
                SizedBox(width: 4),
                Text("1.2K"),
              ]),
              Text("25 Comments  •  10 Shares", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const Divider(height: 0, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionBtn(Icons.thumb_up_outlined, "Like"),
              _actionBtn(Icons.mode_comment_outlined, "Comment"),
              _actionBtn(Icons.share_outlined, "Share"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(5),
        hoverColor: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey[700], size: 20),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}