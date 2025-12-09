import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import '../../login_reg_screens/controllers/auth_service.dart';

class GetPostController extends GetxController {
  var posts = <GetPostModel>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
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

      if (myUserId != null && myUserId.isNotEmpty) {
        url = "$url?user_id=$myUserId";
      }

      print("🔹 Fetching Posts from: $url");

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
}