import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/spoken_video_model.dart';
// import '../models/spoken_video_model.dart';

class SpokenEnglishController extends GetxController {
  var isLoading = true.obs;

  // Wallet & Progress System
  var myCoins = 250.obs; // ইউজারের বর্তমান কয়েন
  var courseProgress = 0.8.obs; // 80% Course Completed
  var isCertificateUnlocked = false.obs; // 100% হলে True হবে

  var allVideos = <SpokenVideoModel>[].obs;
  var filteredVideos = <SpokenVideoModel>[].obs;
  var selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
    // Check if certificate should be unlocked
    if (courseProgress.value == 1.0) isCertificateUnlocked.value = true;
  }

  void fetchVideos() async {
    isLoading(true);
    await Future.delayed(const Duration(seconds: 1)); // Fake API Delay

    allVideos.value = [
      SpokenVideoModel(
        id: "1", title: "Alphabet & Basic Pronunciation",
        description: "Learn how to pronounce English alphabets correctly.",
        thumbnailUrl: "https://images.unsplash.com/photo-1546410531-ee4cb1270cb2?q=80&w=600&auto=format&fit=crop",
        duration: "10:05", level: "Beginner", isLocked: false, progress: 1.0,
      ),
      SpokenVideoModel(
        id: "2", title: "How to Introduce Yourself",
        description: "Master the art of introducing yourself in an interview or casually.",
        thumbnailUrl: "https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?q=80&w=600&auto=format&fit=crop",
        duration: "15:20", level: "Beginner", isLocked: false, progress: 0.8,
      ),
      SpokenVideoModel(
        id: "3", title: "Daily Conversation Sentences",
        description: "50+ useful sentences for day-to-day English speaking.",
        thumbnailUrl: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=600&auto=format&fit=crop",
        duration: "22:15", level: "Intermediate", isLocked: true, progress: 0.0,
      ),
      SpokenVideoModel(
        id: "4", title: "Fluency Tricks & Tips",
        description: "Speak English smoothly without hesitation.",
        thumbnailUrl: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?q=80&w=600&auto=format&fit=crop",
        duration: "18:40", level: "Advanced", isLocked: true, progress: 0.0,
      ),
    ];

    filteredVideos.value = allVideos;
    isLoading(false);
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    if (category == 'All') {
      filteredVideos.value = allVideos;
    } else {
      filteredVideos.value = allVideos.where((video) => video.level == category).toList();
    }
  }

  void playVideo(SpokenVideoModel video) {
    if (video.isLocked) {
      // Coin Logic for Locked Videos
      Get.defaultDialog(
          title: "Premium Content",
          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          backgroundColor: const Color(0xFF1A1A1A),
          radius: 12,
          content: Column(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFFFF6B00), size: 40),
              const SizedBox(height: 10),
              const Text(
                "Unlock this video using 50 coins?",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                    onPressed: () {
                      if (myCoins.value >= 50) {
                        myCoins.value -= 50;
                        Get.back();
                        Get.snackbar("Success", "Video Unlocked! ▶️", backgroundColor: Colors.green, colorText: Colors.white);
                        // Logic to unlock video locally
                      } else {
                        Get.back();
                        Get.snackbar("Error", "Not enough coins!", backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    },
                    child: const Text("Unlock (50)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          )
      );
    } else {
      Get.snackbar("Playing", "Starting: ${video.title}", backgroundColor: const Color(0xFF2E2E2E), colorText: Colors.white);
    }
  }

  void claimCertificate() {
    if (courseProgress.value >= 1.0) {
      Get.snackbar("Congratulations! 🎉", "Your certificate is generating...", backgroundColor: const Color(0xFFFF6B00), colorText: Colors.white);
    } else {
      Get.snackbar("Keep Going!", "Complete 100% of the course to unlock your certificate.", backgroundColor: const Color(0xFF2E2E2E), colorText: Colors.white);
    }
  }
}