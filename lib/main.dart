import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
// ✅ ১. প্যাকেজ ইমপোর্ট (অবশ্যই থাকতে হবে)
import 'package:app_links/app_links.dart';

import 'package:meetyarah/ui/home/models/get_post_model.dart';

import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';
import 'package:meetyarah/ui/reels/screens/reel_screens.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AuthService ইনিশিয়ালাইজ
  await Get.putAsync(() => AuthService().init());

  // 🔥 Stripe সেটআপ (নিরাপদ উপায়ে)
  try {
    Stripe.publishableKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
    await Stripe.instance.applySettings();
  } catch (e) {
    print("⚠️ Stripe Initialization Error: $e");
    // এরর হলেও অ্যাপ চালু থাকবে
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ✅ ২. সঠিক বানান: AppLinks (বড় হাতের L)
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks(); // ✅ এখানেও বানান ঠিক করা হয়েছে

    // অ্যাপ যখন ব্যাকগ্রাউন্ড বা টার্মিনেটেড অবস্থা থেকে লিংকের মাধ্যমে ওপেন হবে
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print("🔗 Deep Link Found: $uri");
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print("❌ Deep Link Error: $err");
    });
  }

  void _handleDeepLink(Uri uri) {
    // লিংক থেকে পোস্ট আইডি বের করা (যেমন: http://.../post?id=123)
    String? postId = uri.queryParameters['id'];

    if (postId != null) {
      // পোস্ট ডিটেইল পেজে নিয়ে যাওয়া
      // নোট: এখানে আমরা শুধু আইডি দিয়ে একটি ডামি মডেল বানাচ্ছি।
      // বেস্ট প্র্যাকটিস হলো এই আইডি দিয়ে API কল করে ডাটা আনা।
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
      ),
      home: ReelScreens(),
    );
  }
}