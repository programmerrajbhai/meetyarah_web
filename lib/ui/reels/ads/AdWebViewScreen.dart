import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:meetyarah/ui/reels/screens/video_player.dart';

class AdWebViewScreen extends StatefulWidget {
  final String adLink;
  final String targetVideoUrl;
  final List<String> allVideos;

  const AdWebViewScreen({super.key, required this.adLink, required this.targetVideoUrl, required this.allVideos});

  @override
  State<AdWebViewScreen> createState() => _AdWebViewScreenState();
}

class _AdWebViewScreenState extends State<AdWebViewScreen> {
  late final WebViewController _controller;
  int _countdown = 5;
  bool _canSkip = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller = WebViewController();
    if (!kIsWeb) _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.loadRequest(Uri.parse(widget.adLink));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canSkip = true);
        _timer?.cancel();
      }
    });
  }

  void _skipAd() {
    _timer?.cancel();
    // ✅ Navigate to Video Player
    Get.off(() => FullVideoPlayerScreen(
      initialVideoUrl: widget.targetVideoUrl,
      allVideos: widget.allVideos,
      adLink: "",
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Positioned(
            top: 40, right: 20,
            child: GestureDetector(
              onTap: _canSkip ? _skipAd : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
                child: Text(_canSkip ? "Skip Ad ▶" : "Skip in $_countdown", style: const TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}