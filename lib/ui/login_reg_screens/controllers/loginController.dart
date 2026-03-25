import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import '../../../data/utils/urls.dart';
import '../model/user_model.dart';
import 'auth_service.dart';

class LoginController extends GetxController {
  final emailOrPhoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  var isLoading = false.obs;
  var isGuestLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  // --- Regular Login ---
  // FIXED: camelCase for method name (loginUser)
  Future<void> loginUser() async {
    String email = emailOrPhoneCtrl.text.trim();
    String password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Required', "Please enter both email and password",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      Map<String, dynamic> requestBody = {
        "login_identifier": email,
        "password": password,
      };

      // FIXED: PascalCase for Classes (NetworkResponse & NetworkClient)
      NetworkResponse response = await NetworkClient.postRequest(
        url: Urls.loginApi,
        body: requestBody,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        String token = response.data['token'];
        Map<String, dynamic> userData = response.data['user'];

        await _authService.saveUserSession(token, userData);

        emailOrPhoneCtrl.clear();
        passwordCtrl.clear();
        Get.offAll(() => const Basescreens());
      } else {
        Get.snackbar('Failed', response.data['message'] ?? "Invalid credentials",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar('Error', "Something went wrong.");
    } finally {
      isLoading(false);
    }
  }

  // --- GUEST MODE LOGIN (One-Tap & Persistent) ---
  Future<void> loginAsGuest() async {
    try {
      isGuestLoading(true);

      // Simulated API call
      await Future.delayed(const Duration(seconds: 1));

      // Dummy guest data
      String guestToken = "guest_token_${DateTime.now().millisecondsSinceEpoch}";
      Map<String, dynamic> guestUser = {
        "id": "guest_001",
        "name": "Guest User",
        "email": "guest@meetyarah.com",
        "avatar": "",
        "is_guest": true
      };

      await _authService.saveUserSession(guestToken, guestUser);

      Get.snackbar('Welcome', "You are logged in as Guest",
          backgroundColor: Colors.blueGrey, colorText: Colors.white);

      Get.offAll(() => const Basescreens());

    } catch (e) {
      Get.snackbar('Error', "Guest login failed");
    } finally {
      isGuestLoading(false);
    }
  }
}