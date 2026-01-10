import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';

class SearchUserController extends GetxController {
  var searchResults = <dynamic>[].obs;
  var isLoading = false.obs;
  var searchText = ''.obs;

  final TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    debounce(
      searchText,
          (query) => _performSearch(query.toString()),
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();

    // ✅ minimum 2 char (backend এও আছে)
    if (q.isEmpty || q.length < 2) {
      searchResults.clear();
      return;
    }

    try {
      isLoading(true);

      // ✅ Backend param name: q + limit
      final String url =
          "${Urls.searchUsersApi}?q=${Uri.encodeComponent(q)}&limit=20";

      final networkResponse response =
      await networkClient.getRequest(url: url);

      if (response.isSuccess == true) {
        final data = response.data;

        if (data != null && data['status'] == 'success') {
          searchResults.value = (data['users'] ?? []) as List<dynamic>;
        } else {
          searchResults.clear();
        }
      } else {
        searchResults.clear();
      }
    } catch (e) {
      searchResults.clear();
      debugPrint("❌ Search Error: $e");
    } finally {
      isLoading(false);
    }
  }

  void clearSearch() {
    searchInputController.clear();
    searchText.value = '';
    searchResults.clear();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }
}
