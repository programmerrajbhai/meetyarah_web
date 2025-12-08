import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import '../../../data/utils/urls.dart';
import '../../login_reg_screens/controllers/auth_service.dart';
import '../models/comments_model.dart';

class CommentController extends GetxController {
  final int postId;
  CommentController({required this.postId});

  var isLoading = false.obs;
  var comments = <CommentModel>[].obs;
  final TextEditingController commentTextController = TextEditingController();

  final AuthService _authService = Get.find<AuthService>();
  // PostController হয়তো সব পেজে লোড নাও থাকতে পারে, তাই এটি optional বা try-catch এ রাখা ভালো
  // final GetPostController _postController = Get.find<GetPostController>();

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

    // --- সমাধান: String থেকে int এ কনভার্ট করা ---
    // যদি userId স্ট্রিং হয়, তবে int.tryParse ব্যবহার করুন
    final int? myUserId = int.tryParse(_authService.userId.toString());

    if (myUserId == null || myUserId == 0) {
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
          'user_id': myUserId, // এখন এটি একটি int হিসেবে যাবে
          'comment_text': text,
        },
      );

      if (response.isSuccess && response.data?['status'] == 'success') {
        await fetchComments(); // রিফ্রেশ
        Get.snackbar('Success', 'Comment added!');
      } else {
        Get.snackbar('Error', 'Failed to add comment.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}