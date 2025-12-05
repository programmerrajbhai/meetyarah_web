import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_controller.dart';

class GetPostController extends GetxController {
  var posts = <GetPostModel>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs; // এরর ট্র্যাক করার জন্য
  var errorMessage = ''.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    getAllPost();
  }

  Future<void> getAllPost() async {
    try {
      isLoading(true);
      hasError(false);

      String? myUserId = _authService.userId;
      String url = Urls.get_all_posts;

      // ইউজার আইডি থাকলে প্যারামিটার হিসেবে যোগ করা
      if (myUserId != null && myUserId.isNotEmpty) {
        url = "$url?user_id=$myUserId";
      }

      print("🔹 Fetching Posts from: $url"); // কনসোলে ইউআরএল চেক করুন

      networkResponse response = await networkClient.getRequest(url: url);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final List data = response.data['posts'] ?? [];
          posts.value = data.map((e) => GetPostModel.fromJson(e)).toList();
          print("✅ Posts Loaded: ${posts.length}");
        } else {
          hasError(true);
          errorMessage.value = response.data['message'] ?? "No posts found";
        }
      } else {
        hasError(true);
        errorMessage.value = "Failed to load data (Status: ${response.statusCode})";

        // ওয়েবে লোকালহোস্ট সমস্যার জন্য বিশেষ মেসেজ
        if (kIsWeb && response.statusCode == 0) {
          errorMessage.value = "CORS Error or Connection Failed.\nWeb browsers block local IP (192.168...).";
        }
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      hasError(true);
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading(false);
    }
  }

  // লাইক টগল ফাংশন (আগের মতোই)
  Future<void> toggleLike(int index) async {
    var post = posts[index];
    String? userId = _authService.userId;

    if (userId == null) {
      Get.snackbar("Error", "Please login to like posts");
      return;
    }

    bool previousState = post.isLiked;
    post.isLiked = !post.isLiked;
    post.like_count = post.isLiked ? (post.like_count + 1) : (post.like_count - 1);
    posts.refresh();

    try {
      await networkClient.postRequest(
        url: Urls.likePostApi,
        body: {"user_id": userId, "post_id": post.post_id},
      );
    } catch (e) {
      post.isLiked = previousState;
      posts.refresh();
    }
  }
}