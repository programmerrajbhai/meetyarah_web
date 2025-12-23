import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';

import '../controllers/view_profile_controllers.dart';

class ViewProfileScreen extends StatefulWidget {
  final int userId; // যাকে দেখব তার আইডি
  const ViewProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  // ইউনিক ট্যাগ ব্যবহার করছি যাতে ভিন্ন ভিন্ন ইউজার প্রোফাইল লোড করা যায়
  late final ViewProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ViewProfileController(), tag: widget.userId.toString());
    controller.loadUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          var username = controller.userProfile['username'] ?? "Profile";
          return Text(username, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold));
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileHeader(),
                  ]),
                ),
              ];
            },
            body: Column(
              children: [
                const TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.person_pin_outlined)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPostsGrid(),
                      const Center(child: Text("Tagged Photos (Coming Soon)")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- হেডার সেকশন ---
  Widget _buildProfileHeader() {
    var profile = controller.userProfile;
    String fullName = profile['full_name'] ?? "Unknown";
    String bio = profile['bio'] ?? "";
    String profilePic = profile['profile_picture_url'] ?? "";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // প্রোফাইল ছবি
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                child: profilePic.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
              ),
              const SizedBox(width: 20),

              // Stats Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(controller.userPosts.length.toString(), "Posts"),
                    _buildStatItem(controller.followersCount.value.toString(), "Followers"),
                    _buildStatItem(controller.followingCount.value.toString(), "Following"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // নাম ও বায়ো
          Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(bio, style: const TextStyle(fontSize: 14)),
          ],
          const SizedBox(height: 16),

          // --- Follow / Edit Button ---
          if (controller.isOwnProfile.value)
          // নিজের প্রোফাইল হলে Edit বাটন (Optional)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
              ),
            )
          else
          // অন্যের প্রোফাইল হলে Follow/Unfollow বাটন
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.toggleFollow(widget.userId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isFollowing.value ? Colors.grey[300] : Colors.blue,
                  elevation: 0,
                ),
                child: Text(
                  controller.isFollowing.value ? "Unfollow" : "Follow",
                  style: TextStyle(
                    color: controller.isFollowing.value ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // --- পোস্ট গ্রিড ---
  Widget _buildPostsGrid() {
    if (controller.userPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No posts yet"),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      itemCount: controller.userPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        var post = controller.userPosts[index];
        return GestureDetector(
          onTap: () {
            Get.to(() => PostDetailPage(post: post));
          },
          child: Container(
            color: Colors.grey[200],
            child: post.image_url != null
                ? Image.network(post.image_url!, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported),
          ),
        );
      },
    );
  }
}