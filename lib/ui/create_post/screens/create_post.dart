import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/create_post/controllers/create_post_controller.dart';
// ✅ ফিক্সড: ProfileController ইমপোর্ট করা হলো
import 'package:meetyarah/ui/profile/controllers/profile_controllers.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // আগের কন্ট্রোলারটিই ব্যবহার করা হচ্ছে
  final CreatePostController controller = Get.put(CreatePostController());

  // ✅ ফিক্সড: ইউজারের লেটেস্ট ডাটা পাওয়ার জন্য ProfileController কল করা হলো
  final ProfileController _profileController = Get.put(ProfileController());

  // মিডিয়া রিমুভ করার ফাংশন
  void _removeMedia() {
    controller.selectedImage.value = null;
    controller.selectedVideo.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text("Create Post",
            style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            // ইনপুট চেক: টেক্সট আছে অথবা ইমেজ আছে অথবা ভিডিও আছে
            bool isActive = controller.hasInput.value ||
                controller.selectedImage.value != null ||
                controller.selectedVideo.value != null;

            return Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton(
                onPressed: (isActive && !controller.isLoading.value)
                    ? () => controller.createPost()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  disabledBackgroundColor: Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("POST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ),

      // --- BODY ---
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- ✅ ফিক্সড: User Info Row from ProfileController ---
                  Obx(() {
                    var user = _profileController.profileUser.value;

                    String userName = (user?.fullName != null && user!.fullName.isNotEmpty)
                        ? user.fullName
                        : (user?.username ?? "User");

                    String profilePic = (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
                        ? user.profilePictureUrl!
                        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random";

                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CachedNetworkImage(
                            imageUrl: profilePic,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(userName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),

                  // Text Input
                  TextField(
                    controller: controller.postTitleCtrl,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  // --- MEDIA PREVIEW SECTION ---
                  Obx(() {
                    if (controller.selectedImage.value != null) {
                      // ১. ইমেজ প্রিভিউ
                      return _buildMediaPreview(
                        child: kIsWeb
                            ? Image.network(controller.selectedImage.value!.path, fit: BoxFit.cover, width: double.infinity)
                            : Image.file(File(controller.selectedImage.value!.path), fit: BoxFit.cover, width: double.infinity),
                      );
                    } else if (controller.selectedVideo.value != null) {
                      // ২. ভিডিও প্রিভিউ (ভিডিও প্লেয়ার ছাড়া আইকন দেখানো হচ্ছে)
                      return _buildMediaPreview(
                        child: Container(
                          color: Colors.black,
                          width: double.infinity,
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
                                const SizedBox(height: 10),
                                Text(
                                  "Video Selected",
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  controller.selectedVideo.value!.name, // ভিডিওর নাম
                                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ],
              ),
            ),
          ),

          // --- BOTTOM ACTION BAR ---
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => controller.pickImageFromGallery(),
                  icon: const Icon(Icons.photo_library, color: Colors.green),
                  label: const Text("Photo"),
                ),
                TextButton.icon(
                  onPressed: () => controller.pickVideoFromGallery(),
                  icon: const Icon(Icons.video_call, color: Colors.red),
                  label: const Text("Video"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // প্রিভিউ দেখানোর জন্য কমন উইজেট (ইমেজ ও ভিডিও উভয়ের জন্য)
  Widget _buildMediaPreview({required Widget child}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 250, // ফিক্সড হাইট প্রিভিউ এর জন্য
            width: double.infinity,
            child: child,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeMedia,
            child: const CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 14,
              child: Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}