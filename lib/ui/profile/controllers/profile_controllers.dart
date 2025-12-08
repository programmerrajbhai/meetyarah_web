import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';

import '../../login_reg_screens/controllers/auth_service.dart';
import '../model/profile_user_model.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var profileUser = Rxn<ProfileUserModel>();
  var myPosts = <GetPostModel>[].obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    getMyProfileData();
  }

  Future<void> getMyProfileData() async {
    // 1. AuthService থেকে আইডি চেক করা
    // (আইডি int বা String যাই হোক, স্ট্রিং এ কনভার্ট করে নিচ্ছি)
    final String? myIdStr = _authService.user.value?.user_id?.toString();

    print("🔹 ProfileController Start: User ID is '$myIdStr'"); // DEBUG

    if (myIdStr == null || myIdStr.isEmpty) {
      print("❌ Error: User ID not found. Please Login Again.");
      isLoading(false);
      // আইডি না থাকলে লোড হবে না, তাই রিটার্ন করছি
      return;
    }

    try {
      isLoading(true);

      String url = "${Urls.getUserProfileApi}?user_id=$myIdStr";
      print("🔹 Calling API: $url"); // DEBUG

      networkResponse response = await networkClient.getRequest(url: url);

      print("🔹 Status Code: ${response.statusCode}"); // DEBUG

      // 2. রেসপন্স বডি চেক (পুরো ডাটা আসছে কি না দেখুন)
      // print("🔹 Response Data: ${response.data}");

      if (response.isSuccess && response.data != null && response.data['status'] == 'success') {

        // 3. প্রোফাইল ডেটা পার্সিং
        var profileData = response.data['profile'];
        if (profileData != null) {
          profileUser.value = ProfileUserModel.fromJson(profileData);
          print("✅ Profile Loaded: ${profileUser.value?.username}");
        }

        // 4. পোস্ট ডেটা পার্সিং
        List<dynamic> postList = response.data['posts'] ?? [];
        print("🔹 Found ${postList.length} posts in response.");

        myPosts.value = postList.map((json) {
          // প্রোফাইল থেকে নাম/ছবি নিয়ে পোস্টে বসাচ্ছি
          json['username'] = profileUser.value?.username;
          json['full_name'] = profileUser.value?.fullName;
          json['profile_picture_url'] = profileUser.value?.profilePictureUrl;

          return GetPostModel.fromJson(json);
        }).toList();

        print("✅ Posts List Updated: ${myPosts.length} items");

      } else {
        print("❌ API Error: ${response.data}");
        Get.snackbar("Error", "Failed to load profile data");
      }
    } catch (e) {
      print("❌ Exception in Profile: $e");
    } finally {
      isLoading(false); // লোডিং বন্ধ
    }
  }

  void logout() {
    _authService.logout();
  }
}