import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_profile/screens/view_profile_screens.dart';
import '../controller/search_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SearchUserController controller = Get.put(SearchUserController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: controller.searchInputController,
          autofocus: true,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: const InputDecoration(
            hintText: "Search users...",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) => controller.searchText.value = value,
        ),
        actions: [
          Obx(() => controller.searchText.value.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: controller.clearSearch,
          )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchResults.isEmpty &&
            controller.searchText.value.trim().isNotEmpty &&
            controller.searchText.value.trim().length >= 2) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  "User not found!",
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return Center(
            child: Text(
              "Type at least 2 letters to search",
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final user = controller.searchResults[index] as Map<String, dynamic>;

            final int userId = int.tryParse(user['user_id'].toString()) ?? 0;
            final String fullName = (user['full_name'] ?? "Unknown").toString();
            final String username = (user['username'] ?? "").toString();
            final String profilePic =
            (user['profile_picture_url'] ?? "").toString();

            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                child: profilePic.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              title: Text(
                fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("@$username"),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
              onTap: () {
                Get.to(() => ViewProfileScreen(userId: userId));
              },
            );
          },
        );
      }),
    );
  }
}
