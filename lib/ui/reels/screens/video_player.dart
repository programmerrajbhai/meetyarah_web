import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../adsterra/adsterra_configs.dart';
import '../ads/AdWebViewScreen.dart';

class FullVideoPlayerScreen extends StatefulWidget {
  final String initialVideoUrl;
  final List<String> allVideos;

  const FullVideoPlayerScreen({
    super.key,
    required this.initialVideoUrl,
    required this.allVideos,
    required String adLink,
  });

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _showRecommendations = false;

  // Logic Variables
  Timer? _progressTimer;
  bool _hasShownAt30s = false;
  double _currentVideoDuration = 0.0;

  // Random Suggestions List
  late List<String> _shuffledSuggestions;

  @override
  void initState() {
    super.initState();
    // 1. Orientation & UI Setup
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 2. Prepare Random Suggestions
    _prepareSuggestions();

    // 3. Load Main Video
    _initializeWebView(widget.initialVideoUrl);
  }

  void _prepareSuggestions() {
    // বর্তমান ভিডিও বাদ দিয়ে বাকিগুলো নেওয়া
    var tempList = widget.allVideos.where((url) => url != widget.initialVideoUrl).toList();
    // র‍্যান্ডমলি শাফেল করা (যাতে প্রতিবার আলাদা ভিডিও আসে)
    tempList.shuffle();
    // টপ ১০টা বা ২০টা নেওয়া (পারফরমেন্সের জন্য)
    _shuffledSuggestions = tempList.take(15).toList();
  }

  void _initializeWebView(String url) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
              _startProgressChecker();
            }
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    controller.loadHtmlString(_getVideoHtml(url));
    _webViewController = controller;
  }

  void _startProgressChecker() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final currentTimeStr = await _webViewController.runJavaScriptReturningResult("document.getElementById('myVideo').currentTime");
        final durationStr = await _webViewController.runJavaScriptReturningResult("document.getElementById('myVideo').duration");

        double currentTime = double.tryParse(currentTimeStr.toString()) ?? 0.0;
        double duration = double.tryParse(durationStr.toString()) ?? 0.0;
        _currentVideoDuration = duration;

        // Auto Open Recommendation Logic
        if (currentTime > 30 && !_hasShownAt30s && !_showRecommendations) {
          setState(() {
            _showRecommendations = true;
            _hasShownAt30s = true;
          });
        }
        if (duration > 0 && (duration - currentTime) <= 10 && !_showRecommendations) {
          if (currentTime > (duration - 9)) {
            setState(() {
              _showRecommendations = true;
            });
          }
        }
      } catch (e) {
        // Ignore
      }
    });
  }

  String _getVideoHtml(String url) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; background-color: black; height: 100vh; display: flex; align-items: center; justify-content: center; overflow: hidden; }
          video { 
            width: 100%; height: 100%; object-fit: contain; 
            transform: translate3d(0, 0, 0); 
            will-change: transform;
          }
          video::-webkit-media-controls-panel { background-image: linear-gradient(transparent, rgba(0,0,0,0.5)); }
        </style>
      </head>
      <body>
        <video id="myVideo" controls autoplay playsinline preload="auto" name="media">
          <source src="$url" type="video/mp4">
        </video>
      </body>
      </html>
    ''';
  }

  void _playSuggestedVideo(String url) {
    _progressTimer?.cancel();
    Get.off(() => AdWebViewScreen(
      adLink: AdsterraConfigs.monetagPlayerLink,
      targetVideoUrl: url,
      allVideos: widget.allVideos,
    ));
  }

  void _onBackPress() {
    _progressTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Get.back();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. MAIN PLAYER
            Center(child: WebViewWidget(controller: _webViewController)),

            // Loading
            if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.red)),

            // 2. CONTROLS
            Positioned(
              top: 40, left: 15,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: _onBackPress),
              ),
            ),
            Positioned(
              top: 40, right: 15,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(
                  icon: Icon(_showRecommendations ? Icons.close : Icons.playlist_play, color: Colors.white, size: 20),
                  onPressed: () => setState(() => _showRecommendations = !_showRecommendations),
                ),
              ),
            ),

            // 3. RECOMMENDATIONS SIDEBAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _showRecommendations ? 0 : -220,
              top: 80, bottom: 20, width: 200,
              child: Container(
                margin: const EdgeInsets.only(right: 5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [const BoxShadow(color: Colors.black45, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8, top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Up Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          if(_currentVideoDuration > 0) const Icon(Icons.flash_on, color: Colors.amber, size: 14)
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _shuffledSuggestions.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final url = _shuffledSuggestions[index];
                          // 🔥 Real Video Thumbnail Widget
                          return _RealVideoThumbnailCard(videoUrl: url, index: index, onTap: () => _playSuggestedVideo(url));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 🔥 REAL VIDEO THUMBNAIL WIDGET (Using WebView Trick)
// =========================================================
class _RealVideoThumbnailCard extends StatefulWidget {
  final String videoUrl;
  final int index;
  final VoidCallback onTap;

  const _RealVideoThumbnailCard({required this.videoUrl, required this.index, required this.onTap});

  @override
  State<_RealVideoThumbnailCard> createState() => _RealVideoThumbnailCardState();
}

class _RealVideoThumbnailCardState extends State<_RealVideoThumbnailCard> with AutomaticKeepAliveClientMixin {
  late WebViewController _thumbnailController;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // WebView ইনিশিয়ালাইজেশন (Thumbnail Mode)
    _thumbnailController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black) // ব্যাকগ্রাউন্ড কালো
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
      ));

    // HTML5 Trick: #t=0.1 দিয়ে ভিডিওর প্রথম ফ্রেম দেখানো
    String html = '''
      <html>
      <body style="margin:0;background:#000;display:flex;align-items:center;justify-content:center;overflow:hidden;">
        <video 
          style="width:100%;height:100%;object-fit:cover;pointer-events:none;" 
          muted 
          preload="metadata" 
          src="${widget.videoUrl}#t=0.1">
        </video>
      </body>
      </html>
    ''';

    _thumbnailController.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // র‍্যান্ডম ডিউরেশন জেনারেট করা (Real Feel এর জন্য)
    final random = Random(widget.videoUrl.hashCode);
    final String duration = "${random.nextInt(5) + 1}:${random.nextInt(60).toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
          color: Colors.grey[900],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. WebView Thumbnail (Real Video Frame)
              AnimatedOpacity(
                opacity: _isLoaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: WebViewWidget(controller: _thumbnailController),
              ),

              // 2. Touch Blocker (To prevent webview gestures)
              Container(color: Colors.transparent),

              // 3. Loading Placeholder
              if (!_isLoaded)
                Container(
                  color: Colors.grey[900],
                  child: const Center(child: Icon(Icons.video_library, color: Colors.white12, size: 30)),
                ),

              // 4. Play Icon Overlay
              Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                ),
              ),

              // 5. Duration Badge
              Positioned(
                bottom: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                  child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),

              // 6. Video Number
              Positioned(
                bottom: 6, left: 6,
                child: Text(
                  "Video #${widget.index + 1}",
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // স্ক্রল করলেও লোড হয়ে থাকবে
}