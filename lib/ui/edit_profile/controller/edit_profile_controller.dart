import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/profile/controllers/profile_controllers.dart';

class EditProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  var isLoading = false.obs;
  var selectedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    if (Get.isRegistered<ProfileController>()) {
      var user = Get.find<ProfileController>().profileUser.value;

      nameController.text = user?.fullName ?? "";
      // ✅ ফিক্সড: Bio ডাটা আনকমেন্ট করা হয়েছে
      bioController.text = user?.bio ?? "";
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

    // ✅ ফিক্সড: user_id রিমুভ করা হয়েছে কারণ ব্যাকএন্ড টোকেন থেকেই আইডি নিয়ে নেয়
    Map<String, String> fields = {
      "full_name": nameController.text.trim(),
      "bio": bioController.text.trim(),
    };

    try {
      var response = await networkClient.multipartRequest(
        url: Urls.updateProfileApi,
        fields: fields,
        imagePath: selectedImagePath.value.isNotEmpty ? selectedImagePath.value : null,
        // 🔥 ফিক্সড: ব্যাকএন্ডের সাথে মিলিয়ে 'profile_picture' দেওয়া হলো
        imageKey: 'profile_picture',
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
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      isLoading(false);
    }
  }
}