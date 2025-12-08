import 'package:get/get.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/login_screen.dart';

import '../../login_reg_screens/controllers/auth_service.dart';

class SplashController extends GetxController {
  // AuthService কে খুঁজে বের করছি
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // অ্যাপ চালু হলে এই ফাংশন কল হবে
    _moveToNextScreen();
  }

  void _moveToNextScreen() async {
    // ১. ৩ সেকেন্ড অপেক্ষা করা (লোগো দেখানোর জন্য)
    await Future.delayed(const Duration(seconds: 3));

    // ২. চেক করা ইউজার লগইন কিনা
    if (_authService.isLoggedIn) {
      // টোকেন থাকলে সরাসরি হোম পেজে
      Get.offAll(() => const Basescreens());
    } else {
      // টোকেন না থাকলে লগইন পেজে
      Get.offAll(() => const LoginScreen());
    }
  }
}