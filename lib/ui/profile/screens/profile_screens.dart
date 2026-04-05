import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.white, // 🔹 Clean iOS White Background

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Obx(() => Text(
          controller.profileUser.value?.username ?? "Loading...",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        )),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_square, color: Colors.black87, size: 26),
            onPressed: () => Get.to(() => const CreatePostScreen()),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.line_horizontal_3, color: Colors.black87, size: 26),
            onPressed: () {
              _showSettingsBottomSheet(context, controller);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator(radius: 16));
        }

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            physics: const BouncingScrollPhysics(), // 🔹 iOS Bounce Effect
            headerSliverBuilder: (context, _) {
              return [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(controller),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: Colors.black87,
                      indicatorWeight: 1.5,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.black87,
                      unselectedLabelColor: Colors.grey.shade400,
                      tabs: const [
                        Tab(icon: Icon(CupertinoIcons.square_grid_2x2, size: 24)),
                        Tab(icon: Icon(CupertinoIcons.person_crop_square, size: 26)),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildPostsGrid(controller),
                _buildEmptyState("Tagged Photos", "Photos and videos of you will appear here."),
              ],
            ),
          ),
        );
      }),
    );
  }

  // =====================================
  // 🎨 PROFILE HEADER WIDGET
  // =====================================
  Widget _buildProfileHeader(ProfileController controller) {
    final user = controller.profileUser.value;
    final postCount = controller.myPosts.length.toString();
    final followersCount = user?.followersCount.toString() ?? "0";
    final followingCount = user?.followingCount.toString() ?? "0";

    String profilePicUrl = (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty)
        ? user.profilePictureUrl!
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.fullName ?? "User")}&background=random";

    String bioText = (user?.bio != null && user!.bio!.trim().isNotEmpty) ? user.bio! : "";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- AVATAR & STATS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: CachedNetworkImageProvider(profilePicUrl),
                ),
              ),
              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(postCount, "Posts"),
                    _buildStatColumn(followersCount, "Followers"),
                    _buildStatColumn(followingCount, "Following"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- NAME & BIO ---
          Text(
            user?.fullName ?? "User Name",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
          ),
          if (bioText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              bioText,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, height: 1.3),
            ),
          ],
          const SizedBox(height: 16),

          // --- EDIT PROFILE BUTTON (iOS Style) ---
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => const EditProfileScreen(), transition: Transition.cupertino),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7), // 🔹 Apple System Gray 6
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Edit Profile",
                      style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {}, // Share profile action
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Share",
                    style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
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
        Text(
            count,
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)
        ),
        const SizedBox(height: 2),
        Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)
        ),
      ],
    );
  }

  // =====================================
  // 📸 POSTS GRID (Smart Image & Text Handing)
  // =====================================
  Widget _buildPostsGrid(ProfileController controller) {
    if (controller.myPosts.isEmpty) {
      return _buildEmptyState("No Posts Yet", "When you share photos or text, they will appear on your profile.");
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2), // 🔹 Minimal gap like Instagram
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.myPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = controller.myPosts[index];
        bool hasImage = post.image_url != null && post.image_url!.isNotEmpty;

        return GestureDetector(
          onTap: () => Get.to(() => PostDetailPage(post: post), transition: Transition.cupertino),
          child: Container(
            color: const Color(0xFFF2F2F7),
            child: hasImage
                ? CachedNetworkImage(
              imageUrl: post.image_url!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.grey),
            )
            // 🔹 যদি শুধু টেক্সট পোস্ট হয়, তাহলে টেক্সট এর কিছু অংশ বক্সে দেখাবে
                : Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.quote_bubble, color: Colors.grey, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      post.post_content ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================
  // 📭 EMPTY STATE
  // =====================================
  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black87, width: 2)),
              child: const Icon(CupertinoIcons.camera, size: 40, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // =====================================
  // ⚙️ SETTINGS BOTTOM SHEET
  // =====================================
  void _showSettingsBottomSheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 10, bottom: 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(CupertinoIcons.settings, color: Colors.black87),
                title: Text("Settings", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.bookmark, color: Colors.black87),
                title: Text("Saved", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 0.5),
              ListTile(
                leading: const Icon(CupertinoIcons.power, color: Colors.redAccent),
                title: Text("Log Out", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                onTap: () {
                  Get.back();
                  controller.logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// 🔹 Sticky TabBar এর জন্য Helper Class
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}