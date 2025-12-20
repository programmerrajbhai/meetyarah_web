import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/ui/create_post/controllers/create_post_controller.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/auth_service.dart';
import 'package:meetyarah/ui/login_reg_screens/model/user_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _mediaList = [];

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _mediaList.clear();
        _mediaList.add(pickedFiles.first);
        controller.hasInput.value = true;
      });
    }
  }

  Future<void> _pickVideo() async {
    // ভিডিও ফিচার পরে অ্যাড করা হবে, আপাতত মেসেজ
    Get.snackbar("Info", "Video upload coming soon!");
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaList.removeAt(index);
      if (_mediaList.isEmpty && controller.postTitleCtrl.text.isEmpty) {
        controller.hasInput.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = _authService.user.value;
    String userName = user?.full_name ?? user?.username ?? "User";
    String? profilePic = user?.profile_picture_url;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text("Create Post", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            bool isActive = controller.hasInput.value || _mediaList.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: ElevatedButton(
                onPressed: (isActive && !controller.isLoading.value)
                    ? () => controller.createPost(images: _mediaList)
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                            ? NetworkImage(profilePic)
                            : const NetworkImage("https://i.pravatar.cc/150?img=12"),
                      ),
                      const SizedBox(width: 12),
                      Text(userName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                  if (_mediaList.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            image: kIsWeb
                                ? NetworkImage(_mediaList[0].path)
                                : FileImage(File(_mediaList[0].path)) as ImageProvider,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => _removeMedia(0),
                            child: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(onPressed: _pickImages, icon: const Icon(Icons.photo_library, color: Colors.green), label: const Text("Photo")),
                TextButton.icon(onPressed: _pickVideo, icon: const Icon(Icons.video_call, color: Colors.red), label: const Text("Video")),
              ],
            ),
          )
        ],
      ),
    );
  }
}