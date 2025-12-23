import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/profile/controllers/profile_controllers.dart';

import '../controller/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    // ✅ ফিক্সড: মডেল থেকে ইমেজ URL নেওয়া
    String currentPicUrl = "";
    if (Get.isRegistered<ProfileController>()) {
      var user = Get.find<ProfileController>().profileUser.value;
      currentPicUrl = user?.profilePictureUrl ?? "";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Center(child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ))
              : TextButton(
            onPressed: () => controller.updateProfile(),
            child: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.selectedImagePath.value.isNotEmpty) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: kIsWeb
                            ? NetworkImage(controller.selectedImagePath.value)
                            : FileImage(File(controller.selectedImagePath.value)) as ImageProvider,
                      );
                    }
                    else if (currentPicUrl.isNotEmpty) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(currentPicUrl),
                      );
                    }
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    );
                  }),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            TextButton(
              onPressed: controller.pickImage,
              child: const Text("Change Profile Photo"),
            ),
            const SizedBox(height: 30),

            _buildTextField("Name", controller.nameController),
            const SizedBox(height: 20),
            _buildTextField("Bio", controller.bioController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            isDense: true,
          ),
        ),
      ],
    );
  }
}