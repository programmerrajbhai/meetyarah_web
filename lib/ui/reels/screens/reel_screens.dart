import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

// আপনার প্রজেক্ট পাথ ঠিক রাখুন
import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';
import '../profile_screens/screens/view_profile_screens.dart';

// ==========================================
// 1. UPDATED DATA MODEL (With Overview & Service Info)
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
  final String coverImage;
  final String bio;
  final String subscribers; // Followers
  final bool isVerified;

  // 🔥 নতুন: প্রোফাইল ওভারভিউ এর জন্য ডেটা
  final String premiumSubscribers;
  final String serviceOverview;
  final String clientFeedback;
  final String contactPrice; // Pay contact with she

  final List<String> freeContentImages;
  final List<String> premiumContentImages;

  VideoDataModel({
    required this.url, required this.title, required this.channelName,
    required this.views, required this.likes, required this.comments,
    required this.timeAgo, required this.duration, required this.profileImage,
    required this.coverImage, required this.bio, required this.subscribers,
    required this.freeContentImages, required this.premiumContentImages,
    required this.premiumSubscribers, required this.serviceOverview,
    required this.clientFeedback, required this.contactPrice,
    this.isVerified = false,
  });
}

// ==========================================
// 2. DATA HELPER (100% DATA GENERATION)
// ==========================================
class VideoDataHelper {
  static final List<String> _profileImages = [
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1587009/pexels-photo-1587009.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/2613260/pexels-photo-2613260.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/2773977/pexels-photo-2773977.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  static final List<String> _coverImages = [
    'https://images.pexels.com/photos/3756770/pexels-photo-3756770.jpeg?auto=compress&cs=tinysrgb&w=1260',
    'https://images.pexels.com/photos/1054218/pexels-photo-1054218.jpeg?auto=compress&cs=tinysrgb&w=1260',
    'https://images.pexels.com/photos/2422915/pexels-photo-2422915.jpeg?auto=compress&cs=tinysrgb&w=1260',
    'https://images.pexels.com/photos/952670/pexels-photo-952670.jpeg?auto=compress&cs=tinysrgb&w=1260',
    'https://images.pexels.com/photos/1535907/pexels-photo-1535907.jpeg?auto=compress&cs=tinysrgb&w=1260',
    'https://images.pexels.com/photos/2440024/pexels-photo-2440024.jpeg?auto=compress&cs=tinysrgb&w=1260',
    'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=1260',
  ];

  static final List<String> _girlNames = [
    "Sofia Rose", "Anika Vlogz", "Misty Night", "Bella X", "Desi Queen",
    "Natasha Cool", "Zara Fashion", "Rimi Dreamer", "Hot Stuff", "Angel Priya",
    "Naughty Sona", "Dream Girl", "Cutie Pie", "Midnight Lover", "Sexy Sam"
  ];

  static final List<String> _bios = [
    "Actress | Model | Dreamer ✨ Click subscribe for exclusive content!",
    "Just a girl living her best life 💖 DM for collabs.",
    "Fashion & Lifestyle Influencer 🔥 VIP club is open!",
    "Creating magic every day. 🧚‍♀️ Join my premium world.",
    "Travel | Food | Fun ✈️ Catch me if you can.",
    "Exclusive model 📸. Subscribe to see what I don't post on IG.",
    "Your dream girl next door 😉. Unlocked content available."
  ];

  static final List<String> _services = [
    "I provide personalized video shoutouts, brand promotions, and exclusive modeling shoots. Book me for your next project!",
    "Offering high-quality video content creation, product reviews, and lifestyle vlogging services. Let's collaborate!",
    "Professional dance covers, choreography, and private virtual performances available upon request.",
    "Exclusive behind-the-scenes content, personalized messages, and VIP chat access for my premium subscribers.",
    "Digital content creator specializing in fashion and beauty. Available for brand deals and sponsored posts."
  ];

  static final List<String> _feedbacks = [
    "Amazing experience working with her! The video quality was top-notch. ⭐⭐⭐⭐⭐ - John D.",
    "Very professional and talented. Highly recommended for brand promotions. ⭐⭐⭐⭐⭐ - Fashion Hub",
    "Loved the personalized shoutout! It made my friend's day. Thanks! ⭐⭐⭐⭐⭐ - Sarah K.",
    "Great energy and creativity. Looking forward to our next collaboration. ⭐⭐⭐⭐⭐ - Media Corp",
    "She is the best! The exclusive content is totally worth the subscription. ⭐⭐⭐⭐⭐ - VIP Fan"
  ];

  static final List<String> _titles = [
    "Viral Video 🔥 | Must Watch!", "Late night fun 🤫", "My new dance cover 💃",
    "Behind the scenes...", "You won't believe this! 😱", "Exclusive for fans ❤️",
    "Just chilling...", "Vlog: My day out", "Workout routine 💪", "GRWM: Date night"
  ];

  static List<String> _generateContentImages(int count, int seed) {
    return List.generate(count, (i) => "https://source.unsplash.com/random/300x400?sig=${seed + i}");
  }

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;

      int profileIndex = random.nextInt(_profileImages.length);
      int coverIndex = random.nextInt(_coverImages.length);
      int nameIndex = random.nextInt(_girlNames.length);
      int bioIndex = random.nextInt(_bios.length);
      int titleIndex = random.nextInt(_titles.length);
      int serviceIndex = random.nextInt(_services.length);
      int feedbackIndex = random.nextInt(_feedbacks.length);

      List<String> freeContent = _generateContentImages(15 + random.nextInt(10), index * 100);
      List<String> premiumContent = _generateContentImages(10 + random.nextInt(10), index * 200);

      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: _titles[titleIndex],
        channelName: _girlNames[nameIndex],
        profileImage: _profileImages[profileIndex],
        coverImage: _coverImages[coverIndex],
        bio: _bios[bioIndex],
        views: "${(random.nextDouble() * 5 + 0.1).toStringAsFixed(1)}M",
        likes: "${random.nextInt(50) + 5}K",
        comments: "${random.nextInt(1000) + 100}",
        timeAgo: "${random.nextInt(23) + 1}h",
        duration: "${random.nextInt(10) + 1}:${random.nextInt(50) + 10}",
        subscribers: "${(random.nextDouble() * 2 + 0.1).toStringAsFixed(1)}M",
        premiumSubscribers: "${random.nextInt(500) + 100}K",
        serviceOverview: _services[serviceIndex],
        clientFeedback: _feedbacks[feedbackIndex],
        contactPrice: "\$${random.nextInt(50) + 20}",
        isVerified: random.nextBool(),
        freeContentImages: freeContent,
        premiumContentImages: premiumContent,
      );
    });
  }
}

// ==========================================
// 3. REEL SCREENS (UI)
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
    await Future.delayed(const Duration(seconds: 2));
    var list = VideoDataHelper.generateVideos(50);
    list.shuffle();
    if(mounted) {
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
      backgroundColor: const Color(0xFFC9CCD1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("facebook", style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: -1.2)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble, color: Colors.black), onPressed: () {}),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF1877F2),
        backgroundColor: Colors.white,
        child: _isLoading
            ? _buildShimmerLoading()
            : ListView.builder(
          cacheExtent: 4000,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                title: Container(height: 10, width: 100, color: Colors.white),
                subtitle: Container(height: 10, width: 60, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(height: 10, width: double.infinity, color: Colors.white),
              ),
              Container(height: 300, width: double.infinity, color: Colors.white),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 20, width: 60, color: Colors.white),
                    Container(height: 20, width: 60, color: Colors.white),
                    Container(height: 20, width: 60, color: Colors.white),
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

// ==========================================
// 4. FACEBOOK VIDEO CARD
// ==========================================
class FacebookVideoCard extends StatefulWidget {
  final VideoDataModel videoData;
  final List<String> allVideosList;
  const FacebookVideoCard({super.key, required this.videoData, required this.allVideosList});

  @override
  State<FacebookVideoCard> createState() => _FacebookVideoCardState();
}

class _FacebookVideoCardState extends State<FacebookVideoCard> with AutomaticKeepAliveClientMixin {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isPreviewing = false;
  double _scale = 1.0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    String cleanUrl = widget.videoData.url.replaceFirst("http://", "https://");
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) { if(mounted) setState(() => _isLoading = false); }))
      ..loadHtmlString(_getFeedHtml(cleanUrl));

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_webViewController.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
  }

  String _getFeedHtml(String url) {
    return '<!DOCTYPE html><html><body style="margin:0;background:#000;display:flex;align-items:center;justify-content:center;"><video style="width:100%;height:100%;object-fit:cover;" muted playsinline preload="metadata" src="$url#t=0.1"></video></body></html>';
  }

  void _onTapVideo() {
    Get.to(() => AdWebViewScreen(
      adLink: AdsterraConfigs.monetagHomeLink,
      targetVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ));
  }

  void _onTapProfile() {
    Get.to(() => ProfileViewScreen(userData: widget.videoData));
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    HapticFeedback.lightImpact();
  }

  void _shareVideo() {
    Share.share("🔥 Check out this viral video: ${widget.videoData.title}");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final video = widget.videoData;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: InkWell(
              onTap: _onTapProfile,
              child: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
            ),
            title: InkWell(
              onTap: _onTapProfile,
              child: Row(
                children: [
                  Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if(video.isVerified) ...[
                    const SizedBox(width: 5),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ]
                ],
              ),
            ),
            subtitle: Text("${video.timeAgo} · 🌎"),
            trailing: const Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(video.title, style: const TextStyle(fontSize: 15)),
          ),
          GestureDetector(
            onTap: _onTapVideo,
            onLongPressStart: (_) {
              HapticFeedback.selectionClick();
              setState(() { _isPreviewing = true; _scale = 1.02; });
              _webViewController.runJavaScript('document.querySelector("video").play();');
            },
            onLongPressEnd: (_) {
              setState(() { _isPreviewing = false; _scale = 1.0; });
              _webViewController.runJavaScript('document.querySelector("video").pause();');
            },
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 150),
              child: Container(
                height: 350, width: double.infinity, color: Colors.black,
                child: Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    Container(color: Colors.transparent), // Touch Blocker
                    if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)),
                    if (_isPreviewing) const Center(child: Text("PREVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
                const Icon(Icons.comment_outlined, color: Colors.grey),
                const Icon(Icons.share_outlined, color: Colors.grey),
              ],
            ),
          )
        ],
      ),
    );
  }
  @override bool get wantKeepAlive => true;
}