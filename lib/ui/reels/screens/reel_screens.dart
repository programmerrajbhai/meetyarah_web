import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts

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
  static final List<String> _profileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  static final List<String> _names = [
    "Sofia Rose",
    "Anika Vlogz",
    "Misty Night",
    "Bella X",
    "Desi Queen",
    "Ryan Star",
    "Zara Life"
  ];

  static final List<String> _titles = [
    "Viral Video 🔥",
    "Late night fun 🤫",
    "My new dance cover 💃",
    "Behind the scenes...",
    "Must Watch! 😱"
  ];

  static final List<String> _bios = [
    "💃 Professional Dancer & Choreographer.\n✨ Creating magic with moves.\n👇 Subscribe for exclusive tutorials!",
    "📸 Travel Vlogger exploring the world.\n✈️ Catch me if you can!\n❤️ Love to meet new people.",
    "Fitness Coach & Model 💪\nHelping you get in shape.\nDM for personalized diet plans! 🥗",
    "Digital Artist & Content Creator 🎨\nSharing my daily life and art.\nThanks for the support! ✨",
    "Just a girl living her dream. 💖\nFashion | Lifestyle | Beauty\nBusiness inquiries available via button above."
  ];

  static final List<String> _services = [
    "I offer shoutouts, personalized dance videos, and 1-on-1 video calls. Join my premium to see exclusive behind-the-scenes content!",
    "Available for brand collaborations, modeling shoots, and travel guidance. Check my premium for uncensored travel vlogs.",
    "Personal diet plans, workout routines, and motivational calls. Premium members get daily updates!",
    "Custom artwork requests, digital portrait drawing, and art tutorials available."
  ];

  static List<String> _generateImages(int count, int seed) => List.generate(
      count, (i) => "https://picsum.photos/seed/${seed + i}/400/600");

  static List<VideoDataModel> generateAllVideos() {
    List<VideoDataModel> allVideos = [];
    var random = Random();

    var ranges = [
      {
        'server': 'https://server15.mmsbee1.xyz/uploads/myfiless/id/',
        'min': 64500,
        'max': 64600
      },
      {
        'server': 'https://server15.mmsbee1.xyz/uploads/myfiless/id/',
        'min': 65500,
        'max': 65600
      },
      {
        'server': 'https://server15.mmsbee1.xyz/uploads/myfiless/id/',
        'min': 65696,
        'max': 65800
      },
      {
        'server': 'https://server24.mmsbee1.xyz/uploads/myfiless/id/',
        'min': 45300,
        'max': 46130
      },
    ];

    for (var range in ranges) {
      String server = range['server'] as String;
      int min = range['min'] as int;
      int max = range['max'] as int;

      for (int id = min; id <= max; id++) {
        String randomService = _services.isNotEmpty
            ? _services[random.nextInt(_services.length)]
            : "Exclusive content available.";

        allVideos.add(VideoDataModel(
          url: '$server$id.mp4',
          title: _titles[random.nextInt(_titles.length)],
          channelName: _names[random.nextInt(_names.length)],
          profileImage: _profileImages[random.nextInt(_profileImages.length)],
          bio: _bios[random.nextInt(_bios.length)],
          serviceOverview: randomService,
          views: "${(random.nextDouble() * 5 + 0.1).toStringAsFixed(1)}M",
          likes: "${random.nextInt(50) + 5}K",
          comments: "${random.nextInt(1000) + 100}",
          subscribers: "${(random.nextDouble() * 2 + 0.5).toStringAsFixed(1)}M",
          premiumSubscribers: "${random.nextInt(50) + 10}K",
          contactPrice: "\$${random.nextInt(50) + 20}",
          timeAgo: "${random.nextInt(23) + 1}h",
          duration: "0:30",
          clientFeedback: "Amazing content!",
          isVerified: random.nextBool(), // Random verified status
          freeContentImages: _generateImages(9, id),
          premiumContentImages: _generateImages(12, id + 1000),
        ));
      }
    }

    allVideos.shuffle();
    return allVideos;
  }
}

// ==========================================
// 3. REEL SCREENS (UPDATED PROFESSIONAL UI)
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
    var list = VideoDataHelper.generateAllVideos();

    // ✅ Deep Linking Logic
    if (kIsWeb) {
      try {
        String? targetPostId = Uri.base.queryParameters['post_id'];
        if (targetPostId != null && targetPostId.isNotEmpty) {
          int targetIndex =
              list.indexWhere((video) => video.url.contains(targetPostId));
          if (targetIndex != -1) {
            var targetVideo = list.removeAt(targetIndex);
            list.insert(0, targetVideo);
            debugPrint("Deep Link Video Found and moved to top");
          }
        }
      } catch (e) {
        debugPrint("Error parsing post ID: $e");
      }
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
      backgroundColor: kIsWeb ? const Color(0xFFF0F2F5) : Colors.white,
      appBar: _buildModernAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 900;
          double feedWidth = isWideScreen ? 600 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: isWideScreen ? 1000 : constraints.maxWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CENTER FEED ---
                  SizedBox(
                    width: feedWidth,
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: const Color(0xFF1877F2),
                      backgroundColor: Colors.white,
                      child: _isLoading
                          ? _buildShimmerLoading()
                          : ListView.separated(
                              cacheExtent: kIsWeb ? 800 : 1500,
                              itemCount: _allVideos.length,
                              padding: EdgeInsets.only(
                                  bottom: 20, top: kIsWeb ? 20 : 0),
                              separatorBuilder: (context, index) => kIsWeb
                                  ? const SizedBox(height: 16)
                                  : const Divider(
                                      thickness: 8, color: Color(0xFFF0F2F5)),
                              itemBuilder: (context, index) {
                                return FacebookVideoCard(
                                  key: ValueKey(_allVideos[index].url),
                                  videoData: _allVideos[index],
                                  allVideosList:
                                      _allVideos.map((e) => e.url).toList(),
                                );
                              },
                            ),
                    ),
                  ),

                  // --- RIGHT SIDEBAR (Web Only) ---
                  if (isWideScreen)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sponsored",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 12),
                            _buildSidebarAd(300),
                            const SizedBox(height: 24),
                            const Divider(),
                            _buildSuggestionList(),
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

  AppBar _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      titleSpacing: 16,
      title: Text(
        "Watch",
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      actions: [
        _circleButton(Icons.search),
        _circleButton(Icons.person_outline),
        if (kIsWeb) _circleButton(Icons.refresh, onTap: _onRefresh),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200)),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.black87, size: 22),
        onPressed: onTap ?? () {},
        splashRadius: 20,
      ),
    );
  }

  Widget _buildSidebarAd(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.public, color: Colors.blueAccent, size: 40),
            SizedBox(height: 8),
            Text("Advertisement",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Suggested Creators",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey[800])),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=${index + 10}")),
            title: Text("Creator ${index + 1}",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: const Text("New video posted"),
            trailing: TextButton(
              onPressed: () {},
              child: const Text("Follow"),
            ),
          ),
        )
      ],
    );
  }

  // ✅ FIXED: borderRadius error fix
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 20),
                      const SizedBox(width: 10),
                      Container(height: 10, width: 100, color: Colors.white)
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

// ==========================================
// 4. FACEBOOK VIDEO CARD (UPDATED PROFESSIONAL UI)
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

class _FacebookVideoCardState extends State<FacebookVideoCard>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPreviewing = false;
  bool _isNavigating = false;
  bool _isLiked = false;
  bool _isBroken = false;
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
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _heartAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _heartScale = Tween<double>(begin: 0.0, end: 1.2).animate(CurvedAnimation(
        parent: _heartAnimationController, curve: Curves.elasticOut));
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
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller!.initialize().timeout(const Duration(seconds: 15),
        onTimeout: () {
      throw TimeoutException("Video load took too long");
    }).then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBroken = false;
        });
        _controller?.setVolume(0);
        _controller?.addListener(_previewTimeListener);
      }
    }).catchError((e) {
      if (mounted) setState(() => _isBroken = true);
    });
  }

  void _previewTimeListener() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isNavigating) return;
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
      if (mounted) setState(() => _isNavigating = false);
    });
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

  void _handleAction({required String message, VoidCallback? action}) {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    if (action != null) action();
    Get.snackbar("Success", message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 20,
        duration: const Duration(seconds: 1),
        icon: const Icon(Icons.check_circle, color: Colors.greenAccent));
  }

  // ✅ DEEP LINK GENERATOR
  String _getPostLink() {
    try {
      Uri uri = Uri.parse(widget.videoData.url);
      String fileName = uri.pathSegments.last;
      String videoId = fileName.replaceAll('.mp4', '');
      if (kIsWeb) {
        return "${Uri.base.origin}/?post_id=$videoId";
      } else {
        return "https://meetyarah.com/?post_id=$videoId";
      }
    } catch (e) {
      return "https://meetyarah.com";
    }
  }

  // ✅ Updated Share Options
  void _showShareOptions() {
    String shareUrl = _getPostLink();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text("Share this video",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(shareUrl,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOptionItem(Icons.copy, "Copy Link", Colors.blue, () {
                  Clipboard.setData(ClipboardData(text: shareUrl));
                  _handleAction(message: "Link copied! 📋");
                }),
                _shareOptionItem(Icons.share, "More", Colors.green, () {
                  _handleAction(
                      message: "Opening options...",
                      action: () => Share.share("Watch this video: $shareUrl"));
                }),
                _shareOptionItem(Icons.send_rounded, "Send", Colors.purple,
                    () => _handleAction(message: "Sent! 🚀")),
                _shareOptionItem(
                    Icons.add_to_photos_rounded,
                    "Feed",
                    Colors.orange,
                    () => _handleAction(message: "Shared to timeline! ✍️")),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return _FeedbackButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
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
    if (_isBroken) return const SizedBox.shrink();
    final video = widget.videoData;

    // ✅ Updated UI: Flat on Mobile, Card on Web
    return Container(
      margin: kIsWeb ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: kIsWeb ? BorderRadius.circular(12) : null,
        boxShadow: kIsWeb
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2))
              ]
            : null,
        border: kIsWeb ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HEADER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Get.to(() => ProfileViewScreen(userData: video)),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200)),
                    child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(video.profileImage)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              video.channelName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // ✅ Verified Badge
                          if (video.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: Colors.blue, size: 16),
                          ]
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text("${video.timeAgo} · 🌎",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.more_horiz),
                    color: Colors.grey[700],
                    onPressed: () {}),
              ],
            ),
          ),

          // Title
          if (video.title.isNotEmpty)
            Padding(
              // ✅ FIXED: Padding Error
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Text(video.title,
                  style: GoogleFonts.inter(
                      fontSize: 15, height: 1.4, color: Colors.black87)),
            ),

          // --- 2. VIDEO PLAYER ---
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
                      aspectRatio: _controller!.value.aspectRatio > 0.8
                          ? _controller!.value.aspectRatio
                          : 4 / 5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller!),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5)
                                    ]))),
                          ),
                          // ✅ Glassmorphism Play Button
                          if (!_isPreviewing)
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 10)
                                    ]),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 35),
                              ),
                            ),
                          if (_isPreviewing)
                            Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Text("PREVIEW",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)))),
                          if (_showHeart)
                            ScaleTransition(
                                scale: _heartScale,
                                child: const Icon(Icons.favorite,
                                    color: Colors.white,
                                    size: 100,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black45, blurRadius: 15)
                                    ])),
                        ],
                      ),
                    )
                  : const SizedBox(
                      height: 350,
                      child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white30))),
            ),
          ),

          // --- 3. FOOTER STATS ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Color(0xFF1877F2), shape: BoxShape.circle),
                      child: const Icon(Icons.thumb_up,
                          color: Colors.white, size: 10)),
                  const SizedBox(width: 6),
                  Text(video.views,
                      style: GoogleFonts.inter(
                          color: Colors.grey[600], fontSize: 13)),
                ]),
                Text("${video.comments} Comments · ${video.likes} Shares",
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),

          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1, thickness: 0.5)),

          // --- 4. ACTION BUTTONS ---
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModernActionButton(
                  icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  label: _selectedReaction,
                  color: _isLiked ? const Color(0xFF1877F2) : Colors.grey[700]!,
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
                ),
                _buildModernActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: "Comment",
                    color: Colors.grey[700]!,
                    onTap: () async {
                      final Uri url =
                          Uri.parse(AdsterraConfigs.monetagHomeLink);
                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication))
                        debugPrint("Could not launch");
                    }),
                _buildModernActionButton(
                    icon: Icons.share_outlined,
                    label: "Share",
                    color: Colors.grey[700]!,
                    onTap: _showShareOptions // Updated with Deep Linking
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label,
                    style: GoogleFonts.inter(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ FEEDBACK BUTTON
class _FeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _FeedbackButton({required this.child, this.onTap, this.onLongPress});

  @override
  State<_FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<_FeedbackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed
            ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
            color: _isPressed ? Colors.grey.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: widget.child,
      ),
    );
  }
}
