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

  // লজিক ভেরিয়েবল
  Timer? _progressTimer;
  bool _hasShownAt30s = false;
  double _currentVideoDuration = 0.0;

  @override
  void initState() {
    super.initState();
    // ১. ওরিয়েন্টেশন ফিক্সড রাখা
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // ২. ফুল স্ক্রিন মোড (স্ট্যাটাস বার হাইড করে ইমারসিভ মোড)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initializeWebView(widget.initialVideoUrl);
  }

  void _initializeWebView(String url) {
    // [PERFORMANCE FIX 1]: সঠিক কনফিগারেশন প্যারামস ব্যবহার
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black) // ফ্ল্যাশ এড়াতে কালো ব্যাকগ্রাউন্ড
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

    // [PERFORMANCE FIX 2]: Android এর জন্য হার্ডওয়্যার সেটিংস অপ্টিমাইজেশন
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false); // ডিবাগিং বন্ধ (ফাস্ট হবে)
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

        // ৩০ সেকেন্ড লজিক
        if (currentTime > 30 && !_hasShownAt30s && !_showRecommendations) {
          setState(() {
            _showRecommendations = true;
            _hasShownAt30s = true;
          });
        }
        // শেষ ১০ সেকেন্ড লজিক
        if (duration > 0 && (duration - currentTime) <= 10 && !_showRecommendations) {
          if (currentTime > (duration - 9)) {
            setState(() {
              _showRecommendations = true;
            });
          }
        }
      } catch (e) {
        // ইগনোর এরর
      }
    });
  }

  // [PERFORMANCE FIX 3]: CSS দিয়ে GPU ফোর্স করা (মেইন ল্যাগ ফিক্স)
  String _getVideoHtml(String url) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; background-color: black; height: 100vh; display: flex; align-items: center; justify-content: center; overflow: hidden; }
          
          /* ভিডিও এলিমেন্টে হার্ডওয়্যার অ্যাকসিলারেশন */
          video { 
            width: 100%; 
            height: 100%; 
            object-fit: contain; 
            transform: translate3d(0, 0, 0); /* GPU Force Trigger */
            -webkit-transform: translate3d(0, 0, 0);
            will-change: transform;
          }
          
          /* প্লেয়ার কন্ট্রোল ডিজাইন */
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
    // বের হওয়ার সময় আগের UI মোড ফেরত আনা
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
    final suggestions = widget.allVideos.where((url) => url != widget.initialVideoUrl).toList();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ------------------------------------------
            // 1. MAIN VIDEO PLAYER (Single WebView)
            // ------------------------------------------
            Center(
              child: WebViewWidget(controller: _webViewController),
            ),

            // Loading Indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.red)),

            // ------------------------------------------
            // 2. CONTROL BUTTONS (Top Layer)
            // ------------------------------------------
            Positioned(
              top: 40, left: 15,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: _onBackPress,
                ),
              ),
            ),

            Positioned(
              top: 40, right: 15,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(
                  icon: Icon(_showRecommendations ? Icons.close : Icons.playlist_play, color: Colors.white, size: 20),
                  onPressed: () {
                    setState(() => _showRecommendations = !_showRecommendations);
                  },
                ),
              ),
            ),

            // ------------------------------------------
            // 3. RECOMMENDATIONS SIDEBAR (Smart List)
            // ------------------------------------------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _showRecommendations ? 0 : -220,
              top: 80, bottom: 20, width: 200,
              child: Container(
                margin: const EdgeInsets.only(right: 5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9), // Glass Effect
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
                          if(_currentVideoDuration > 0)
                            const Icon(Icons.flash_on, color: Colors.amber, size: 14)
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final url = suggestions[index];
                          // এখানে আমরা একটি স্মার্ট থাম্বনেইল উইজেট ব্যবহার করছি
                          return _buildSmartThumbnailCard(url, index);
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

  // ----------------------------------------------------
  // 🧩 SMART THUMBNAIL BUILDER (No Lag, Looks Real)
  // ----------------------------------------------------
  Widget _buildSmartThumbnailCard(String url, int index) {
    // র‍্যান্ডম সিড ব্যবহার করছি যাতে একই ভিডিওর জন্য সবসময় একই ছবি আসে
    // কিন্তু ভিন্ন ভিডিওর জন্য ভিন্ন ছবি আসে।
    final int randomSeed = url.hashCode + index;
    final Random random = Random(randomSeed);

    // ফেইক ডিউরেশন তৈরি (যেমন: 04:20, 02:15 ইত্যাদি)
    final String minutes = (random.nextInt(5) + 1).toString().padLeft(2, '0');
    final String seconds = random.nextInt(60).toString().padLeft(2, '0');
    final String duration = "$minutes:$seconds";

    // র‍্যান্ডম ইমেজ URL (Picsum - হাই কোয়ালিটি, ফাস্ট)
    final String imageUrl = "https://picsum.photos/seed/$randomSeed/300/180";

    return GestureDetector(
      onTap: () => _playSuggestedVideo(url),
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
              // 1. Random High Quality Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: Colors.grey[900]);
                },
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white24)),
              ),

              // 2. Black Gradient Overlay (টেক্সট পড়ার জন্য)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),

              // 3. Play Icon (Center)
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

              // 4. Fake Duration (Bottom Right)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // 5. Video Index/Title (Bottom Left) q
              Positioned(
                bottom: 6,
                left: 6,
                child: Text(
                  "Video Clip ${index + 1}",
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}