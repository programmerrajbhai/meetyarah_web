import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import '../../../data/utils/urls.dart';
import 'auth_service.dart';

class RegistrationController extends GetxController {
  final firstnameCtrl = TextEditingController();
  final lastnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController(); // ইউজারনেম কন্ট্রোলার
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  var isLoading = false.obs;
  var isGuestLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  // --- Register User ---
  Future<void> RegisterUser() async {
    String firstname = firstnameCtrl.text.trim();
    String lastname = lastnameCtrl.text.trim();
    String rawUsername = usernameCtrl.text.trim();
    String email = emailCtrl.text.trim();
    String password = passwordCtrl.text.trim();

    if (firstname.isEmpty || lastname.isEmpty || rawUsername.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Required',
        "Please fill in all fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
      return;
    }

    try {
      isLoading(true);

      // ✅ লজিক: ইউজারনেমে '@' না থাকলে লাগিয়ে দেওয়া হবে
      String finalUsername = rawUsername.startsWith('@') ? rawUsername : '@$rawUsername';

      Map<String, dynamic> responseBody = {
        "full_name": "$firstname $lastname",
        "username": finalUsername, // ডাটাবেসে @ সহ যাবে
        "email": email,
        "password": password,
      };

      NetworkResponse response = await NetworkClient.postRequest(
        url: Urls.registerApi,
        body: responseBody,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Get.snackbar(
          'Success',
          "Account created! Username: $finalUsername",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // ফর্ম ক্লিয়ার
        firstnameCtrl.clear();
        lastnameCtrl.clear();
        usernameCtrl.clear();
        emailCtrl.clear();
        passwordCtrl.clear();

        // লগইন স্ক্রিনে ফেরত পাঠানো
        Get.back();

      } else {
        Get.snackbar(
          'Failed',
          response.data['message'] ?? "Registration failed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Registration Error: $e");
      Get.snackbar('Error', "Connection failed.");
    } finally {
      isLoading(false);
    }
  }

  // --- Guest Login ---
  Future<void> continueAsGuest() async {
    try {
      isGuestLoading(true);
      await Future.delayed(const Duration(milliseconds: 800));

      String guestToken = "guest_${DateTime.now().millisecondsSinceEpoch}";
      Map<String, dynamic> guestUser = {
        "user_id": 0,
        "username": "@Guest",
        "full_name": "Explorer",
        "email": "",
        "profile_picture_url": null,
      };

      await _authService.saveUserSession(guestToken, guestUser);
      Get.offAll(() => const Basescreens());

    } catch (e) {
      Get.snackbar('Error', "Guest mode error.");
    } finally {
      isGuestLoading(false);
    }
  }

  @override
  void onClose() {
    firstnameCtrl.dispose();
    lastnameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}