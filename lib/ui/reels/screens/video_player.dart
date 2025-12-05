import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FullVideoPlayerScreen extends StatefulWidget {
  final String initialVideoUrl;
  final List<String> allVideos;
  const FullVideoPlayerScreen({super.key, required this.initialVideoUrl, required this.allVideos, required String adLink});

  @override
  State<FullVideoPlayerScreen> createState() => _FullVideoPlayerScreenState();
}

class _FullVideoPlayerScreenState extends State<FullVideoPlayerScreen> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController();
    if (!kIsWeb) {
      _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
      _webViewController.setBackgroundColor(Colors.black);
    }
    _webViewController.loadHtmlString(
        '<!DOCTYPE html><html><body style="margin:0;background:#000;display:flex;align-items:center;justify-content:center;height:100vh;"><video width="100%" height="100%" controls autoplay src="${widget.initialVideoUrl}"></video></body></html>'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: WebViewWidget(controller: _webViewController)),
          Positioned(
            top: 40, left: 15,
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
              if (!kIsWeb) SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              Get.back();
            }),
          ),
        ],
      ),
    );
  }
}