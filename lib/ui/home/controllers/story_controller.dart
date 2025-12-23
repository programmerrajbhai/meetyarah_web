import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';

class StoryController extends GetxController {
  // স্টোরি লিস্ট
  var storyList = [].obs;
  var isLoading = true.obs;
  var isUploading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    fetchStories();
  }

  // ১. স্টোরি লোড করা
  void fetchStories() async {
    try {
      // প্রথমবার লোড করার সময় লোডার দেখাবে
      if (storyList.isEmpty) isLoading(true);

      print("Fetching stories from: ${Urls.getStoriesApi}"); // ডিবাগিং

      var response = await networkClient.getRequest(url: Urls.getStoriesApi);

      // রেসপন্স প্রিন্ট করে দেখুন কনসোলে
      print("Story Response: ${response.data}");

      if (response.isSuccess) {
        if (response.data['status'] == 'success') {
          var rawList = response.data['stories'];
          if (rawList != null) {
            storyList.assignAll(rawList); // ✅ লিস্ট ফোর্স আপডেট
          }
        }
      }
    } catch (e) {
      print("Story Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // ২. স্টোরি আপলোড করা
  void uploadStory() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        isUploading(true);

        Get.snackbar(
            "Uploading",
            "Adding to your story...",
            showProgressIndicator: true,
            backgroundColor: Colors.blueAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM
        );

        Map<String, String> fields = {
          "user_id": _authService.userId ?? "",
        };

        var response = await networkClient.multipartRequest(
          url: Urls.uploadStoryApi,
          fields: fields,
          imagePath: image.path,
          imageKey: 'image',
        );

        if (response.isSuccess) {
          Get.snackbar("Success", "Story added!", backgroundColor: Colors.green, colorText: Colors.white);
          fetchStories(); // ✅ আপলোড শেষে রিফ্রেশ
        } else {
          Get.snackbar("Failed", "Could not upload story", backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        print("Upload Error: $e");
      } finally {
        isUploading(false);
      }
    }
  }
}