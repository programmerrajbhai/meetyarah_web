import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/reels/profile_screens/screens/view_profile_screens.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

import '../../view_profile/screens/view_profile_screens.dart';

class NotificationController extends GetxController {
  var isLoading = true.obs;
  var isNavigating = false.obs; // যখন পোস্ট লোড হবে তখন লোডার দেখানোর জন্য
  var notifications = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() async {
    try {
      isLoading(true);
      networkResponse response = await networkClient.getRequest(url: Urls.getNotificationsApi);

      if (response.isSuccess) {
        if (response.data['status'] == 'success') {
          notifications.value = response.data['notifications'] ?? [];
        }
      }
    } catch (e) {
      print("Notification Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🔥 এই ফাংশনটিই আসল কাজ করবে
  void handleNotificationTap(var notif) async {
    String type = notif['type'] ?? "";
    int sourceUserId = int.tryParse(notif['source_user_id'].toString()) ?? 0;
    int postId = int.tryParse(notif['post_id'].toString()) ?? 0;

    // ১. যদি Follow হয় -> প্রোফাইল ভিউ
    if (type == 'follow') {
      Get.to(() => ViewProfileScreen(userId: sourceUserId));
    }
    // ২. যদি Like বা Comment হয় -> পোস্ট ডিটেইলস
    else if ((type == 'like' || type == 'comment') && postId != 0) {
      await _fetchPostAndNavigate(postId);
    }
  }

  // পোস্ট ফেচ করে নেভিগেট করার প্রাইভেট ফাংশন
  Future<void> _fetchPostAndNavigate(int postId) async {
    try {
      isNavigating(true); // লোডিং শুরু
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      String url = "${Urls.getSinglePostApi}?post_id=$postId";
      networkResponse response = await networkClient.getRequest(url: url);

      Get.back(); // লোডিং ডায়ালগ বন্ধ
      isNavigating(false);

      if (response.isSuccess && response.data['status'] == 'success') {
        var postData = response.data['post'];
        // মডেল কনভার্ট করা
        GetPostModel post = GetPostModel.fromJson(postData);
        // ডিটেইলস পেজে যাওয়া
        Get.to(() => PostDetailPage(post: post));
      } else {
        Get.snackbar("Error", "Post not found or deleted");
      }
    } catch (e) {
      Get.back(); // এরর হলে লোডিং বন্ধ
      Get.snackbar("Error", "Something went wrong");
    }
  }
}