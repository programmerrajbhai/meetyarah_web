import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import 'package:meetyarah/ui/profile/controllers/profile_controllers.dart';

class EditProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  var isLoading = false.obs;
  var selectedImagePath = ''.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentData();
  }

  // ✅ ফিক্সড: এখন মডেল থেকে ডাটা লোড হবে
  void _loadCurrentData() {
    if (Get.isRegistered<ProfileController>()) {
      var user = Get.find<ProfileController>().profileUser.value; // userProfile -> profileUser.value

      // মডেল থেকে ডাটা নিচ্ছি
      nameController.text = user?.fullName ?? "";
      // আপনার মডেলে 'bio' ফিল্ড নেই, যদি থাকে তবে user?.bio দেবেন। না থাকলে ফাঁকা রাখুন।
      // bioController.text = user?.bio ?? "";
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  Future<void> updateProfile() async {
    isLoading(true);

    Map<String, String> fields = {
      "user_id": _authService.userId ?? "",
      "full_name": nameController.text,
      "bio": bioController.text,
    };

    try {
      var response = await networkClient.multipartRequest(
        url: Urls.updateProfileApi,
        fields: fields,
        imagePath: selectedImagePath.value.isNotEmpty ? selectedImagePath.value : null,
        imageKey: 'profile_image',
      );

      if (response.isSuccess && response.data['status'] == 'success') {
        Get.snackbar("Success", "Profile updated successfully!", backgroundColor: Colors.green, colorText: Colors.white);

        // প্রোফাইল পেজ রিফ্রেশ করা
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getMyProfileData();
        }

        Get.back();
      } else {
        Get.snackbar("Error", response.data['message'] ?? "Failed to update");
      }
    } catch (e) {
      print("Update Error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading(false);
    }
  }
}