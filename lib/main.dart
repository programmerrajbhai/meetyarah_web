import 'package:flutter/foundation.dart'; // kIsWeb এর জন্য
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // ওয়েবে মাউস ড্র্যাগ স্ক্রল এর জন্য
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ওয়েব ভিউ প্যাকেজ ইমপোর্ট
import 'package:webview_flutter_web/webview_flutter_web.dart';

// প্রোজেক্ট ইমপোর্ট
import 'package:meetyarah/ui/reels/screens/reel_screens.dart';
import 'package:meetyarah/ui/splashScreens/screens/splash_screens.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart' hide AuthService; // AuthService এর জন্য
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ১. ওয়েবের জন্য ওয়েবভিউ প্ল্যাটফর্ম রেজিস্টার (খুবই গুরুত্বপূর্ণ)
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  // ✅ ২. Auth Service ইনিশিয়ালাইজেশন
  await Get.putAsync(() => AuthService().init());

  // ✅ ৩. স্ট্রাইপ সেটআপ
  try {
    // আপনার সঠিক Publishable Key ব্যবহার করুন
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

  // ✅ ৪. দীপ লিংক (Deep Link) হ্যান্ডলিং
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // অ্যাপ চালু থাকা অবস্থায় লিংক আসলে
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
    // লিংকের কুয়েরি প্যারামিটার চেক (যেমন: domain.com?id=123)
    String? postId = uri.queryParameters['id'];

    if (postId != null) {
      GetPostModel post = GetPostModel(post_id: postId);
      // সরাসরি পোস্ট ডিটেইলস পেজে নিয়ে যাওয়া
      Get.to(() => PostDetailPage(post: post));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meetyarah',

      // ✅ ৫. ওয়েবে মাউস দিয়ে ড্র্যাগ করে স্ক্রল করার জন্য (Touch Scroll Feel)
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // ফন্ট ফ্যামিলি বা অন্যান্য থিম সেটিংস এখানে দিতে পারেন
      ),

      // প্রথমে স্প্ল্যাশ স্ক্রিন বা রিলস স্ক্রিন দেখাবে
      home: Basescreens(),
    );
  }
}