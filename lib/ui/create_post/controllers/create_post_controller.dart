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

  var hasInput = false.obs;
  var isLoading = false.obs;

  // মিডিয়া সিলেকশন ভেরিয়েবল
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  Rx<XFile?> selectedVideo = Rx<XFile?>(null);

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // ✅ ফিক্সড: লিসেনার অ্যাড করা হলো
    postTitleCtrl.addListener(_checkInput);

    // ✅ ফিক্সড: ইমেজ বা ভিডিও সিলেক্ট করলেও ইনপুট স্ট্যাটাস চেক করবে
    ever(selectedImage, (_) => _checkInput());
    ever(selectedVideo, (_) => _checkInput());
  }

  // টেক্সট, ইমেজ বা ভিডিও যেকোনো একটি থাকলেই hasInput সত্য হবে
  void _checkInput() {
    hasInput.value = postTitleCtrl.text.trim().isNotEmpty ||
        selectedImage.value != null ||
        selectedVideo.value != null;
  }

  @override
  void onClose() {
    // ✅ ফিক্সড: মেমরি লিক রোধ করা হলো
    postTitleCtrl.removeListener(_checkInput);
    postTitleCtrl.dispose();
    super.onClose();
  }

  // পোস্ট ক্রিয়েট ফাংশন
  Future<void> createPost() async {
    final String content = postTitleCtrl.text.trim();
    final String token = _authService.token.value.toString();

    // টোকেন চেক
    if (token.isEmpty || token == "null") {
      Get.snackbar("Error", "Please login first.", backgroundColor: Colors.redAccent, colorText: Colors.white);
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
        'Accept': 'application/json',
      });

      // 🔥 ফিক্সড: ব্যাকএন্ডে Field Mismatch রোধ করতে caption এবং post_content দুটোই পাঠানো হলো
      // (আপনার PHP ব্যাকএন্ড যেই নামেই খুঁজুক না কেন, ডাটা পেয়ে যাবে)
      request.fields['caption'] = content;
      request.fields['post_content'] = content;

      // --- লজিক: ইমেজ নাকি ভিডিও? ---
      if (selectedImage.value != null) {
        // ১. যদি ইমেজ থাকে
        XFile file = selectedImage.value!;
        if (kIsWeb) {
          var bytes = await file.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: file.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('image', file.path));
        }

      } else if (selectedVideo.value != null) {
        // ২. যদি ভিডিও থাকে
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

      print("🔹 Create Post API Status: ${response.statusCode}");
      print("🔹 Create Post API Response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Get.snackbar("Success", "Post uploaded successfully!", backgroundColor: Colors.green, colorText: Colors.white);

          // সব ক্লিয়ার করে দেওয়া
          postTitleCtrl.clear();
          selectedImage.value = null;
          selectedVideo.value = null;

          // ✅ ফিক্সড: হোম পেজের ফিড নতুন পোস্টসহ রিফ্রেশ করার জন্য await যুক্ত করা হলো
          if (Get.isRegistered<GetPostController>()) {
            await Get.find<GetPostController>().getAllPost();
          }

          Get.offAll(() => const Basescreens());
        } else {
          Get.snackbar("Error", data['message'] ?? "Unknown Error", backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Create Post Error: $e");
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