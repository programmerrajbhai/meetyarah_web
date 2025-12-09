import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import '../../login_reg_screens/controllers/auth_service.dart';
import 'get_post_controllers.dart';

class LikeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final GetPostController _postController = Get.find<GetPostController>();

  Future<void> toggleLike(int index) async {
    var post = _postController.posts[index];
    String? userId = _authService.userId;

    if (userId == null) {
      Get.snackbar("Error", "Please login to like posts");
      return;
    }

    // --- 1. Optimistic Update (Instant UI Change) ---
    bool previousStatus = post.isLiked; // Purono status save rakha
    int previousCount = post.like_count ?? 0;

    // Toggle Logic
    post.isLiked = !post.isLiked;

    // Count Update
    if (post.isLiked) {
      post.like_count = previousCount + 1;
    } else {
      post.like_count = (previousCount > 0) ? previousCount - 1 : 0;
    }

    // UI Refresh (Eta na dile color change hobe na)
    _postController.posts.refresh();

    // --- 2. API Call (Background e) ---
    try {
      networkResponse response = await networkClient.postRequest(
        url: Urls.likePostApi,
        body: {
          "user_id": userId,
          "post_id": post.post_id,
        },
      );

      if (!response.isSuccess) {
        // Jodi API fail kore, tahole ager obosthay fire jabe
        _revert(post, previousStatus, previousCount);
        Get.snackbar("Failed", "Connection error. Undo like.");
      }
    } catch (e) {
      print("Like Error: $e");
      _revert(post, previousStatus, previousCount);
    }
  }

  // Revert function jodi API fail kore
  void _revert(var post, bool status, int count) {
    post.isLiked = status;
    post.like_count = count;
    _postController.posts.refresh();
  }
}