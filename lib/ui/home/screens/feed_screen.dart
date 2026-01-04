import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ ক্লিন ইমপোর্টস (Adsterra এবং AdBlock রিমুভ করা হয়েছে)
import '../../reels/screens/reel_screens.dart'; // Contains FacebookVideoCard & VideoDataHelper

import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../view_post/screens/post_details.dart';
import '../../create_post/screens/create_post.dart';
import '../widgets/like_button.dart';
import '../widgets/simple_video_player.dart';
import '../widgets/story_list_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = Get.put(GetPostController());
  final likeController = Get.put(LikeController());

  // ✅ ভিডিও লিস্ট রাখার জন্য ভেরিয়েবল
  List<VideoDataModel> _feedVideos = [];

  // ✅ পিন করা ভিডিও (যেটা ভিডিও লিংকের মাধ্যমে এসেছে)
  VideoDataModel? _pinnedVideo;

  // ✅ পিন করা পোস্ট (যেটা পোস্ট লিংকের মাধ্যমে এসেছে)
  dynamic _pinnedPost;

  @override
  void initState() {
    super.initState();
    // ✅ _checkAdBlocker রিমুভ করা হয়েছে

    // ✅ প্রথমে সব ডেটা লোড করা হবে, তারপর লিংক চেক করা হবে
    _initializeFeedData();
  }

  Future<void> _initializeFeedData() async {
    // ১. আগে পোস্টগুলো সার্ভার থেকে আনবো
    await postController.getAllPost();

    // ২. তারপর চেক করবো লিংকে কোনো পোস্ট আইডি আছে কিনা
    _checkDeepLinkForPosts();

    // ৩. সবশেষে ভিডিও লোড করবো এবং ভিডিও লিংক চেক করবো
    _loadFeedVideos();
  }

  // ✅ POST Deep Link Logic (?id=...)
  void _checkDeepLinkForPosts() {
    if (kIsWeb) {
      try {
        String? targetId = Uri.base.queryParameters['id'];
        if (targetId != null && targetId.isNotEmpty) {
          debugPrint("🔗 Post Deep Link Found: $targetId");

          // পোস্ট লিস্ট থেকে ওই পোস্টটি খোঁজা হচ্ছে
          int index = postController.posts
              .indexWhere((p) => p.post_id.toString() == targetId);

          if (index != -1) {
            var post = postController.posts.removeAt(index);
            setState(() {
              _pinnedPost = post;
              // পোস্টটি লিস্টের শুরুতেও দিয়ে রাখলাম যাতে রিফ্রেশ করলে হার না যায়
              postController.posts.insert(0, post);
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar("Shared Post", "Showing shared post at the top.",
                  backgroundColor: Colors.blueAccent,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP);
            });
          }
        }
      } catch (e) {
        debugPrint("Error parsing Post ID: $e");
      }
    }
  }

  // ✅ VIDEO Deep Link Logic (?post_id=...)
  void _loadFeedVideos() {
    var videos = VideoDataHelper.generateAllVideos();

    if (kIsWeb) {
      try {
        String? targetPostId = Uri.base.queryParameters['post_id'];

        if (targetPostId != null && targetPostId.isNotEmpty) {
          debugPrint("🔗 Video Deep Link Found: $targetPostId");
          int targetIndex =
          videos.indexWhere((video) => video.url.contains(targetPostId));

          if (targetIndex != -1) {
            var foundVideo = videos.removeAt(targetIndex);
            setState(() {
              _pinnedVideo = foundVideo;
              videos.insert(0, foundVideo);
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar("Shared Video", "Showing video at the top.",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP);
            });
          }
        }
      } catch (e) {
        debugPrint("Error parsing Video ID: $e");
      }
    }

    if (mounted) {
      setState(() {
        _feedVideos = videos;
      });
    }
  }

  // ✅ ক্লিক হ্যান্ডলার ক্লিন করা হয়েছে (অ্যাড লজিক রিমুভড)
  Future<void> _handlePostClick(dynamic post) async {
    // সরাসরি পোস্ট ডিটেইলসে যাবে
    Get.to(() => PostDetailPage(post: post));
  }

  void _handleAction({required String message, VoidCallback? action}) {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    if (action != null) action();
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 20,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
    );
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Just now";
    try {
      DateTime date;
      if (!dateString.endsWith("Z")) {
        date = DateTime.parse("${dateString}Z").toLocal();
      } else {
        date = DateTime.parse(dateString).toLocal();
      }
      Duration diff = DateTime.now().difference(date);
      if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y ago";
      if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
      if (diff.inDays > 0) return "${diff.inDays}d ago";
      if (diff.inHours > 0) return "${diff.inHours}h ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
      return "Just now";
    } catch (e) {
      return "Just now";
    }
  }

  String _getUserName(dynamic post) {
    if (post.full_name != null && post.full_name!.isNotEmpty)
      return post.full_name!;
    if (post.username != null && post.username!.isNotEmpty)
      return post.username!;
    return "Unknown User";
  }

  // ✅ Regular Post Link Generator (Uses ?id=)
  String _getPostLink(String postId) {
    if (kIsWeb) {
      return "${Uri.base.origin}/?id=$postId";
    }
    return "https://meetyarah.com/?id=$postId";
  }

  void _copyPostLink(String postId) {
    Clipboard.setData(ClipboardData(text: _getPostLink(postId)));
  }

  // ✅ Share Options for Regular Posts
  void _showShareOptions(BuildContext context, dynamic post) {
    String shareUrl = _getPostLink(post.post_id.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text("Share this post",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Link Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(shareUrl,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOptionItem(Icons.copy, "Copy Link", Colors.blue, () {
                  _handleAction(
                      message: "Link copied to clipboard! 📋",
                      action: () => _copyPostLink(post.post_id.toString()));
                }),
                _shareOptionItem(Icons.share, "More Options", Colors.green, () {
                  _handleAction(
                      message: "Opening share options...",
                      action: () =>
                          Share.share("Check out this post: $shareUrl"));
                }),
                _shareOptionItem(
                    Icons.send_rounded, "Send in App", Colors.purple, () {
                  _handleAction(message: "Sent to friend successfully! 🚀");
                }),
                _shareOptionItem(
                    Icons.add_to_photos_rounded, "Share to Feed", Colors.orange,
                        () {
                      _handleAction(message: "Shared to your timeline! ✍️");
                    }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return _FeedbackButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            _buildOptionTile(
                Icons.bookmark_border,
                "Save Post",
                "Add this to your saved items.",
                    () => _handleAction(message: "Post saved to collection! 💾")),
            _buildOptionTile(
                Icons.visibility_off_outlined,
                "Hide Post",
                "See fewer posts like this.",
                    () => _handleAction(message: "Post hidden from feed. 🙈")),
            const Divider(),
            _buildOptionTile(
                Icons.copy,
                "Copy Link",
                "Copy post url to clipboard.",
                    () => _handleAction(
                    message: "Link copied! 🔗",
                    action: () => _copyPostLink(post.post_id.toString()))),
            _buildOptionTile(
                Icons.report_gmailerrorred,
                "Report Post",
                "I'm concerned about this post.",
                    () => _handleAction(message: "Report submitted. Thanks! 🛡️"),
                isDestructive: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration:
        BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon,
            color: isDestructive ? Colors.red : Colors.black87, size: 22),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDestructive ? Colors.red : Colors.black87)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]))
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 900;
            double feedWidth = isWideScreen ? 600 : constraints.maxWidth;

            return RefreshIndicator(
              onRefresh: () async {
                await _initializeFeedData(); // Refresh both posts and videos
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: feedWidth,
                    child: Obx(() {
                      if (postController.isLoading.value)
                        return _buildShimmer();

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 50),
                        children: [
                          _buildCreatePostBox(),


                          const StoryListWidget(), // ✅ এখানে স্টোরি বার বসানো হলো

                          // ✅ PINNED VIDEO SECTION (If URL is ?post_id=...)
                          if (_pinnedVideo != null) ...[
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    child: const Text("Shared Video",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                  const SizedBox(height: 8),
                                  FacebookVideoCard(
                                    key:
                                    ValueKey("pinned_${_pinnedVideo!.url}"),
                                    videoData: _pinnedVideo!,
                                    allVideosList:
                                    _feedVideos.map((e) => e.url).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ✅ PINNED POST SECTION (If URL is ?id=...)
                          if (_pinnedPost != null) ...[
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    child: const Text("Shared Post",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildFacebookPostCard(
                                      _pinnedPost, 0), // Index 0 as it's pinned
                                ],
                              ),
                            ),
                          ],

                          if (postController.posts.isEmpty) _buildEmptyState(),

                          // ✅ POST LIST Builder
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postController.posts.length,
                            itemBuilder: (context, index) {
                              final post = postController.posts[index];

                              // ✅ VIDEO INJECTION LOGIC
                              Widget videoWidget = const SizedBox.shrink();
                              if (_feedVideos.isNotEmpty &&
                                  (index + 1) % 10 == 0) {
                                int videoIndex =
                                    ((index + 1) ~/ 10) % _feedVideos.length;
                                videoWidget = Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                                  child: FacebookVideoCard(
                                    key: ValueKey(
                                        "feed_video_${_feedVideos[videoIndex].url}"),
                                    videoData: _feedVideos[videoIndex],
                                    allVideosList:
                                    _feedVideos.map((e) => e.url).toList(),
                                  ),
                                );
                              }

                              // Don't show pinned post again in the list (Optional check, but simple insert at 0 is safer)
                              return Column(
                                children: [
                                  _buildFacebookPostCard(post, index),
                                  // ✅ বিজ্ঞাপন রিমুভ করা হয়েছে
                                  videoWidget,
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                  if (isWideScreen)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // ✅ Sponsored এবং অ্যাড সেকশন রিমুভ করা হয়েছে
                            _buildFriendSuggestions(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widgets ---
  Widget _buildCreatePostBox() {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      elevation: 0.5,
      color: Colors.white,
      shape: kIsWeb
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(
                radius: 20,
                backgroundImage:
                NetworkImage("https://i.pravatar.cc/150?img=12")),
            const SizedBox(width: 10),
            Expanded(
              child: _FeedbackButton(
                onTap: () => Get.to(() => const CreatePostScreen()),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(25)),
                  child: const Text("What's on your mind?",
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
                icon: const Icon(Icons.photo_library, color: Colors.green),
                onPressed: () => Get.to(() => const CreatePostScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: kIsWeb ? Colors.transparent : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FeedbackButton(
              onTap: () {},
              child: Container(
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: NetworkImage(
                          "https://picsum.photos/200/300?random=$index"),
                      fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ]))),
                    Positioned(
                        bottom: 8,
                        left: 8,
                        child: Text(index == 0 ? "Add Story" : "User $index",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


// ২. হেল্পার ফাংশন (ক্লাসের ভেতরে বা বাইরে রাখতে পারেন)
  bool isVideo(String url) {
    String ext = url.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  Widget _buildFacebookPostCard(dynamic post, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0.5,
      shape: kIsWeb
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Section ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundImage: NetworkImage(post.profile_picture_url ??
                        "https://via.placeholder.com/150")),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getUserName(post),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatTimeAgo(post.created_at),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () => _showPostOptions(context, post)),
              ],
            ),
          ),

          // --- Content Section ---
          InkWell(
            onTap: () => _handlePostClick(post),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.post_content != null && post.post_content!.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Text(post.post_content!,
                          style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: Colors.black87))),
                const SizedBox(height: 8),

                // ✅ PROFESSIONAL VIDEO PLAYER INTEGRATION
                if (post.image_url != null && post.image_url!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 400, // ফিক্সড হাইট (ভিডিও এবং ইমেজের জন্য)
                    decoration: const BoxDecoration(color: Colors.black),
                    child: isVideo(post.image_url!)
                        ? ClipRRect(
                      child: SimpleVideoPlayer(videoUrl: post.image_url!),
                    )
                        : Hero(
                      tag: "post_image_${post.post_id}_$index",
                      child: CachedNetworkImage(
                        imageUrl: post.image_url!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 50),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // --- Footer Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _buildReactionIcon(Icons.thumb_up, Colors.blue),
                  if ((post.like_count ?? 0) > 0) ...[
                    const SizedBox(width: 6),
                    Text("${post.like_count}",
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 13))
                  ]
                ]),
                InkWell(
                    onTap: () => _handlePostClick(post),
                    child: Text("${post.comment_count ?? 0} Comments",
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),

          // --- Action Buttons ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildReactionButton(post, index)),
                Expanded(
                    child: _actionButton(
                        icon: Icons.chat_bubble_outline,
                        label: "Comment",
                        onTap: () => _handlePostClick(post))),
                Expanded(
                    child: _actionButton(
                        icon: Icons.share_outlined,
                        label: "Share",
                        onTap: () => _showShareOptions(context, post))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(dynamic post, int index) {
    return LikeButton(
        isLiked: post.isLiked,
        onTap: () {
          likeController.toggleLike(index);
        });
  }

  Widget _actionButton(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return _FeedbackButton(
        onTap: onTap, child: _actionButtonContent(icon, label));
  }

  Widget _actionButtonContent(IconData icon, String label,
      {Color color = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon,
            color: color == Colors.grey ? Colors.grey[600] : color, size: 20),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color == Colors.grey ? Colors.grey[600] : color,
                fontWeight: FontWeight.w600,
                fontSize: 14))
      ]),
    );
  }

  Widget _buildEmptyState() => const Padding(
      padding: EdgeInsets.all(40),
      child: Center(child: Text("No posts found.")));

  Widget _buildFriendSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("People You May Know",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
            shrinkWrap: true,
            itemCount: 2,
            itemBuilder: (c, i) => const ListTile(
                title: Text("User Name"), leading: CircleAvatar())),
      ],
    );
  }

  Widget _buildReactionIcon(IconData icon, Color color) {
    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 10, color: Colors.white));
  }

  Widget _buildShimmer() {
    return ListView.builder(
        itemCount: 3,
        itemBuilder: (c, i) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
                height: 250,
                color: Colors.white,
                margin: const EdgeInsets.all(10))));
  }
}

class _FeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _FeedbackButton({required this.child, required this.onTap});
  @override
  State<_FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<_FeedbackButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed
            ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
            color: _isPressed ? Colors.grey.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: widget.child,
      ),
    );
  }
}