import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';

import '../story/story_image_preview_screen.dart';
import '../story/story_text_preview_screen.dart';

class StoryController extends GetxController {
  var storyList = [].obs;
  var isLoading = true.obs;
  var isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStories();
  }

  void safeSnack(String msg) {
    try {
      final ctx = Get.context;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
      } else {
        debugPrint(msg);
      }
    } catch (_) {
      debugPrint(msg);
    }
  }

  Future<void> fetchStories() async {
    try {
      if (storyList.isEmpty) isLoading(true);

      final response = await networkClient.getRequest(url: Urls.getActiveStoriesApi);

      if (response.isSuccess && response.data != null && response.data['status'] == 'success') {
        final rawList = response.data['stories'];
        if (rawList != null) {
          storyList.assignAll(rawList);
        } else {
          storyList.clear();
        }
      }
    } catch (e) {
      debugPrint("Story Fetch Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickStoryType() async {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Wrap(
            runSpacing: 10,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Photo Story"),
                onTap: () {
                  Get.back();
                  pickImageAndPreview();
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text("Text Story"),
                onTap: () {
                  Get.back();
                  Get.to(() => const StoryTextPreviewScreen());
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> pickImageAndPreview() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    Get.to(() => StoryImagePreviewScreen(image: image));
  }

  Future<void> uploadImageStory(XFile imageFile) async {
    try {
      isUploading(true);
      safeSnack("Uploading story...");

      final res = await networkClient.multipartRequest(
        url: Urls.uploadStoryApi,
        fields: {},          // token middleware থেকে user নেয়
        imageFile: imageFile,
        imageKey: 'media',   // MUST match PHP
      );

      debugPrint("UPLOAD status: ${res.statusCode}");
      debugPrint("UPLOAD data: ${res.data}");
      debugPrint("UPLOAD err: ${res.errorMessage}");

      if (res.isSuccess && res.data != null && res.data['status'] == 'success') {
        safeSnack("Story uploaded!");
        await fetchStories();
        Get.back(); // preview screen close
      } else {
        safeSnack(res.errorMessage ?? "Upload failed");
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      safeSnack("Upload Error: $e");
    } finally {
      isUploading(false);
    }
  }
}
