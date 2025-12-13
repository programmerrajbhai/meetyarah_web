import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_post_controller.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreatePostController controller = Get.put(CreatePostController());

    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.postTitleCtrl,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Direct Link Toggle
            Obx(() => SwitchListTile(
              title: const Text("Direct Link Post"),
              value: controller.isDirectLink.value,
              onChanged: (val) {
                controller.isDirectLink.value = val;
                if (val) {
                  controller.directUrl = "https://google.com"; // hidden set
                } else {
                  controller.directUrl = null;
                }
              },
            )),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                controller.createPost();
              },
              child: Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Post")),
            ),
          ],
        ),
      ),
    );
  }
}
