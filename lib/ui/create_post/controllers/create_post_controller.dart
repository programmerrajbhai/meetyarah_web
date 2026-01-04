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

  // ✅ Missing Variable Added
  var hasInput = false.obs;
  var isLoading = false.obs;

  // মিডিয়া সেলেকশন ভেরিয়েবল
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  Rx<XFile?> selectedVideo = Rx<XFile?>(null);

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // ✅ Listener added: টেক্সট লিখলে hasInput সত্য হবে
    postTitleCtrl.addListener(() {
      hasInput.value = postTitleCtrl.text.trim().isNotEmpty;
    });
  }

  // পোস্ট ক্রিয়েট ফাংশন
  Future<void> createPost() async {
    final String content = postTitleCtrl.text.trim();
    final String token = _authService.token.value;

    if (token.isEmpty) {
      Get.snackbar("Error", "Please login first.");
      return;
    }

    // ভ্যালিডেশন: টেক্সট, ইমেজ বা ভিডিও—কিছু একটা থাকতেই হবে
    if (content.isEmpty && selectedImage.value == null && selectedVideo.value == null) {
      Get.snackbar("Warning", "Write something or add photo/video.");
      return;
    }

    try {
      isLoading(true);

      var request = http.MultipartRequest('POST', Uri.parse(Urls.createPostApi));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      });

      request.fields['caption'] = content;

      // --- লজিক: ইমেজ নাকি ভিডিও? ---

      if (selectedImage.value != null) {
        // ১. যদি ইমেজ থাকে -> 'image' ফিল্ডে পাঠাবো
        XFile file = selectedImage.value!;
        if (kIsWeb) {
          var bytes = await file.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: file.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('image', file.path));
        }

      } else if (selectedVideo.value != null) {
        // ২. যদি ভিডিও থাকে -> 'video' ফিল্ডে পাঠাবো
        XFile file = selectedVideo.value!;
        if (kIsWeb) {
          var bytes = await file.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('video', bytes, filename: file.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('video', file.path));
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Get.snackbar("Success", "Post uploaded!", backgroundColor: Colors.green, colorText: Colors.white);

          // সব ক্লিয়ার করে দেওয়া
          postTitleCtrl.clear();
          hasInput.value = false; // রিসেট
          selectedImage.value = null;
          selectedVideo.value = null;

          if (Get.isRegistered<GetPostController>()) {
            Get.find<GetPostController>().getAllPost();
          }
          Get.offAll(() => const Basescreens());
        } else {
          Get.snackbar("Error", data['message'] ?? "Unknown Error");
        }
      } else {
        Get.snackbar("Error", "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Check internet connection.");
    } finally {
      isLoading(false);
    }
  }

  // --- UI থেকে কল করার ফাংশন ---

  void pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
      selectedVideo.value = null; // ভিডিও থাকলে সরিয়ে দিব
    }
  }

  void pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedVideo.value = video;
      selectedImage.value = null; // ইমেজ থাকলে সরিয়ে দিব
    }
  }
}