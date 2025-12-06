import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ Ensure these paths match your project structure
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
// 2. DATA HELPER (RICH DUMMY DATA)
// ==========================================
class VideoDataHelper {
  // Profile Pictures
  static final List<String> _profileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  static final List<String> _names = [
    "Sofia Rose", "Anika Vlogz", "Misty Night", "Bella X", "Desi Queen", "Ryan Star", "Zara Life"
  ];
  static final List<String> _titles = [
    "Viral Video 🔥", "Late night fun 🤫", "My new dance cover 💃", "Behind the scenes...", "Must Watch! 😱"
  ];

  // Bio Data
  static final List<String> _bios = [
    "💃 Professional Dancer & Choreographer.\n✨ Creating magic with moves.\n👇 Subscribe for exclusive tutorials!",
    "📸 Travel Vlogger exploring the world.\n✈️ Catch me if you can!\n❤️ Love to meet new people.",
    "Fitness Coach & Model 💪\nHelping you get in shape.\nDM for personalized diet plans! 🥗",
    "Digital Artist & Content Creator 🎨\nSharing my daily life and art.\nThanks for the support! ✨",
    "Just a girl living her dream. 💖\nFashion | Lifestyle | Beauty\nBusiness inquiries available via button above."
  ];

  // Service Overview
  static final List<String> _services = [
    "I offer shoutouts, personalized dance videos, and 1-on-1 video calls. Join my premium to see exclusive behind-the-scenes content!",
    "Available for brand collaborations, modeling shoots, and travel guidance. Check my premium for uncensored travel vlogs.",
    "Personal diet plans, workout routines, and motivational calls. Premium members get daily updates!",
    "Custom artwork requests, digital portrait drawing, and art tutorials available."
  ];

  // Gallery Image Generator
  static List<String> _generateImages(int count, int seed) {
    return List.generate(count, (i) => "https://picsum.photos/seed/${seed + i}/400/600");
  }

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;
      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: _titles[random.nextInt(_titles.length)],
        channelName: _names[random.nextInt(_names.length)],
        profileImage: _profileImages[random.nextInt(_profileImages.length)],
        bio: _bios[random.nextInt(_bios.length)],
        serviceOverview: _services[random.nextInt(_services.length)],
        views: "${(random.nextDouble() * 5 + 0.1).toStringAsFixed(1)}M",
        likes: "${random.nextInt(50) + 5}K",
        comments: "${random.nextInt(1000) + 100}",
        subscribers: "${(random.nextDouble() * 2 + 0.5).toStringAsFixed(1)}M",
        premiumSubscribers: "${random.nextInt(50) + 10}K",
        contactPrice: "\$${random.nextInt(50) + 20}",
        timeAgo: "${random.nextInt(23) + 1}h",
        duration: "0:30",
        clientFeedback: "Amazing content!",
        isVerified: random.nextBool(),
        freeContentImages: _generateImages(9, index * 10),
        premiumContentImages: _generateImages(12, index * 20),
      );
    });
  }
}

// ==========================================
// 3. REEL SCREENS (MAIN FEED UI)
// ==========================================
class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  List<VideoDataModel> _allVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    var list = VideoDataHelper.generateVideos(kIsWeb ? 50 : 50);

    // 🔥🔥 MAIN LOGIC: URL Parameter Check & Reorder 🔥🔥
    if (kIsWeb) {
      try {
        String? targetPostId = Uri.base.queryParameters['post_id'];
        if (targetPostId != null && targetPostId.isNotEmpty) {
          debugPrint("Found Post ID in URL: $targetPostId");
          int targetIndex = list.indexWhere((video) => video.url.contains(targetPostId));
          if (targetIndex != -1) {
            var targetVideo = list.removeAt(targetIndex);
            list.insert(0, targetVideo);
            debugPrint("Video Moved to Top: $targetPostId");
          }
        } else {
          list.shuffle();
        }
      } catch (e) {
        debugPrint("Error processing URL parameters: $e");
        list.shuffle();
      }
    } else {
      list.shuffle();
    }

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
      appBar: _buildModernAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF1877F2),
            child: _isLoading
                ? _buildShimmerLoading()
                : ListView.builder(
              cacheExtent: kIsWeb ? 800 : 1500,
              itemCount: _allVideos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FacebookVideoCard(
                    key: ValueKey(_allVideos[index].url),
                    videoData: _allVideos[index],
                    allVideosList: _allVideos.map((e) => e.url).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
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
        _circleButton(Icons.search),
        _circleButton(Icons.chat_bubble),
        if (kIsWeb) _circleButton(Icons.refresh, onTap: _onRefresh),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 22),
        onPressed: onTap ?? () {},
        splashRadius: 20,
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
                Container(height: 350, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. FACEBOOK VIDEO CARD
// ==========================================
class FacebookVideoCard extends StatefulWidget {
  final VideoDataModel videoData;
  final List<String> allVideosList;

  const FacebookVideoCard({
    super.key,
    required this.videoData,
    required this.allVideosList,
  });

  @override
  State<FacebookVideoCard> createState() => _FacebookVideoCardState();
}

class _FacebookVideoCardState extends State<FacebookVideoCard> with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPreviewing = false;
  bool _isNavigating = false;
  bool _isLiked = false;
  String _selectedReaction = "Like";

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

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
    String url = widget.videoData.url.replaceFirst("http://", "https://");
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller?.setVolume(0);
          _controller?.addListener(_previewTimeListener);
        }
      }).catchError((e) {
        debugPrint("Video Error: $e");
      });
  }

  void _previewTimeListener() {
    if (_controller == null || !_controller!.value.isInitialized || _isNavigating) return;
    if (_controller!.value.isPlaying && _isPreviewing) {
      if (_controller!.value.position.inSeconds >= 7) {
        _isNavigating = true;
        _stopPreview();
        _openFullScreen();
      }
    }
  }

  void _startPreview() {
    if (_controller != null && _isInitialized) {
      HapticFeedback.selectionClick();
      setState(() => _isPreviewing = true);
      _controller?.play();
    }
  }

  void _stopPreview() {
    if (_controller != null && _isInitialized) {
      setState(() => _isPreviewing = false);
      _controller?.pause();
    }
  }

  void _openFullScreen() {
    _stopPreview();
    if (mounted) setState(() => _isNavigating = true);
    Get.to(() => AdWebViewScreen(
      adLink: AdsterraConfigs.monetagHomeLink,
      targetVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ))?.then((_) {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    });
  }

  void _openCommentLinkInBrowser() async {
    final Uri url = Uri.parse(AdsterraConfigs.monetagHomeLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  void _sharePostUrl() {
    String shareUrl = widget.videoData.url;
    if (kIsWeb) {
      try {
        String videoId = widget.videoData.url.split('/id/').last.split('.').first;
        String appDomain = Uri.base.origin;
        shareUrl = "$appDomain/?post_id=$videoId";
      } catch (e) {
        debugPrint("Error generating share link: $e");
        shareUrl = Uri.base.toString();
      }
    }
    Share.share("Check out this video: $shareUrl");
  }

  void _onDoubleTapLike() {
    setState(() {
      _showHeart = true;
      _isLiked = true;
      _selectedReaction = "Love";
    });
    _heartAnimationController.forward();
    HapticFeedback.mediumImpact();
  }

  Widget _getReactionButtonIcon() {
    if (!_isLiked) return Icon(Icons.thumb_up_alt_outlined, color: Colors.grey[700], size: 20);
    switch (_selectedReaction) {
      case 'Love': return const Text('❤️', style: TextStyle(fontSize: 20));
      case 'Haha': return const Text('😆', style: TextStyle(fontSize: 20));
      case 'Wow': return const Text('😮', style: TextStyle(fontSize: 20));
      case 'Sad': return const Text('😢', style: TextStyle(fontSize: 20));
      case 'Angry': return const Text('😡', style: TextStyle(fontSize: 20));
      default: return const Icon(Icons.thumb_up, color: Color(0xFF1877F2), size: 20);
    }
  }

  Color _getReactionTextColor() {
    if (!_isLiked) return Colors.grey[700]!;
    switch (_selectedReaction) {
      case 'Love': return const Color(0xFFE0245E);
      case 'Haha':
      case 'Wow':
      case 'Sad': return const Color(0xFFF7B125);
      case 'Angry': return const Color(0xFFE4405F);
      default: return const Color(0xFF1877F2);
    }
  }

  void _showReactionMenu() {
    HapticFeedback.mediumImpact();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.center,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimatedReactionItem("Like", const Icon(Icons.thumb_up, color: Color(0xFF1877F2), size: 30)),
              _buildAnimatedReactionItem("Love", const Text('❤️', style: TextStyle(fontSize: 30))),
              _buildAnimatedReactionItem("Haha", const Text('😆', style: TextStyle(fontSize: 30))),
              _buildAnimatedReactionItem("Wow", const Text('😮', style: TextStyle(fontSize: 30))),
              _buildAnimatedReactionItem("Sad", const Text('😢', style: TextStyle(fontSize: 30))),
              _buildAnimatedReactionItem("Angry", const Text('😡', style: TextStyle(fontSize: 30))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedReactionItem(String name, Widget icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLiked = true;
          _selectedReaction = name;
        });
        Get.back();
        HapticFeedback.lightImpact();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: icon,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_previewTimeListener);
    _controller?.dispose();
    _pulseController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videoData;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: kIsWeb ? BorderRadius.circular(12) : null,
        boxShadow: kIsWeb ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))] : null,
      ),
      margin: EdgeInsets.only(bottom: kIsWeb ? 15 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Navigation to Profile
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: InkWell(
              onTap: () => Get.to(() => ProfileViewScreen(userData: video)), // ✅ Navigate to Profile
              child: Hero(
                tag: video.url + video.channelName,
                child: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
              ),
            ),
            title: InkWell(
              onTap: () => Get.to(() => ProfileViewScreen(userData: video)), // ✅ Navigate to Profile
              child: Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            subtitle: Text("${video.timeAgo} · 🌎", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            trailing: const Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(video.title, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 5),

          // Interactive Video Area
          GestureDetector(
            onLongPressStart: (_) => _startPreview(),
            onLongPressEnd: (_) => _stopPreview(),
            onTap: _openFullScreen,
            onDoubleTap: _onDoubleTapLike,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _isInitialized
                  ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio > 1 ? _controller!.value.aspectRatio : 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ),
                    if (!_isPreviewing)
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2)),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 45),
                        ),
                      ),
                    if (_isPreviewing)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                          child: const Text("Preview Mode", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (_showHeart)
                      ScaleTransition(
                        scale: _heartScale,
                        child: const Icon(Icons.favorite, color: Colors.white, size: 100, shadows: [Shadow(color: Colors.black54, blurRadius: 20)]),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: false,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF1877F2),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.transparent,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(height: 350, child: Center(child: CircularProgressIndicator(color: Colors.white))),
            ),
          ),

          // Stats Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _getReactionButtonIcon(),
                  const SizedBox(width: 4),
                  Text(!_isLiked ? "1.2K" : "You and 1.2K others", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ]),
                const Text("25 Comments  •  10 Shares", style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isLiked) {
                          _isLiked = false;
                          _selectedReaction = "Like";
                        } else {
                          _isLiked = true;
                          _selectedReaction = "Like";
                        }
                      });
                      HapticFeedback.lightImpact();
                    },
                    onLongPress: _showReactionMenu,
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getReactionButtonIcon(),
                          const SizedBox(width: 6),
                          Text(_selectedReaction, style: TextStyle(color: _getReactionTextColor(), fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _openCommentLinkInBrowser,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mode_comment_outlined, color: Colors.grey[700], size: 22),
                          const SizedBox(width: 6),
                          Text("Comment", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _sharePostUrl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_outlined, color: Colors.grey[700], size: 22),
                          const SizedBox(width: 6),
                          Text("Share", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
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