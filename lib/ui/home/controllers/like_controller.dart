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

    // 1. Optimistic Update (আগে UI চেঞ্জ)
    bool previousStatus = post.isLiked;
    post.isLiked = !post.isLiked;
    post.like_count = post.isLiked
        ? (post.like_count + 1)
        : (post.like_count - 1);

    _postController.posts.refresh();

    // 2. API Call
    try {
      networkResponse response = await networkClient.postRequest(
        url: Urls.likePostApi,
        body: {
          "user_id": userId,
          "post_id": post.post_id,
        },
      );

      if (!response.isSuccess) {
        // ফেইল হলে রিভার্ট করা
        _revert(post, previousStatus);
        Get.snackbar("Failed", "Could not like post. Check connection.");
      }
    } catch (e) {
      print("Like Error: $e");
      _revert(post, previousStatus);
      // এখানে ইউজারকে CORS বা কানেকশন এরর এর ব্যাপারে সতর্ক করা হলো
      Get.snackbar(
          "Network Error",
          "If you are on Web/Localhost, ensure the API allows CORS.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white
      );
    }
  }

  void _revert(var post, bool status) {
    post.isLiked = status;
    post.like_count = post.isLiked
        ? (post.like_count + 1)
        : (post.like_count - 1);
    _postController.posts.refresh();
  }
}