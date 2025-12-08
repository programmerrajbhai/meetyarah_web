import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/controllers/get_post_controllers.dart';

import 'package:meetyarah/ui/home/screens/baseScreens.dart';

import '../../login_reg_screens/controllers/auth_service.dart';

class CreatePostController extends GetxController {
  final TextEditingController postTitleCtrl = TextEditingController();
  var isLoading = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  // images এখন List<XFile>
  Future<void> createPost({List<XFile>? images}) async {
    final String content = postTitleCtrl.text.trim();
    final String? userId = _authService.userId;

    if (userId == null || userId.isEmpty) {
      Get.snackbar("Error", "Please login again to post.");
      return;
    }

    if (content.isEmpty && (images == null || images.isEmpty)) {
      Get.snackbar("Alert", "Write something or add an image.");
      return;
    }

    try {
      isLoading(true);
      String? imageUrl;

      if (images != null && images.isNotEmpty) {
        imageUrl = await _uploadImage(images.first);
        if (imageUrl == null) {
          isLoading(false);
          return;
        }
      }

      var response = await http.post(
        Uri.parse(Urls.createPostApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "post_content": content,
          "image_url": imageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Get.snackbar("Success", "Post created successfully!");
        postTitleCtrl.clear();
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

  Future<String?> _uploadImage(XFile xfile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(Urls.uploadImageApi));

      if (kIsWeb) {
        // ✅ ওয়েবের জন্য
        var bytes = await xfile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: xfile.name));
      } else {
        // ✅ মোবাইলের জন্য
        request.files.add(await http.MultipartFile.fromPath('image', xfile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json != null && json['status'] == 'success') {
          return json['image_url'];
        }
      }
      return null;
    } catch (e) {
      print("Upload Exception: $e");
      return null;
    }
  }
}