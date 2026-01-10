import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'story_image_preview_screen.dart';
import 'story_text_preview_screen.dart';

class StoryTypeScreen extends StatelessWidget {
  const StoryTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Story"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _storyButton(
              icon: Icons.image,
              title: "Image Story",
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);

                if (image != null) {
                  Get.to(() => StoryImagePreviewScreen(image: image));
                }
              },
            ),
            const SizedBox(height: 20),
            _storyButton(
              icon: Icons.text_fields,
              title: "Text Story",
              onTap: () {
                Get.to(() => const StoryTextPreviewScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _storyButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
