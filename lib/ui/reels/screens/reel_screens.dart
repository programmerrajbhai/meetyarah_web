import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/reels/screens/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:share_plus/share_plus.dart';

// আপনার প্রজেক্ট পাথ ঠিক রাখুন
import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';
import '../profile_screens/screens/view_profile_screens.dart';

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
  final String subscribers;

  VideoDataModel({
    required this.url, required this.title, required this.channelName,
    required this.views, required this.likes, required this.comments,
    required this.timeAgo, required this.duration, required this.profileImage,
    required this.subscribers,
  });
}



// ==========================================
// 2. DATA GENERATOR (Real Girl Photos)
// ==========================================
class VideoDataHelper {

  // 🔥 রিয়েল দেশি ও বিদেশি মেয়েদের ছবির ডাইরেক্ট লিংক
  static final List<String> _realProfileImages = [
    // --- Desi / Indian / Bengali Look ---
    'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1587009/pexels-photo-1587009.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/2104252/pexels-photo-2104252.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/2613260/pexels-photo-2613260.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/2773977/pexels-photo-2773977.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=200',

    // --- Bideshi / Western Look ---
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1382731/pexels-photo-1382731.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/3756679/pexels-photo-3756679.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1024311/pexels-photo-1024311.jpeg?auto=compress&cs=tinysrgb&w=200',
    'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=200'
  ];

  static final List<String> _girlNames = [
    "Naughty Anika", "Desi Bhabi Vlogs", "Sexy Sophia", "Dream Girl Rimi",
    "Hot Bella", "Misty Night", "Sofia X", "Cute Puja",
    "Viral Queen", "Midnight Lover", "Sunny Fan Club", "Sweet Taniya",
    "Boudi Diaries", "Romance Hub", "Private Moments"
  ];

  static final List<String> _titleStart = [
    "OMG! My Ex", "Late Night", "Desi Bhabi", "College Girl", "Bathroom",
    "Bedroom Secret", "First Night", "Private Room", "Hidden Cam", "Hot Yoga",
    "Naughty", "Midnight", "Shower Time", "Hotel Room", "My Crush"
  ];

  static final List<String> _titleMiddle = [
    "Forgot Camera Was ON 📸", "Leaked Video Viral", "Romance with BF",
    "Changing Clothes 👗", "Towel Slipped 😱", "Video Call Record",
    "Private Moment Caught", "Oil Massage Prank", "Uncut Scene", "Sleeping Alone",
    "Live Stream Mistake", "Sending Nudes?", "Kissing Prank"
  ];

  static final List<String> _titleEnd = [
    "🔥 | Too Hot", "❌ | Don't Tell Anyone", "🔞 | 18+ Only", "😱 | Viral Clip",
    "🚫 | Watch Before Delete", "💦 | Satisfaction", "😈 | Very Naughty", "🔒 | Leaked",
    "😍 | Must Watch"
  ];

  static List<VideoDataModel> generateVideos(int count) {
    var random = Random();
    return List.generate(count, (index) {
      int id = 64000 + index;

      String dynamicTitle = "${_titleStart[random.nextInt(_titleStart.length)]} "
          "${_titleMiddle[random.nextInt(_titleMiddle.length)]} "
          "${_titleEnd[random.nextInt(_titleEnd.length)]}";
      String dynamicChannel = _girlNames[random.nextInt(_girlNames.length)];

      return VideoDataModel(
        url: 'https://ser3.masahub.cc/myfiless/id/$id.mp4',
        title: dynamicTitle,
        channelName: dynamicChannel,
        views: "${(random.nextDouble() * 8 + 0.5).toStringAsFixed(1)}M",
        likes: "${random.nextInt(80) + 20}K",
        comments: "${random.nextInt(2000) + 500}",
        timeAgo: "${random.nextInt(12) + 1}h",
        duration: "${random.nextInt(15) + 4}:${random.nextInt(50) + 10}",
        // 🔥 এখান থেকে র‍্যান্ডম রিয়েল ফটো পিক করবে
        profileImage: _realProfileImages[random.nextInt(_realProfileImages.length)],
        subscribers: "${(random.nextDouble() * 5 + 0.5).toStringAsFixed(1)}M",
      );
    });
  }
}

// ==========================================
// 3. MAIN REEL SCREEN (With Shimmer Effect)
// ==========================================
class ReelScreens extends StatefulWidget {
  const ReelScreens({super.key});
  @override
  State<ReelScreens> createState() => _ReelScreensState();
}

class _ReelScreensState extends State<ReelScreens> {
  List<VideoDataModel> _allVideos = [];
  bool _isLoading = true; // লোডিং ইন্ডিকেটর

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // ফেক লোডিং ইফেক্ট (প্রথমবার ১ সেকেন্ড)
    await Future.delayed(const Duration(seconds: 1));
    var list = VideoDataHelper.generateVideos(1500);
    list.shuffle();
    if(mounted) {
      setState(() {
        _allVideos = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true); // শিমার শুরু
    await Future.delayed(const Duration(milliseconds: 1500)); // ১.৫ সেকেন্ড লোডিং
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
            ? _buildShimmerLoading() // 🔥 লোডিং হলে শিমার দেখাবে
            : ListView.builder(
          cacheExtent: 4000,
          physics: const AlwaysScrollableScrollPhysics(),
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

  // 🔥 SHIMMER EFFECT WIDGET (Facebook Style Skeleton)
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // ৫টা স্কেলিটন কার্ড দেখাবে
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Shimmer
              ListTile(
                leading: _shimmerBox(height: 40, width: 40, isCircle: true),
                title: _shimmerBox(height: 10, width: 100),
                subtitle: _shimmerBox(height: 10, width: 60),
              ),
              // Title Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _shimmerBox(height: 12, width: double.infinity),
              ),
              // Video Box Shimmer
              _shimmerBox(height: 300, width: double.infinity),
              // Footer Shimmer
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(height: 20, width: 80),
                    _shimmerBox(height: 20, width: 80),
                    _shimmerBox(height: 20, width: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // শিমার বক্স বিল্ডার
  Widget _shimmerBox({required double height, required double width, bool isCircle = false}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(4),
      ),
    );
  }
}
// ==========================================
// 4. FACEBOOK VIDEO CARD (FEED ITEM)
// ==========================================
// ==========================================
// 4. FACEBOOK VIDEO CARD (PREMIUM LOADING UI)
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
      ..setBackgroundColor(Colors.transparent)
    // 🔥 Optimized Agent
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) { if(mounted) setState(() => _isLoading = false); }));

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (_webViewController.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController.loadHtmlString(_getFeedHtml(cleanUrl));
  }

  String _getFeedHtml(String url) {
    return '''
      <!DOCTYPE html><html><head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>body{margin:0;background:#000;display:flex;align-items:center;justify-content:center;overflow:hidden;} video{width:100%;height:100%;object-fit:cover;}</style>
      </head><body>
      <video id="v" muted playsinline preload="metadata" src="$url#t=1.5"></video>
      <script>
        var v=document.getElementById("v");
        v.addEventListener('loadedmetadata',function(){this.currentTime=1.5;});
        function startP(){ v.preload="auto"; v.currentTime=0; v.play(); v.playbackRate=2.0; }
        function stopP(){ v.pause(); v.currentTime=1.5; v.preload="metadata"; }
      </script></body></html>
    ''';
  }

  void _onTap() {
    Get.to(() => FullVideoPlayerScreen(
      initialVideoUrl: widget.videoData.url,
      allVideos: widget.allVideosList,
    ));
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    HapticFeedback.lightImpact();
  }

  void _shareVideo() {
    Share.share("🔥 Check out this viral video: ${widget.videoData.title}\n\nWatch full video here 👇\nhttps://play.google.com/store/apps/details?id=com.hotreels.app");
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
          // Header
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(video.profileImage)),
            title: Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${video.timeAgo} · 🌎"),
            trailing: const Icon(Icons.more_horiz),
            onTap: () => Get.to(() => ProfileViewScreen(videoData: video)),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(video.title, maxLines: 2, style: const TextStyle(fontSize: 15)),
          ),

          // Video Preview Area (With Animation)
          GestureDetector(
            onTap: _onTap,
            onLongPressStart: (_) {
              HapticFeedback.selectionClick();
              setState(() { _isPreviewing = true; _scale = 1.02; });
              _webViewController.runJavaScript('startP();');
            },
            onLongPressEnd: (_) {
              setState(() { _isPreviewing = false; _scale = 1.0; });
              _webViewController.runJavaScript('stopP();');
            },
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 150),
              child: Container(
                height: 350, width: double.infinity, color: const Color(0xFF101010),
                child: Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),

                    Container(color: Colors.transparent), // Touch Blocker

                    // 🔥 PREMIUM LOADING ANIMATION
                    if (_isLoading)
                      Container(
                        color: Colors.black, // কালো ব্যাকগ্রাউন্ডের উপর লোডিং
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // কাস্টম পালসিং আইকন
                              TweenAnimationBuilder(
                                tween: Tween(begin: 0.8, end: 1.2),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.2), size: 60),
                                  );
                                },
                                onEnd: () {}, // লুপের জন্য বা কনটিনিউয়াস রাখার জন্য আলাদা কন্ট্রোলার লাগবে, এখানে সিম্পল রাখা হলো
                              ),
                              const SizedBox(height: 20),
                              // লোডিং টেক্সট বা স্পিনার
                              const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Duration Badge
                    if (!_isPreviewing && !_isLoading)
                      Positioned(bottom: 10, right: 10, child: Container(padding: const EdgeInsets.all(4), color: Colors.black54, child: Text(video.duration, style: const TextStyle(color: Colors.white)))),

                    // Preview Indicator
                    if (_isPreviewing)
                      const Center(child: Text("PREVIEW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(blurRadius: 10, color: Colors.black)]))),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.thumb_up, size: 14, color: Color(0xFF1877F2)),
                  const SizedBox(width: 5),
                  Text(_isLiked ? "You and ${video.likes}" : video.likes, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ]),
                Text("${video.comments} Comments • ${video.views} Views", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                  onPressed: _toggleLike,
                  icon: Icon(_isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt, color: _isLiked ? const Color(0xFF1877F2) : Colors.grey),
                  label: Text("Like", style: TextStyle(color: _isLiked ? const Color(0xFF1877F2) : Colors.grey))
              ),
              TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Comments 💬",
                      content: const Text("Only premium members can comment on this video!"),
                      confirm: ElevatedButton(onPressed: () => Get.back(), child: const Text("OK")),
                    );
                  },
                  icon: const Icon(Icons.comment, color: Colors.grey),
                  label: const Text("Comment", style: TextStyle(color: Colors.grey))
              ),
              TextButton.icon(
                  onPressed: _shareVideo,
                  icon: const Icon(Icons.share, color: Colors.grey),
                  label: const Text("Share", style: TextStyle(color: Colors.grey))
              ),
            ],
          )
        ],
      ),
    );
  }
  @override bool get wantKeepAlive => true;
}

