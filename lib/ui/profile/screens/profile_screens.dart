import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/create_post/screens/create_post.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';
import '../../edit_profile/screens/edit_profile_screens.dart';
import '../controllers/profile_controllers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
          controller.profileUser.value?.username ?? "Loading...",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              Get.to(() => const CreatePostScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: controller.logout,
          ),
        ],
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
                    _buildProfileHeader(controller),
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
                      _buildPostsGrid(controller),
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

  // --- ১. প্রোফাইল হেডার ---
  Widget _buildProfileHeader(ProfileController controller) {
    final user = controller.profileUser.value;
    final postCount = controller.myPosts.length.toString();

    // ✅ ফিক্সড: মডেল থেকে লেটেস্ট ফলোয়ার কাউন্ট নেওয়া হলো
    final followersCount = user?.followersCount.toString() ?? "0";
    final followingCount = user?.followingCount.toString() ?? "0";

    String profilePicUrl = (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
        ? user.profilePictureUrl!
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.fullName ?? "User")}&background=random";

    String bioText = (user?.bio != null && user!.bio!.trim().isNotEmpty)
        ? user.bio!
        : "No bio available";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(43),
                child: CachedNetworkImage(
                  imageUrl: profilePicUrl,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(postCount, "Posts"),
                    // ✅ ফিক্সড: হার্ডকোডেড ০ সরিয়ে অরিজিনাল ডাটা বসানো হলো
                    _buildStatColumn(followersCount, "Followers"),
                    _buildStatColumn(followingCount, "Following"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            user?.fullName ?? "Name",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),

          Text(
            bioText,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(() => const EditProfileScreen(), transition: Transition.rightToLeft);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  Widget _buildPostsGrid(ProfileController controller) {
    if (controller.myPosts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No posts yet"),
      ));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      itemCount: controller.myPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = controller.myPosts[index];

        return GestureDetector(
          onTap: () {
            Get.to(() => PostDetailPage(post: post));
          },
          child: Container(
            color: Colors.grey[200],
            child: post.image_url != null
                ? CachedNetworkImage(
              imageUrl: post.image_url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
            )
                : const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
        );
      },
    );
  }
}