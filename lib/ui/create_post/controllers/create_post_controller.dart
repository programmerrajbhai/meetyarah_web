import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/controllers/get_post_controllers.dart';
import 'package:meetyarah/ui/home/screens/baseScreens.dart';
import '../../login_reg_screens/controllers/auth_service.dart';

class CreatePostController extends GetxController {
  final TextEditingController postTitleCtrl = TextEditingController();

  var isLoading = false.obs;
  var hasInput = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // কিছু লিখলে বাটন অ্যাক্টিভ হবে
    postTitleCtrl.addListener(() {
      hasInput.value = postTitleCtrl.text.trim().isNotEmpty;
    });
  }

  Future<void> createPost({List<XFile>? images}) async {
    final String content = postTitleCtrl.text.trim();
    final String? userId = _authService.userId;

    if (userId == null || userId.isEmpty) {
      Get.snackbar("Error", "Please login again to post.");
      return;
    }

    try {
      isLoading(true);

      // ✅ মাল্টিপার্ট রিকোয়েস্ট
      var request = http.MultipartRequest('POST', Uri.parse(Urls.createPostApi));

      // শুধুমাত্র প্রয়োজনীয় ডাটা পাঠানো হচ্ছে (Direct Link রিমুভড)
      request.fields['user_id'] = userId;
      request.fields['post_content'] = content;

      // ছবি থাকলে তা ফাইলে যোগ করা
      if (images != null && images.isNotEmpty) {
        XFile imageFile = images.first;

        if (kIsWeb) {
          var bytes = await imageFile.readAsBytes();
          request.files.add(
              http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name)
          );
        } else {
          request.files.add(
              await http.MultipartFile.fromPath('image', imageFile.path)
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Server Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Get.snackbar("Success", "Post created successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);

        postTitleCtrl.clear();
        hasInput.value = false;

        if (Get.isRegistered<GetPostController>()) {
          Get.find<GetPostController>().getAllPost();
        }

        Get.offAll(() => const Basescreens());
      } else {
        Get.snackbar("Error", data['message'] ?? "Failed to create post");
      }

    } catch (e) {
      print("Create Post Error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading(false);
    }
  }
}