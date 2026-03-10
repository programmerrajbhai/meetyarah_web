import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profile/controllers/profile_controllers.dart';
import '../controllers/story_controller.dart';
import '../story/story_viewer_screen.dart';

class StoryListWidget extends StatelessWidget {
  const StoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());
    final ProfileController profileController = Get.put(ProfileController());

    return Container(
      height: 190, // স্টোরি কার্ডের হাইট অনুযায়ী কন্টেইনার বড় করা হলো
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.storyList.length + 1,
          itemBuilder: (context, index) {

            // -------------------- Add Story (My Profile / Create Story) --------------------
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: GestureDetector(
                  onTap: controller.isUploading.value ? null : () => controller.pickStoryType(),
                  child: Container(
                    width: 110,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 5, spreadRadius: 1)
                      ],
                    ),
                    child: Stack(
                      children: [
                        // উপরের অংশে ইউজারের নিজের ছবি
                        Positioned(
                          top: 0, left: 0, right: 0, bottom: 45,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Builder(
                              builder: (context) {
                                var user = profileController.profileUser.value;
                                String userName = (user?.fullName != null && user!.fullName.isNotEmpty)
                                    ? user.fullName
                                    : (user?.username ?? "User");
                                String profilePicUrl = (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
                                    ? user.profilePictureUrl!
                                    : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random";

                                return CachedNetworkImage(
                                  imageUrl: profilePicUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                                );
                              },
                            ),
                          ),
                        ),
                        // নিচের সাদা অংশ
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 45,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  controller.isUploading.value ? "Uploading..." : "Create Story",
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // মাঝখানে প্লাস (+) বাটন
                        Positioned(
                          bottom: 25, left: 0, right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: controller.isUploading.value
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.add, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // -------------------- Story Item (Others) --------------------
            final story = controller.storyList[index - 1];

            final String mediaUrl = (story['media_url'] ?? story['image_url'] ?? "").toString();
            final String mediaType = (story['media_type'] ?? "image").toString(); // image/video/text
            final String thumbnailUrl = (story['thumbnail_url'] ?? "").toString();

            final String userImage = (story['profile_picture_url'] ?? "").toString();
            final String username = (story['username'] ?? "User").toString();

            // স্টোরির ব্যাকগ্রাউন্ড ইমেজ (ভিডিও হলে থাম্বনেইল, ইমেজ হলে ইমেজ, নাহলে ইউজারের প্রোফাইল পিক)
            String backgroundImageUrl = mediaUrl.isNotEmpty && mediaType == "image"
                ? mediaUrl
                : (thumbnailUrl.isNotEmpty ? thumbnailUrl : userImage);

            String safeUserImageUrl = userImage.isNotEmpty
                ? userImage
                : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=random";

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  Get.to(
                        () => StoryViewerScreen(
                      stories: controller.storyList,
                      initialIndex: index - 1,
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[800],
                    image: backgroundImageUrl.isNotEmpty
                        ? DecorationImage(
                      image: CachedNetworkImageProvider(backgroundImageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // কালার ওভারলে (যাতে টেক্সট স্পষ্ট বোঝা যায়)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // প্রোফাইল পিকচার (উপরে বামে)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent, // ফেসবুক স্টাইল ব্লু বর্ডার
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: safeUserImageUrl,
                              width: 32, height: 32,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[400]),
                              errorWidget: (context, url, error) => Container(color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),

                      // ইউজারের নাম (নিচে)
                      Positioned(
                        bottom: 8, left: 8, right: 8,
                        child: Text(
                          username,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // মিডিয়া টাইপ হিন্ট (ভিডিও হলে প্লে আইকন)
                      if (mediaType == "video")
                        const Positioned(
                          top: 10, right: 10,
                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}