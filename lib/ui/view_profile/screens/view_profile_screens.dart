import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:meetyarah/ui/view_post/screens/post_details.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import '../../home/widgets/post_card_widget.dart'; // 🔹 News Feed e post dekhabar jonno
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
    controller =
        Get.put(ViewProfileController(), tag: widget.userId.toString());
    controller.loadUserProfile(widget.userId);
  }

  // 🔥 Minimal 3-Dot Menu
  void _showProfileOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(bottom: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (controller.isFollowing.value)
              _buildBottomSheetTile(
                icon: CupertinoIcons.person_badge_minus,
                title: "Unfollow",
                color: Colors.redAccent,
                onTap: () {
                  Get.back();
                  controller.toggleFollow(widget.userId);
                },
              ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, thickness: 0.5)),
            _buildBottomSheetTile(
              icon: CupertinoIcons.nosign,
              title: "Block User",
              color: Colors.black87,
              onTap: () {
                Get.back();
                Get.snackbar("Notice", "Block feature coming soon",
                    backgroundColor: Colors.black87, colorText: Colors.white);
              },
            ),
            _buildBottomSheetTile(
              icon: CupertinoIcons.exclamationmark_triangle,
              title: "Report Profile",
              color: Colors.red,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBottomSheetTile(
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: color, size: 24),
      title: Text(title,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 16, color: color)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          var username = controller.userProfile['username'] ?? "Profile";
          return Text(
            username,
            style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.5),
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis, color: Colors.black87),
            onPressed: _showProfileOptions,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator(radius: 16));
        }

        return RefreshIndicator(
          onRefresh: () async =>
              await controller.loadUserProfile(widget.userId, isRefresh: true),
          color: Colors.black87,
          backgroundColor: Colors.white,
          child: DefaultTabController(
            length: 2, // 🔹 2 Tabs: Gallery & Feed
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, _) {
                return [
                  SliverToBoxAdapter(child: _buildProfileHeader()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        indicatorColor: Colors.black87,
                        indicatorWeight: 2,
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey.shade400,
                        tabs: const [
                          Tab(
                              icon: Icon(CupertinoIcons.square_grid_2x2,
                                  size: 24)), // Gallery
                          Tab(
                              icon: Icon(CupertinoIcons.list_bullet,
                                  size: 24)), // News Feed
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildGalleryGrid(), // Tab 1: Gallery Style
                  _buildNewsFeedList(), // Tab 2: News Feed Style
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // =====================================
  // 🎨 PROFILE HEADER WIDGET
  // =====================================
  Widget _buildProfileHeader() {
    var profile = controller.userProfile;
    String fullName = profile['full_name'] ?? "Unknown User";
    String bio = profile['bio'] ?? "";
    String profilePic = profile['profile_picture_url'] ??
        "https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=random";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- AVATAR & STATS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.grey.shade200, width: 1.5)),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: CachedNetworkImageProvider(profilePic),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                        controller.userPosts.length.toString(), "Posts"),
                    _buildStatItem(controller.followersCount.value.toString(),
                        "Followers"),
                    _buildStatItem(controller.followingCount.value.toString(),
                        "Following"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- NAME & BIO ---
          Text(fullName,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87)),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(bio,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.black87, height: 1.3)),
          ],
          const SizedBox(height: 20),

          // --- 🔹 ACTION BUTTONS (Message Button Removed) ---
          Row(
            children: [
              Expanded(
                child: controller.isOwnProfile.value
                    ? _buildModernButton(
                        text: "Edit Profile",
                        bgColor: Colors.grey.shade100,
                        textColor: Colors.black87,
                        onTap: () {}, // 🔹 Navigate to edit
                      )
                    : Obx(() {
                        bool isFollowing = controller.isFollowing.value;
                        bool isFriends =
                            isFollowing && controller.isTargetFollowingMe.value;

                        String text = isFriends
                            ? "Friends"
                            : (isFollowing ? "Following" : "Follow");
                        Color bgColor = isFollowing
                            ? Colors.grey.shade100
                            : Colors.blueAccent;
                        Color txtColor =
                            isFollowing ? Colors.black87 : Colors.white;

                        return _buildModernButton(
                          text: text,
                          bgColor: bgColor,
                          textColor: txtColor,
                          isLoading: controller.isFollowLoading.value,
                          onTap: () => controller.toggleFollow(widget.userId),
                        );
                      }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(
      {required String text,
      required Color bgColor,
      required Color textColor,
      required VoidCallback onTap,
      bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: textColor))
            : Text(text,
                style: GoogleFonts.inter(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // =====================================
  // 📸 TAB 1: GALLERY GRID WIDGET
  // =====================================
  Widget _buildGalleryGrid() {
    if (controller.userPosts.isEmpty) {
      return _buildEmptyState(
          "No Posts Yet", "When this user posts, they will show up here.");
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2), // 🔹 Minimal gap
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.userPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        var post = controller.userPosts[index];
        return GestureDetector(
          onTap: () => Get.to(() => PostDetailPage(post: post),
              transition: Transition.cupertino),
          child: _buildGridItem(post),
        );
      },
    );
  }

  // 🔹 Text hole Text, Video hole Video, Image hole Image
  Widget _buildGridItem(GetPostModel post) {
    String mediaUrl = post.directUrl ?? post.image_url ?? "";
    bool isVideo =
        mediaUrl.toLowerCase().endsWith('.mp4') || post.isDirectLink == true;
    bool hasMedia = mediaUrl.isNotEmpty;

    if (isVideo) {
      // 🎥 VIDEO POST
      return Container(
        color: Colors.black87,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (post.image_url != null) // If there's a thumbnail
              CachedNetworkImage(
                  imageUrl: post.image_url!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity)
            else
              const Icon(CupertinoIcons.play_circle_fill,
                  color: Colors.white70, size: 36),
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(CupertinoIcons.video_camera_solid,
                  color: Colors.white, size: 18),
            )
          ],
        ),
      );
    } else if (hasMedia) {
      // 🖼️ IMAGE POST
      return CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey.shade200),
        errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: const Icon(CupertinoIcons.exclamationmark_triangle,
                color: Colors.grey)),
      );
    } else {
      // 📝 TEXT POST
      return Container(
        color: const Color(0xFFF2F2F7), // Soft grey background
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                post.post_content ?? "",
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    height: 1.4),
              ),
            ],
          ),
        ),
      );
    }
  }

  // =====================================
  // 📰 TAB 2: NEWS FEED WIDGET
  // =====================================
  Widget _buildNewsFeedList() {
    if (controller.userPosts.isEmpty) {
      return _buildEmptyState("No Posts Yet", "Timeline is empty.");
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.userPosts.length,
      itemBuilder: (context, index) {
        var post = controller.userPosts[index];
        // 🔹 Apnar kora PostCardWidget ti call kora holo Feed dekhanor jonno
        return PostCardWidget(post: post, index: index);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2)),
              child: Icon(CupertinoIcons.camera,
                  size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// 🔹 Sticky TabBar Helper
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: _tabBar);

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
