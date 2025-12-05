import 'package:flutter/foundation.dart'; // kIsWeb এর জন্য
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:meetyarah/ui/reels/screens/reel_screens.dart';
import 'package:meetyarah/ui/splashScreens/screens/splash_screens.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ওয়েব ভিউ প্যাকেজ ইমপোর্ট (অবশ্যই ধাপ ১ এর কমান্ডটি রান করবেন)
import 'package:webview_flutter_web/webview_flutter_web.dart';

import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ওয়েবের জন্য ওয়েবভিউ প্ল্যাটফর্ম রেজিস্টার করা হচ্ছে
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  await Get.putAsync(() => AuthService().init());

  try {
    Stripe.publishableKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
    await Stripe.instance.applySettings();
  } catch (e) {
    print("⚠️ Stripe Initialization Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen(
          (Uri? uri) {
        if (uri != null) {
          print("🔗 Deep Link Found: $uri");
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        print("❌ Deep Link Error: $err");
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    String? postId = uri.queryParameters['id'];
    if (postId != null) {
      GetPostModel post = GetPostModel(post_id: postId);
      Get.to(() => PostDetailPage(post: post));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meetyarah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ReelScreens(),
    );
  }
}