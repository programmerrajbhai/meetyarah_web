import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';

class SearchUserController extends GetxController {
  var searchResults = [].obs; // রেজাল্ট লিস্ট
  var isLoading = false.obs;  // লোডিং স্ট্যাটাস
  var searchText = ''.obs;    // যা টাইপ করা হচ্ছে

  TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // 🔥 Magic Part: ইউজার থামা পর্যন্ত অপেক্ষা করবে (500ms), তারপর সার্চ করবে
    debounce(searchText, (query) {
      _performSearch(query.toString());
    }, time: const Duration(milliseconds: 500));
  }

  // মেইন সার্চ ফাংশন
  void _performSearch(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading(true);
      print("🔎 Searching for: $query");

      String url = "${Urls.searchUsersApi}?query=$query";
      networkResponse response = await networkClient.getRequest(url: url);

      if (response.isSuccess) {
        if (response.data['status'] == 'success') {
          searchResults.value = response.data['users'] ?? [];
        } else {
          searchResults.clear();
        }
      }
    } catch (e) {
      print("❌ Search Error: $e");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }
}