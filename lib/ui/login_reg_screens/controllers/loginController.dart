import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import '../../../data/utils/urls.dart';
import 'auth_service.dart';

class LoginController extends GetxController {
  final emailOrPhoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  var isLoading = false.obs;

  // AuthService খুঁজে বের করি
  final AuthService _authService = Get.find<AuthService>();

  Future<void> LoginUser() async {
    String email = emailOrPhoneCtrl.text.trim();
    String password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        "Please enter both email and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading(true);

      Map<String, dynamic> requestBody = {
        "login_identifier": email,
        "password": password,
      };

      networkResponse response = await networkClient.postRequest(
        url: Urls.loginApi,
        body: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {

        String token = response.data['token'];
        Map<String, dynamic> userData = response.data['user'];

        // AuthService-এ ডাটা সেভ করি
        await _authService.saveUserSession(token, userData);

        // --- পরিবর্তন: টোকেনটি Snackbar-এ দেখানো হচ্ছে ---
        Get.snackbar(
          'Login Successful!',
          "Token: $token", // এখানে টোকেন প্রিন্ট হবে
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4), // টোকেন দেখার জন্য সময় বাড়ালাম
        );

        // ইনপুট ক্লিয়ার করি
        emailOrPhoneCtrl.clear();
        passwordCtrl.clear();

        // হোম পেজে যাই
        Get.offAll(() => const Basescreens());

      } else {
        Get.snackbar(
          'Login Failed',
          response.data['message'] ?? "Invalid credentials",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar(
        'Error',
        "Something went wrong. Check your connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}