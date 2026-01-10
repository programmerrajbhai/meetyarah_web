import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import '../controllers/story_controller.dart';
import '../story/story_viewer_screen.dart';

class StoryListWidget extends StatelessWidget {
  const StoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());
    final AuthService authService = Get.find<AuthService>();

    return Container(
      height: 115,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.storyList.length + 1,
          itemBuilder: (context, index) {
            // -------------------- Add Story --------------------
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: controller.isUploading.value
                          ? null
                          : () => controller.pickStoryType(),
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
                                    "https://i.pravatar.cc/150?img=12",
                              ),
                              child: controller.isUploading.value
                                  ? Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
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
                      controller.isUploading.value ? "Uploading..." : "Your Story",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            // -------------------- Story Item --------------------
            final story = controller.storyList[index - 1];

            final String mediaUrl = (story['media_url'] ?? story['image_url'] ?? "").toString();
            final String mediaType = (story['media_type'] ?? "image").toString(); // image/video/text
            final String thumbnailUrl = (story['thumbnail_url'] ?? "").toString(); // optional
            final String text = (story['text'] ?? story['story_text'] ?? "").toString();

            final String userImage = (story['profile_picture_url'] ?? "").toString();
            final String username = (story['username'] ?? "User").toString();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // ✅ FB Style Viewer
                      Get.to(
                            () => StoryViewerScreen(
                          stories: controller.storyList,
                          initialIndex: index - 1,
                        ),
                      );
                    },
                    child: _StoryBubble(
                      userImage: userImage,
                      isSeen: false,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 70,
                    child: Text(
                      username,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // ✅ small hint for media type (optional)
                  if (mediaType == "video")
                    Text("Video", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  if (mediaType == "text")
                    Text("Text", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

/// ✅ FB-like bubble ring
class _StoryBubble extends StatelessWidget {
  final String userImage;
  final bool isSeen;

  const _StoryBubble({
    required this.userImage,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSeen
            ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade300])
            : const LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFFC837)],
        ),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[200],
          backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
          child: userImage.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
        ),
      ),
    );
  }
}
