import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:get/get.dart';
import 'package:app_links/app_links.dart';

// ✅ Firebase ইমপোর্টগুলো রিমুভ করা হয়েছে

import 'package:meetyarah/web_config/web_config_stub.dart'
if (dart.library.html) 'package:meetyarah/web_config/web_config.dart';
import 'package:meetyarah/ui/splashScreens/screens/splash_screens.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

// 🚀 Login Screen ইমপোর্ট করা হলো (লগ-আউট থাকলে এখানে রিডাইরেক্ট হবে)
import 'package:meetyarah/ui/login_reg_screens/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  registerWebView();
  await Get.putAsync(() => AuthService().init());

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

      // 🚀 THE MAGIC: Auth Check (ইউজার লগ-ইন করা আছে কিনা চেক)
      final authService = Get.find<AuthService>();
      final token = authService.token.value;

      if (token != null && token.toString().trim().isNotEmpty && token.toString() != "null") {
        // ✅ ইউজার লগ-ইন অবস্থায় আছে, তাই সরাসরি পোস্টে নিয়ে যাবে
        Get.to(() => PostDetailPage(post: post));
      } else {
        // ❌ ইউজার লগ-আউট অবস্থায় আছে, তাই লগ-ইন স্ক্রিনে পাঠাবে
        Get.offAll(() => const LoginScreen());

        // একটু সময় নিয়ে স্ন্যাকবার দেখাবে যাতে স্ক্রিন ট্রানজিশনের সময় মেসেজটি হারিয়ে না যায়
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            "Login Required 🔒",
            "Please login to your account to view this post.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(20),
            borderRadius: 15,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.lock_person, color: Colors.white),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meetyarah',
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
      ),
      home: const SplashScreen(),
    );
  }
}