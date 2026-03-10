import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// ✅ ফিক্সড: ProfileController ইমপোর্ট করা হলো
import '../../profile/controllers/profile_controllers.dart';
import '../controllers/story_controller.dart';
import '../story/story_viewer_screen.dart';

class StoryListWidget extends StatelessWidget {
  const StoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());
    // ✅ ফিক্সড: ইউজারের লেটেস্ট প্রোফাইল পিকচার পেতে ProfileController কল করা হলো
    final ProfileController profileController = Get.put(ProfileController());

    return Container(
      height: 115,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.storyList.length + 1,
          itemBuilder: (context, index) {
            // -------------------- Add Story (My Profile) --------------------
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
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            // ✅ ফিক্সড: নিজের লেটেস্ট ছবি এবং CachedNetworkImage ব্যবহার করা হলো
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Builder(
                                builder: (context) {
                                  var user = profileController.profileUser.value;
                                  String userName = (user?.fullName != null && user!.fullName.isNotEmpty)
                                      ? user.fullName
                                      : (user?.username ?? "User");

                                  String profilePicUrl = (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
                                      ? user.profilePictureUrl!
                                      : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random";

                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: profilePicUrl,
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
                                      if (controller.isUploading.value)
                                        Container(
                                          color: Colors.black45,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
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

            // -------------------- Story Item (Others) --------------------
            final story = controller.storyList[index - 1];

            final String mediaType = (story['media_type'] ?? "image").toString(); // image/video/text
            final String userImage = (story['profile_picture_url'] ?? "").toString();
            final String username = (story['username'] ?? "User").toString();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(
                            () => StoryViewerScreen(
                          stories: controller.storyList,
                          initialIndex: index - 1,
                        ),
                      );
                    },
                    child: _StoryBubble(
                      userImage: userImage,
                      userName: username, // নামের অক্ষর দিয়ে ডিফল্ট ছবি তৈরির জন্য নাম পাঠানো হলো
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

                  // small hint for media type
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
  final String userName;
  final bool isSeen;

  const _StoryBubble({
    required this.userImage,
    required this.userName,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ফিক্সড: অন্যদের স্টোরির ছবিতেও সেফ ইমেজ লোডিং যুক্ত করা হলো
    String safeImageUrl = userImage.isNotEmpty
        ? userImage
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random";

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
      child: Container(
        padding: const EdgeInsets.all(2), // সাদা গ্যাপ
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26), // 52 এর অর্ধেক
          child: CachedNetworkImage(
            imageUrl: safeImageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}