import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/ui/view_post/screens/post_details.dart';
import '../controllers/view_profile_controllers.dart';

class ViewProfileScreen extends StatefulWidget {
  final int userId;
  const ViewProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late final ViewProfileController controller;

  @override
  void initState() {
    super.initState();
    // ইউনিক ট্যাগ দিয়ে কন্ট্রোলার ইনিশিয়ালাইজ করছি
    controller = Get.put(ViewProfileController(), tag: widget.userId.toString());
    controller.loadUserProfile(widget.userId);
  }

  // 🔥 Facebook Style Bottom Sheet Menu
  void _showProfileOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (controller.isFollowing.value)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                  child: const Icon(Icons.person_remove, color: Colors.red),
                ),
                title: const Text("Unfollow", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text("Stop seeing posts from this user"),
                onTap: () {
                  Get.back(); // Close sheet
                  controller.toggleFollow(widget.userId);
                },
              )
            else
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                  child: const Icon(Icons.person_add, color: Colors.blue),
                ),
                title: const Text("Follow", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                onTap: () {
                  Get.back();
                  controller.toggleFollow(widget.userId);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text("Block"),
              onTap: () {
                Get.back();
                Get.snackbar("Block", "Block feature coming soon");
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text("Report Profile"),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
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

        // 🔥 Refresh Indicator Added
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadUserProfile(widget.userId, isRefresh: true);
          },
          color: Colors.black,
          backgroundColor: Colors.white,
          child: DefaultTabController(
            length: 2,
            child: NestedScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // রিফ্রেশ কাজ করার জন্য জরুরি
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
          ),
        );
      }),
    );
  }

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
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: (profilePic.isNotEmpty) ? NetworkImage(profilePic) : null,
                onBackgroundImageError: (profilePic.isNotEmpty) ? (_, __) {} : null,
                child: (profilePic.isEmpty) ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
              ),
              const SizedBox(width: 20),
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
          Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(bio, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
          const SizedBox(height: 16),

          // 🔥 Action Buttons Row (Like Facebook)
          Row(
            children: [
              // 1. Main Action Button (Follow/Friends/Edit)
              Expanded(
                child: controller.isOwnProfile.value
                    ? _buildActionButton(
                  text: "Edit Profile",
                  icon: Icons.edit,
                  color: Colors.grey[200]!,
                  textColor: Colors.black,
                  onTap: () {}, // Open Edit Screen logic here
                )
                    : Obx(() {
                  // Determine State
                  bool isFollowing = controller.isFollowing.value;
                  bool isFriends = isFollowing && controller.isTargetFollowingMe.value;

                  String text = isFriends ? "Friends" : (isFollowing ? "Following" : "Follow");
                  Color bgColor = isFollowing ? Colors.grey[200]! : Colors.blue;
                  Color txtColor = isFollowing ? Colors.black : Colors.white;
                  IconData icon = isFriends ? Icons.people : (isFollowing ? Icons.check : Icons.person_add);

                  return _buildActionButton(
                    text: text,
                    icon: icon,
                    color: bgColor,
                    textColor: txtColor,
                    isLoading: controller.isFollowLoading.value,
                    onTap: () => controller.toggleFollow(widget.userId),
                  );
                }),
              ),

              const SizedBox(width: 8),

              // 2. Message Button
              if (!controller.isOwnProfile.value)
                Expanded(
                  child: _buildActionButton(
                    text: "Message",
                    icon: Icons.chat_bubble_outline,
                    color: Colors.grey[200]!,
                    textColor: Colors.black,
                    onTap: () {},
                  ),
                ),

              if (!controller.isOwnProfile.value) const SizedBox(width: 8),

              // 3. Three Dot Menu Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: _showProfileOptions, // 🔥 Open Menu
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Button Widget
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: textColor))
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 18),
              const SizedBox(width: 6),
              Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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

  Widget _buildPostsGrid() {
    if (controller.userPosts.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No posts yet")));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(), // NestedScrollView handles scroll
      shrinkWrap: true,
      itemCount: controller.userPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 2, crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        var post = controller.userPosts[index];
        return GestureDetector(
          onTap: () => Get.to(() => PostDetailPage(post: post)),
          child: Container(
            color: Colors.grey[200],
            child: (post.image_url != null && post.image_url!.isNotEmpty)
                ? Image.network(post.image_url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                : const Icon(Icons.image_not_supported),
          ),
        );
      },
    );
  }
}