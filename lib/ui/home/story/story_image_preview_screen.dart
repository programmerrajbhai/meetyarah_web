import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/story_controller.dart';

class StoryImagePreviewScreen extends StatefulWidget {
  final XFile image;
  const StoryImagePreviewScreen({super.key, required this.image});

  @override
  State<StoryImagePreviewScreen> createState() => _StoryImagePreviewScreenState();
}

class _StoryImagePreviewScreenState extends State<StoryImagePreviewScreen> {
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    bytes = await widget.image.readAsBytes();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.find<StoryController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: bytes == null
                ? const CircularProgressIndicator(color: Colors.white)
                : Image.memory(bytes!, fit: BoxFit.contain),
          ),

          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.isUploading.value
                    ? null
                    : () => controller.uploadImageStory(widget.image),
                icon: Obx(() => controller.isUploading.value
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.send)),
                label: Obx(() => Text(controller.isUploading.value ? "Sharing..." : "Share")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
