import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/ui/create_post/controllers/create_post_controller.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import 'package:meetyarah/ui/login_reg_screens/model/user_model.dart'; // UserModel ইমপোর্ট করা হলো

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  // লোকাল মিডিয়া লিস্ট (ছবি/ভিডিও রাখার জন্য)
  final List<XFile> _mediaList = [];

  // ছবি পিক করার ফাংশন
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _mediaList.addAll(pickedFiles);
      });
    }
  }

  // ভিডিও পিক করার ফাংশন
  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mediaList.add(pickedFile);
      });
    }
  }

  // মিডিয়া রিমুভ করার ফাংশন
  void _removeMedia(int index) {
    setState(() {
      _mediaList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ফিক্স: userSession এর বদলে user.value এবং Map এর বদলে Model ব্যবহার
    final UserModel? user = _authService.user.value;
    String userName = user?.full_name ?? user?.username ?? "User";
    String? profilePic = user?.profile_picture_url;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Create Post",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // পোস্ট বাটন
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        // কন্ট্রোলারে ছবি পাঠিয়ে পোস্ট করা হচ্ছে
                        controller.createPost(images: _mediaList);
                      },
                style: TextButton.styleFrom(
                  backgroundColor: controller.isLoading.value
                      ? Colors.grey[300]
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("POST",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ইউজার ইনফো
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            (profilePic != null && profilePic.isNotEmpty)
                                ? NetworkImage(profilePic)
                                : const NetworkImage(
                                    "https://i.pravatar.cc/150?img=12"),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Row(
                              children: [
                                Icon(Icons.public,
                                    size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("Public",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. টেক্সট ইনপুট এরিয়া
                  TextField(
                    controller: controller.postTitleCtrl,
                    maxLines: null, // অটো হাইট বাড়বে
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  // 3. মিডিয়া প্রিভিউ (ছবি/ভিডিও)
                  if (_mediaList.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: _mediaList.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? NetworkImage(_mediaList[index].path)
                                      : FileImage(File(_mediaList[index].path))
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // 4. বটম অ্যাকশন বার (মিডিয়া + সেটিংস)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Direct Link Switch
                Obx(() => SwitchListTile(
                      title: const Text("Enable Direct Link Ad",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                          "This post will open a direct link when clicked",
                          style: TextStyle(fontSize: 12)),
                      value: controller.isDirectLink.value,
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        controller.isDirectLink.value = val;
                      },
                    )),

                const Divider(),

                // Media Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _pickImages,
                      icon:
                          const Icon(Icons.photo_library, color: Colors.green),
                      label: const Text("Photo",
                          style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton.icon(
                      onPressed: _pickVideo, // ভিডিও পিকার
                      icon: const Icon(Icons.video_call, color: Colors.red),
                      label: const Text("Video",
                          style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      label: const Text("Camera",
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
