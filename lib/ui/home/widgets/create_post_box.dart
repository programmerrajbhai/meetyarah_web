import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../profile/controllers/profile_controllers.dart';
import '../../create_post/screens/create_post.dart';
import 'feedback_button.dart';

class CreatePostBox extends StatelessWidget {
  const CreatePostBox({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX theke controller find kora hocche
    final profileController = Get.find<ProfileController>();

    return Card(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      elevation: 0.5,
      color: Colors.white,
      shape: kIsWeb
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Obx(() {
              var user = profileController.profileUser.value;

              String profilePicUrl = (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
                  ? user.profilePictureUrl!
                  : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.fullName ?? "User")}&background=random";

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: profilePicUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              );
            }),

            const SizedBox(width: 10),
            Expanded(
              child: FeedbackButton(
                onTap: () => Get.to(() => const CreatePostScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(25)),
                  child: const Text("What's on your mind?",
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
                icon: const Icon(Icons.photo_library, color: Colors.green),
                onPressed: () => Get.to(() => const CreatePostScreen())),
          ],
        ),
      ),
    );
  }
}