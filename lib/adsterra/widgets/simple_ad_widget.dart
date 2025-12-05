import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../adsterra_configs.dart';
import '../controller/adsterra_controller.dart';

enum AdType { banner300, banner728, socialBar, native }

class SimpleAdWidget extends StatefulWidget {
  final AdType type;
  const SimpleAdWidget({super.key, required this.type});

  @override
  State<SimpleAdWidget> createState() => _SimpleAdWidgetState();
}

class _SimpleAdWidgetState extends State<SimpleAdWidget> {
  late final WebViewController _controller;
  double containerHeight = 100;
  double containerWidth = 320;

  final adController = Get.put(AdsterraController());
  final String myWebsiteUrl = "https://laraabook.com";

  @override
  void initState() {
    super.initState();
    _calculateSize();
    _setupAd();
  }

  void _calculateSize() {
    switch (widget.type) {
      case AdType.banner300:
        containerHeight = 260;
        containerWidth = 300;
        break;
      case AdType.banner728:
        containerHeight = 100;
        containerWidth = double.infinity;
        break;
      case AdType.socialBar:
        containerHeight = 1;
        containerWidth = 1;
        break;
      case AdType.native:
        containerHeight = 180;
        containerWidth = double.infinity;
        break;
    }
  }

  void _setupAd() {
    String adCode = "";
    switch (widget.type) {
      case AdType.banner300: adCode = AdsterraConfigs.html300x250; break;
      case AdType.banner728: adCode = AdsterraConfigs.html728x90; break;
      case AdType.socialBar: adCode = AdsterraConfigs.htmlSocialBar; break;
      case AdType.native: adCode = AdsterraConfigs.htmlNative; break;
    }

    _controller = WebViewController();

    // ❌ ফিক্স: ওয়েবে এই ফাংশনগুলো কল করা যাবে না
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.setBackgroundColor(Colors.transparent);
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("http")) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    }

    _controller.loadHtmlString(
      """
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
          <style>
            body { margin:0; padding:0; display:flex; justify-content:center; align-items:center; background-color: transparent; overflow: hidden; }
            img { max-width: 100%; height: auto; }
          </style>
        </head>
        <body>
          $adCode
        </body>
      </html>
      """,
      baseUrl: kIsWeb ? null : myWebsiteUrl,
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == AdType.socialBar) {
      return SizedBox(height: 1, width: 1, child: WebViewWidget(controller: _controller));
    }
    if (widget.type == AdType.native) {
      return _buildNativePostWrapper();
    }
    return Container(
      height: containerHeight,
      width: containerWidth,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: WebViewWidget(controller: _controller),
    );
  }

  Widget _buildNativePostWrapper() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            leading: Icon(Icons.star, color: Colors.amber),
            title: Text("Sponsored", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Suggested for you"),
            trailing: Icon(Icons.more_horiz),
            dense: true,
          ),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}