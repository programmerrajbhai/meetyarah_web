import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';

class ViewProfileController extends GetxController {
  var isLoading = true.obs;
  var userProfile = {}.obs; // প্রোফাইল ডাটা রাখার জন্য ম্যাপ
  var userPosts = <GetPostModel>[].obs; // পোস্ট লিস্ট

  // Follow System Variables
  var isFollowing = false.obs;
  var followersCount = 0.obs;
  var followingCount = 0.obs;
  var isOwnProfile = false.obs; // এটি কি আমার নিজের প্রোফাইল?

  // ডাটা লোড করা
  Future<void> loadUserProfile(int userId) async {
    try {
      isLoading(true);
      String url = "${Urls.getUserProfileApi}?user_id=$userId";
      print("🔹 Fetching Profile: $url");

      networkResponse response = await networkClient.getRequest(url: url);

      if (response.isSuccess && response.data['status'] == 'success') {
        var data = response.data;

        // ১. প্রোফাইল ডাটা সেট করা
        userProfile.value = data['profile'];

        // ২. ফলো স্ট্যাটাস সেট করা
        isFollowing.value = data['profile']['is_following'] ?? false;
        followersCount.value = data['profile']['followers_count'] ?? 0;
        followingCount.value = data['profile']['following_count'] ?? 0;
        isOwnProfile.value = data['profile']['is_own_profile'] ?? false;

        // ৩. পোস্ট লিস্ট সেট করা
        List<dynamic> posts = data['posts'] ?? [];
        userPosts.value = posts.map((e) => GetPostModel.fromJson(e)).toList();

      } else {
        Get.snackbar("Error", "User not found or private");
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading(false);
    }
  }

  // ফলো বা আনফলো করা
  Future<void> toggleFollow(int targetUserId) async {
    // ১. UI তে আগে চেঞ্জ করে দিই (Optimistic Update)
    bool previousState = isFollowing.value;
    isFollowing.value = !previousState;

    if (isFollowing.value) {
      followersCount.value++;
    } else {
      followersCount.value--;
    }

    // ২. সার্ভারে রিকোয়েস্ট পাঠানো
    String url = isFollowing.value ? Urls.followUserApi : Urls.unfollowUserApi;

    networkResponse response = await networkClient.postRequest(
      url: url,
      body: {"target_user_id": targetUserId},
    );

    // ৩. যদি ফেইল করে, তাহলে আগের অবস্থায় ফিরে যাব
    if (!response.isSuccess) {
      isFollowing.value = previousState;
      if (previousState) followersCount.value++; else followersCount.value--;
      Get.snackbar("Error", "Action failed");
    }
  }
}