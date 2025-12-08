import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import '../../../data/utils/urls.dart';
import '../../home/controllers/get_post_controllers.dart';

import '../../login_reg_screens/controllers/auth_service.dart';
import '../../view_post/models/comments_model.dart';


class CommentController extends GetxController {
  final int postId;
  CommentController({required this.postId});

  var isLoading = false.obs;
  var comments = <CommentModel>[].obs;
  final TextEditingController commentTextController = TextEditingController();

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      isLoading(true);
      String url = "${Urls.getCommentsApi}?post_id=$postId";
      networkResponse response = await networkClient.getRequest(url: url);

      if (response.isSuccess && response.data?['status'] == 'success') {
        List<dynamic> data = response.data!['comments'];
        comments.value = data.map((json) => CommentModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching comments: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addComment() async {
    final text = commentTextController.text.trim();
    if (text.isEmpty) return;

    final String? myUserId = _authService.userId;
    if (myUserId == null) {
      Get.snackbar("Error", "Please login again.");
      return;
    }

    try {
      commentTextController.clear();
      FocusScope.of(Get.context!).unfocus();

      networkResponse response = await networkClient.postRequest(
        url: Urls.addCommentApi,
        body: {
          'post_id': postId,
          'user_id': myUserId,
          'comment_text': text,
        },
      );

      if (response.isSuccess && response.data?['status'] == 'success') {
        await fetchComments(); // কমেন্ট লিস্ট রিফ্রেশ
        Get.snackbar('Success', 'Comment added!');

        // ✅ মেইন ফিডের কমেন্ট কাউন্ট আপডেট করা
        _updateFeedCommentCount();

      } else {
        Get.snackbar('Error', 'Failed to add comment.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // ফিডের কাউন্ট বাড়ানোর ফাংশন
  void _updateFeedCommentCount() {
    if (Get.isRegistered<GetPostController>()) {
      final postController = Get.find<GetPostController>();
      // লিস্ট থেকে পোস্টটি খুঁজে বের করা
      try {
        var post = postController.posts.firstWhere((p) => p.post_id == postId.toString());
        post.comment_count = (post.comment_count ?? 0) + 1;
        postController.posts.refresh(); // UI আপডেট
      } catch (e) {
        print("Post not found in feed list to update count");
      }
    }
  }
}