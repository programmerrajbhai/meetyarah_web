import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';

import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:meetyarah/web_config/web_config_stub.dart'
    if (dart.library.html) 'package:meetyarah/web_config/web_config.dart';
import 'package:meetyarah/ui/splashScreens/screens/splash_screens.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("⚠️ Firebase Init Error: $e");
  }
  registerWebView();
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
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

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
      title: 'Larabook',
      navigatorObservers: <NavigatorObserver>[observer],
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
      home: SplashScreen(),
    );

  }
}
