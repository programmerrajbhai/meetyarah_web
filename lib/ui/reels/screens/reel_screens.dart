import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  // final String coverImage;
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
    // required this.coverImage,
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

  static final List<String> _girlNames = [
    "Sofia Rose",
    "Anika Vlogz",
    "Misty Night",
    "Bella X",
    "Desi Queen",
  ];
  static final List<String> _titles = [
    "Viral Video 🔥",
    "Late night fun 🤫",
    "My new dance cover 💃",
    "Behind the scenes...",
    "Must Watch! 😱",
  ];

  static List<String> _generateContentImages(int count, int seed) {
    return List.generate(
      count,
      (i) => "https://source.unsplash.com/random/300x400?sig=${seed + i}",
    );
  }

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;
      String pImg = _profileImages[random.nextInt(_profileImages.length)];
      String name = _girlNames[random.nextInt(_girlNames.length)];
      String title = _titles[random.nextInt(_titles.length)];

      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: title,
        channelName: name,
        profileImage: pImg,
        bio: "Content Creator ✨",
        views: "${(random.nextDouble() * 5 + 0.1).toStringAsFixed(1)}M",
        likes: "${random.nextInt(50) + 5}K",
        comments: "${random.nextInt(1000) + 100}",
        timeAgo: "${random.nextInt(23) + 1}h",
        duration: "${random.nextInt(10) + 1}:${random.nextInt(50) + 10}",
        subscribers: "${(random.nextDouble() * 2 + 0.1).toStringAsFixed(1)}M",
        premiumSubscribers: "${random.nextInt(500) + 100}K",
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
// 3. REEL SCREENS (MAIN UI)
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
    await Future.delayed(const Duration(milliseconds: 500));
    var list = VideoDataHelper.generateVideos(50);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
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
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF1877F2),
        child: _isLoading
            ? _buildShimmerLoading()
            : ListView.builder(
                // ✅ Smooth Scrolling Settings
                physics: const AlwaysScrollableScrollPhysics(),
                cacheExtent: 3000,
                addAutomaticKeepAlives: true,
                itemCount: _allVideos.length,
                itemBuilder: (context, index) {
                  return FacebookVideoCard(
                    key: ValueKey(_allVideos[index].url),
                    videoData: _allVideos[index],
                    allVideosList: _allVideos.map((e) => e.url).toList(),
                  );
                },
              ),
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 24),
        onPressed: () {},
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        color: Colors.white,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
                title: Container(height: 10, width: 100, color: Colors.white),
                subtitle: Container(height: 10, width: 60, color: Colors.white),
              ),
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. FACEBOOK VIDEO CARD (CLICK & SCROLL FIXED)
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
    with AutomaticKeepAliveClientMixin {
  late WebViewController _thumbnailWebController;

  bool _isLiked = false;
  String _selectedReaction = 'Like';
  bool _showReactionDock = false;
  final Color fbBlue = const Color(0xFF1877F2);

  Uint8List? _thumbnailBytes;
  bool _isThumbnailLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeThumbnail();
  }

  void _initializeThumbnail() {
    if (kIsWeb) {
      _thumbnailWebController = WebViewController();

      // ✅ Web: ভিডিও প্রিভিউ থাম্বনেইল হিসেবে
      String cleanUrl = widget.videoData.url.replaceFirst(
        "http://",
        "https://",
      );
      String html =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
          <style>
            body { margin:0; padding:0; background:#000; height:100vh; display:flex; align-items:center; justify-content:center; overflow:hidden; }
            video { width:100%; height:100%; object-fit:cover; }
          </style>
        </head>
        <body>
          <video muted playsinline preload="metadata">
            <source src="$cleanUrl#t=0.1" type="video/mp4">
          </video>
        </body>
        </html>
      ''';

      _thumbnailWebController.loadHtmlString(html);
    } else {
      // ✅ Mobile: ইমেজ থাম্বনেইল
      _generateNativeThumbnail();
    }
  }

  Future<void> _generateNativeThumbnail() async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: widget.videoData.url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 50,
      );
      if (mounted) {
        setState(() {
          _thumbnailBytes = uint8list;
          _isThumbnailLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isThumbnailLoading = false);
    }
  }

  void _onTapVideo() {
    Get.to(
      () => AdWebViewScreen(
        adLink: AdsterraConfigs.monetagHomeLink,
        targetVideoUrl: widget.videoData.url,
        allVideos: widget.allVideosList,
      ),
    );
  }

  void _onTapProfile() {
    Get.to(() => ProfileViewScreen(userData: widget.videoData));
  }

  void _handleLikeTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _showReactionDock = false;
      _isLiked = !_isLiked;
      _selectedReaction = _isLiked ? 'Like' : 'Like';
    });
  }

  void _handleReactionSelect(String reaction) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedReaction = reaction;
      _isLiked = true;
      _showReactionDock = false;
    });
  }

  void _shareVideo() {
    Share.share("🔥 Check out this viral video: ${widget.videoData.title}");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final video = widget.videoData;

    // ❌ Parent GestureDetector removed (Fixes conflict)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ListTile(
                leading: InkWell(
                  onTap: _onTapProfile,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(video.profileImage),
                  ),
                ),
                title: InkWell(
                  onTap: _onTapProfile,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          video.channelName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (video.isVerified) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
                subtitle: Text(
                  "${video.timeAgo} · 🌎",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ),

              // Caption
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(video.title, style: const TextStyle(fontSize: 15)),
              ),
              const SizedBox(height: 5),

              // ✅ VIDEO THUMBNAIL AREA (CLICK & SCROLL FIXED)
              SizedBox(
                height: 350,
                width: double.infinity,
                child: Stack(
                  children: [
                    // 1. Background (WebView for Web / Image for Mobile)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (kIsWeb)
                              // ✅ Web: WebView
                              WebViewWidget(controller: _thumbnailWebController)
                            else if (_thumbnailBytes != null)
                              // ✅ Mobile: Thumbnail
                              Image.memory(
                                _thumbnailBytes!,
                                height: 350,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            else if (_isThumbnailLoading)
                              Shimmer.fromColors(
                                baseColor: Colors.grey[800]!,
                                highlightColor: Colors.grey[700]!,
                                child: Container(color: Colors.black),
                              )
                            else
                              const Icon(
                                Icons.video_library,
                                color: Colors.white54,
                                size: 50,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Transparent Overlay (✅ THE FIX)
                    // এটি WebView এর ওপর থাকবে। ফলে ক্লিক এবং স্ক্রল দুটোই Flutter হ্যান্ডেল করবে।
                    // WebView এর নিজস্ব স্ক্রলিং বা ক্লিক ব্লক হয়ে যাবে।
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior
                            .translucent, // স্বচ্ছ অংশেও ক্লিক নেবে
                        onTap: _onTapVideo, // ✅ ক্লিক করলে অ্যাড আসবে
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Duration Badge
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IgnorePointer(
                        // ক্লিক যাতে নিচে পাস হয়
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1877F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isLiked ? "You and ${video.likes} others" : video.likes,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      "${video.comments} Comments  •  ${video.views} Views",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0, thickness: 1),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showReactionDock = true);
                    },
                    onTap: _handleLikeTap,
                    child: _buildActionButton(
                      icon: _isLiked
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                      label: "Like",
                      color: _isLiked ? fbBlue : Colors.grey[700]!,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Get.snackbar("Comment", "Comments are disabled."),
                    child: _buildActionButton(
                      icon: Icons.mode_comment_outlined,
                      label: "Comment",
                      color: Colors.grey[700]!,
                    ),
                  ),
                  GestureDetector(
                    onTap: _shareVideo,
                    child: _buildActionButton(
                      icon: Icons.share_outlined,
                      label: "Share",
                      color: Colors.grey[700]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),

        if (_showReactionDock)
          Positioned(bottom: 50, left: 15, child: _buildReactionDock()),
      ],
    );
  }

  // --- Helpers ---

  Widget _buildReactionDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _reactionEmoji('Like', '👍'),
          _reactionEmoji('Love', '❤️'),
          _reactionEmoji('Haha', '😆'),
          _reactionEmoji('Wow', '😮'),
        ],
      ),
    );
  }

  Widget _reactionEmoji(String name, String emoji) {
    return GestureDetector(
      onTap: () => _handleReactionSelect(name),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildActionButton({
    required dynamic icon,
    required String label,
    required Color color,
  }) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          icon is IconData ? Icon(icon, color: color, size: 20) : icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;



}
