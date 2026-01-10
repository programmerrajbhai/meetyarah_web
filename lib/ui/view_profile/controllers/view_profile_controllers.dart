import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';

class ViewProfileController extends GetxController {
  var isLoading = true.obs; // প্রথমবার লোডিং এর জন্য
  var userProfile = <String, dynamic>{}.obs;
  var userPosts = <GetPostModel>[].obs;

  // Follow System
  var isFollowing = false.obs;
  var isTargetFollowingMe = false.obs; // সে আমাকে ফলো করে কি না

  var followersCount = 0.obs;
  var followingCount = 0.obs;
  var isOwnProfile = false.obs;

  var isFollowLoading = false.obs; // বাটনের লোডিং

  // 🔥 Helper: PHP থেকে আসা ডাটা (0, 1, "0", "1", true) ঠিকভাবে হ্যান্ডেল করার জন্য
  bool _parseBool(dynamic value) {
    if (value == true || value == 1 || value == "1") return true;
    return false;
  }

  // 🔥 ডাটা লোড করা (Refresh অপশন সহ)
  Future<void> loadUserProfile(int userId, {bool isRefresh = false}) async {
    try {
      if (!isRefresh) isLoading(true); // রিফ্রেশ হলে লোডিং দেখাবো না

      final url = "${Urls.getUserProfileApi}?user_id=$userId";
      print("🚀 Loading Profile: $url");

      final response = await networkClient.getRequest(url: url);

      if (response.isSuccess == true && response.data != null) {
        final data = response.data;

        if (data['status'] == 'success') {
          userProfile.value = Map<String, dynamic>.from(data['profile'] ?? {});

          // ✅ সার্ভার ডাটা পার্সিং
          isFollowing.value = _parseBool(userProfile['is_following']);
          isTargetFollowingMe.value = _parseBool(userProfile['is_following_viewer']);
          isOwnProfile.value = _parseBool(userProfile['is_own_profile']);

          followersCount.value = int.tryParse(userProfile['followers_count'].toString()) ?? 0;
          followingCount.value = int.tryParse(userProfile['following_count'].toString()) ?? 0;

          final List<dynamic> posts = data['posts'] ?? [];
          userPosts.value = posts.map((e) => GetPostModel.fromJson(e)).toList();

          print("✅ Loaded: isFollowing=${isFollowing.value}, Friends=${isFollowing.value && isTargetFollowingMe.value}");
        }
      } else {
        if (!isRefresh) Get.snackbar("Error", "User profile not found");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🔥 Follow / Unfollow
  Future<void> toggleFollow(int targetUserId) async {
    if (isOwnProfile.value) return;
    if (isFollowLoading.value) return;

    // ১. বর্তমান অবস্থা সেভ রাখি (Rollback এর জন্য)
    bool prevFollow = isFollowing.value;
    int prevFollowers = followersCount.value;

    // ২. UI তে আগে আপডেট (Optimistic Update)
    isFollowing.value = !prevFollow;
    if (isFollowing.value) {
      followersCount.value++;
    } else {
      followersCount.value--;
    }

    isFollowLoading(true);

    try {
      final url = isFollowing.value ? Urls.followUserApi : Urls.unfollowUserApi;

      final response = await networkClient.postRequest(
        url: url,
        body: {"target_user_id": targetUserId},
      );

      print("📥 Follow Response: ${response.data}");

      if (response.isSuccess && response.data != null) {
        String msg = (response.data['message'] ?? "").toString().toLowerCase();

        // ✅ সার্ভার যদি বলে "Already following", তাহলে UI তে true সেট করে দেব
        if (msg.contains("already following")) {
          isFollowing.value = true;
          // যদি UI তে আগে false ছিল, তাহলে কাউন্ট ঠিক আছে।
        }
        // ✅ সার্ভার যদি বলে "Not following"
        else if (msg.contains("not following") || msg.contains("failed")) {
          // এটা সাধারণত unfollow এর রেসপন্স
        }

      } else {
        // ফেইল করলে আগের অবস্থায় ফিরে যাওয়া
        isFollowing.value = prevFollow;
        followersCount.value = prevFollowers;
        Get.snackbar("Error", "Action failed");
      }
    } catch (e) {
      isFollowing.value = prevFollow;
      followersCount.value = prevFollowers;
      Get.snackbar("Error", "Network error");
    } finally {
      isFollowLoading(false);
    }
  }
}