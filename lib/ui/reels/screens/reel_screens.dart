import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts

// ✅ প্রোফাইল স্ক্রিন ইমপোর্ট (Internal Navigation)
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
// 2. DATA HELPER (GOOGLE DEMO VIDEOS)
// ==========================================
class VideoDataHelper {
  // ✅ Google Demo Videos List
  static final List<String> _videoUrls = [
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
  ];

  static final List<String> _profileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  static final List<String> _names = [
    "Google Demo",
    "CGI Master",
    "Nature Lover",
    "Auto Expert",
    "Movie Clips",
    "Tech Reviewer",
    "Travel Vlog"
  ];

  static final List<String> _titles = [
    "Big Buck Bunny - Short Film",
    "Elephants Dream - 3D Animation",
    "Amazing Fire Effects 🔥",
    "Escape Routine 🏃‍♂️",
    "Having Fun with Friends 😄",
    "Joyride in the City 🚗",
    "Meltdown Explained ❄️",
    "Sintel - The Search",
    "Subaru Outback Review",
    "Tears of Steel - SciFi"
  ];

  static final List<String> _bios = [
    "🎥 Official Google Demo Channel.\n✨ High quality sample videos.\n👇 Subscribe for more!",
    "🖌️ 3D Artist & Animator.\nCreating open movies with Blender.\nSupport open source!",
    "🚗 Car Enthusiast.\nReviewing the latest models.\nDM for collabs.",
    "🌍 Travel & Lifestyle.\nExploring the hidden gems.\nJoin my journey!"
  ];

  static List<String> _generateImages(int count, int seed) => List.generate(
      count, (i) => "https://picsum.photos/seed/${seed + i}/400/600");

  static List<VideoDataModel> generateAllVideos() {
    List<VideoDataModel> allVideos = [];
    var random = Random();

    // Generate models based on the fixed Google video list
    for (int i = 0; i < _videoUrls.length; i++) {
      allVideos.add(VideoDataModel(
        url: _videoUrls[i],
        title: i < _titles.length ? _titles[i] : "Awesome Video #${i + 1}",
        channelName: _names[random.nextInt(_names.length)],
        profileImage: _profileImages[random.nextInt(_profileImages.length)],
        bio: _bios[random.nextInt(_bios.length)],
        serviceOverview: "Watch high quality demo content here.",
        views: "${(random.nextDouble() * 10 + 0.5).toStringAsFixed(1)}M",
        likes: "${random.nextInt(100) + 10}K",
        comments: "${random.nextInt(5000) + 200}",
        subscribers: "${(random.nextDouble() * 5 + 1).toStringAsFixed(1)}M",
        premiumSubscribers: "${random.nextInt(100) + 10}K",
        contactPrice: "\$${random.nextInt(100) + 50}",
        timeAgo: "${random.nextInt(10) + 1} days ago",
        duration: "10:00", // Standard placeholder
        clientFeedback: "Crystal clear quality!",
        isVerified: true, // Making them verified for demo look
        freeContentImages: _generateImages(6, i),
        premiumContentImages: _generateImages(8, i + 500),
      ));
    }

    // Shuffle slightly but keep quality
    // allVideos.shuffle(); // Optional: Keep order for specific demo feel
    return allVideos;
  }
}

// ==========================================
// 3. REEL SCREENS (CLEAN VERSION)
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
    // Simulate network delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 500));
    var list = VideoDataHelper.generateAllVideos();

    // ✅ Deep Linking Logic (Simplified for Demo)
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
                            Text("Suggested for You",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.grey[700])),
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

  Widget _buildSuggestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Popular Channels",
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
                    "https://i.pravatar.cc/150?img=${index + 20}")),
            title: Text("Creator ${index + 1}",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: const Text("Verified Creator"),
            trailing: TextButton(
              onPressed: () {},
              child: const Text("Follow"),
            ),
          ),
        )
      ],
    );
  }

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
// 4. FACEBOOK VIDEO CARD (NO ADS, PURE VIDEO)
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
  bool _isLiked = false;
  bool _isBroken = false;
  bool _isPlaying = false;
  bool _isMuted = true;
  String _selectedReaction = "Like";

  late AnimationController _heartAnimationController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

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
    // ✅ Google videos use standard HTTP/HTTPS correctly
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoData.url));
    _controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBroken = false;
          _isPlaying = true;
        });
        _controller?.setLooping(true);
        _controller?.setVolume(0); // Start muted like FB
        _controller?.play();
      }
    }).catchError((e) {
      debugPrint("Video Error: $e");
      if (mounted) setState(() => _isBroken = true);
    });
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

  void _toggleMute() {
    if (_controller != null && _isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        _controller?.setVolume(_isMuted ? 0 : 1);
      });
    }
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

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
                width: 40, height: 4, color: Colors.grey[300], margin: const EdgeInsets.only(bottom: 10)),
            const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=$index")),
                  title: Text("User $index", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Great video! Keep it up. 🔥"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Share Options
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
    _controller?.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBroken) return const SizedBox.shrink();
    final video = widget.videoData;

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
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Text(video.title,
                  style: GoogleFonts.inter(
                      fontSize: 15, height: 1.4, color: Colors.black87)),
            ),

          // --- 2. VIDEO PLAYER ---
          GestureDetector(
            onTap: _togglePlayPause,
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

                    // Play/Pause Icon Overlay
                    if (!_isPlaying)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 60),
                        ),
                      ),

                    // Mute Button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle
                          ),
                          child: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

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
                    onTap: _showComments // ✅ Updated to show modal
                ),
                _buildModernActionButton(
                    icon: Icons.share_outlined,
                    label: "Share",
                    color: Colors.grey[700]!,
                    onTap: _showShareOptions
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

// ✅ সংশোধিত _FeedbackButton ক্লাস
class _FeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress; // এটি আগে থেকেই ছিল

  // এখানে পরিবর্তন করা হয়েছে: কনস্ট্রাক্টরে this.onLongPress যোগ করা হয়েছে
  const _FeedbackButton({
    super.key, 
    required this.child, 
    this.onTap, 
    this.onLongPress, // এই লাইনটি নিশ্চিত করুন
  });

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
      onLongPress: widget.onLongPress, // এটি লঙ প্রেস হ্যান্ডেল করবে
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