import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/controllers/story_controller.dart';

class StoryTextPreviewScreen extends StatefulWidget {
  const StoryTextPreviewScreen({super.key});

  @override
  State<StoryTextPreviewScreen> createState() => _StoryTextPreviewScreenState();
}

class _StoryTextPreviewScreenState extends State<StoryTextPreviewScreen> {
  final TextEditingController c = TextEditingController();
  bool sharing = false;

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Future<void> _shareTextStory() async {
    final text = c.text.trim();
    if (text.isEmpty) {
      Get.snackbar("Empty", "Write something first",
          backgroundColor: Colors.black87, colorText: Colors.white);
      return;
    }

    setState(() => sharing = true);

    final res = await networkClient.postRequest(
      url: Urls.uploadStoryTextApi, // ✅ new api
      body: {"text": text},
    );

    setState(() => sharing = false);

    if (res.isSuccess && res.data != null && res.data['status'] == 'success') {
      // refresh stories list
      if (Get.isRegistered<StoryController>()) {
        await Get.find<StoryController>().fetchStories();
      }
      Get.back();
      Get.snackbar("Shared", "Text story posted!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Failed", res.errorMessage ?? "Text upload failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFFC837)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: TextField(
                    controller: c,
                    maxLines: null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "Type your story...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 6,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 18,
              right: 18,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: sharing ? null : _shareTextStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    sharing ? "Sharing..." : "Share",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
