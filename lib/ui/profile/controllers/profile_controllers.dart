import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';

import '../../login_reg_screens/controllers/auth_service.dart';
// ⚠️ আপনার ProfileUserModel ফাইলটি যেখানে আছে তার সঠিক ইমপোর্ট দিন
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
    final String? myIdStr = _authService.user.value?.user_id?.toString();

    if (myIdStr == null || myIdStr.isEmpty || myIdStr == "null") {
      print("❌ Error: User ID not found.");
      isLoading(false);
      return;
    }

    try {
      isLoading(true);

      String url = "${Urls.getUserProfileApi}?user_id=$myIdStr";
      networkResponse response = await networkClient.getRequest(url: url);

      if (response.isSuccess && response.data != null && response.data['status'] == 'success') {

        // ১. প্রোফাইল ডেটা পার্সিং (ফলোয়ার ডাটা সহ)
        var profileData = response.data['profile'];
        if (profileData != null) {
          profileUser.value = ProfileUserModel.fromJson(profileData);
        }

        // ২. পোস্ট ডেটা পার্সিং
        List<dynamic> postList = response.data['posts'] ?? [];
        var parsedPosts = <GetPostModel>[];

        for (var item in postList) {
          if (item is Map<String, dynamic>) {
            var modifiedJson = Map<String, dynamic>.from(item);
            modifiedJson['username'] = profileUser.value?.username;
            modifiedJson['full_name'] = profileUser.value?.fullName;
            modifiedJson['profile_picture_url'] = profileUser.value?.profilePictureUrl;

            parsedPosts.add(GetPostModel.fromJson(modifiedJson));
          }
        }

        myPosts.value = parsedPosts;

      } else {
        Get.snackbar("Error", "Failed to load profile data");
      }
    } catch (e) {
      print("❌ Exception in Profile: $e");
    } finally {
      isLoading(false);
    }
  }

  void logout() {
    _authService.logout();
  }
}