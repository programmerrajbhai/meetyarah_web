import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import '../controllers/story_controller.dart';

class StoryListWidget extends StatelessWidget {
  const StoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());
    final AuthService authService = Get.find<AuthService>();

    return Container(
      height: 115, // হাইট ফিক্সড
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Obx(() {
        // লিস্ট এবং লোডিং হ্যান্ডেলিং
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.storyList.length + 1,
          itemBuilder: (context, index) {

            // --- ১. "Add Story" বাটন (Index 0) ---
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: controller.isUploading.value ? null : () => controller.uploadStory(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(
                                  authService.user.value?.profilePictureUrl ??
                                      "https://i.pravatar.cc/150?img=12"
                              ),
                              child: controller.isUploading.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : null,
                            ),
                          ),
                          if (!controller.isUploading.value)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.add, size: 16, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your Story",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            // --- ২. বন্ধুদের স্টোরি ---
            var story = controller.storyList[index - 1];

            // ডাটা সেফটি চেক
            String storyImage = story['image_url'] ?? "";
            String userImage = story['profile_picture_url'] ?? "";
            String username = story['username'] ?? "User";

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (storyImage.isNotEmpty) {
                        _showStoryDialog(context, storyImage);
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // ইনস্টাগ্রাম কালার গ্রেডিয়েন্ট
                        gradient: LinearGradient(
                          colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFFC837)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: userImage.isNotEmpty
                              ? NetworkImage(userImage)
                              : null,
                          child: userImage.isEmpty
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 70,
                    child: Text(
                      username,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // --- স্টোরি ভিউ ডায়ালগ ---
  void _showStoryDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero, // ফুল স্ক্রিন ভাব আনার জন্য
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            SizedBox(
              width: double.infinity,
              height: 500, // বড় করে দেখাবে
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}