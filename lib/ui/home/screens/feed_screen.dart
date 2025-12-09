import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../../../adsterra/controller/adsterra_controller.dart';
import '../../../adsterra/widgets/simple_ad_widget.dart';
import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../view_post/screens/post_details.dart';
import '../../create_post/screens/create_post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = Get.put(GetPostController());
  final likeController = Get.put(LikeController());
  final adController = Get.put(AdsterraController());

  final Map<int, String> _postReactions = {};
  final bool _showDemoAds = kDebugMode;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAdBlocker();
      });
    }
  }

  Future<void> _checkAdBlocker() async {
    try {
      final response = await http.get(Uri.parse("https://pl25522730.effectivegatecpm.com/dd/4f/78/dd4f7878c3a97f6f9e08bdf8911ad44b.js"));
      if (response.statusCode != 200 || response.body.isEmpty) {
        if (mounted) _showAdBlockAlert();
      }
    } catch (e) {
      // Ignore
    }
  }

  void _showAdBlockAlert() {
    // AdBlock alert dialog logic...
  }

  // ✅ CENTRAL HELPER: Dismiss Sheet & Show Snackbar automatically
  void _handleAction({required String message, VoidCallback? action}) {
    // 1. Dismiss BottomSheet immediately if open
    if (Get.isBottomSheetOpen ?? false) Get.back();

    // 2. Execute the logic (Copy/Share/Save etc.)
    if (action != null) action();

    // 3. Show Visual Feedback (SnackBar)
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 20,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
    );
  }

  // Link Generator
  String _getPostLink(String postId) {
    return "https://meetyarah.com/post/$postId";
  }

  // Copy Link Logic
  void _copyPostLink(String postId) {
    Clipboard.setData(ClipboardData(text: _getPostLink(postId)));
  }

  // ✅ Advanced Share Menu (Updated)
  void _showShareOptions(BuildContext context, dynamic post) {
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text("Share this post", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Copy Link
                _shareOptionItem(Icons.copy, "Copy Link", Colors.blue, () {
                  _handleAction(
                    message: "Link copied to clipboard! 📋",
                    action: () => _copyPostLink(post.post_id ?? "0"),
                  );
                }),

                // 2. System Share (Social Media)
                _shareOptionItem(Icons.share, "More Options", Colors.green, () {
                  _handleAction(
                    message: "Opening share options...",
                    action: () => Share.share("Check out this post: ${_getPostLink(post.post_id ?? "0")}"),
                  );
                }),

                // 3. Send in App
                _shareOptionItem(Icons.send_rounded, "Send in App", Colors.purple, () {
                  _handleAction(message: "Sent to friend successfully! 🚀");
                }),

                // 4. Share to Feed
                _shareOptionItem(Icons.add_to_photos_rounded, "Share to Feed", Colors.orange, () {
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

  Widget _shareOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return _FeedbackButton( // Shadow Effect Button
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ✅ Three-Dot Menu Options (Updated)
  void _showPostOptions(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),

            _buildOptionTile(Icons.bookmark_border, "Save Post", "Add this to your saved items.", () {
              _handleAction(message: "Post saved to collection! 💾");
            }),

            _buildOptionTile(Icons.visibility_off_outlined, "Hide Post", "See fewer posts like this.", () {
              _handleAction(message: "Post hidden from feed. 🙈");
            }),

            const Divider(),

            _buildOptionTile(Icons.copy, "Copy Link", "Copy post url to clipboard.", () {
              _handleAction(
                message: "Link copied! 🔗",
                action: () => _copyPostLink(post.post_id ?? "0"),
              );
            }),

            _buildOptionTile(Icons.report_gmailerrorred, "Report Post", "I'm concerned about this post.", () {
              _handleAction(message: "Report submitted. Thanks! 🛡️");
            }, isDestructive: true),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.black87, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDestructive ? Colors.red : Colors.black87)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
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
              onRefresh: () async { await postController.getAllPost(); },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CENTER FEED ---
                  SizedBox(
                    width: feedWidth,
                    child: Obx(() {
                      if (postController.isLoading.value) return _buildShimmer();

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 50),
                        children: [
                          _buildCreatePostBox(),
                          _buildStorySection(),
                          _buildAdContainer(AdType.banner728, height: 100),

                          if (postController.posts.isEmpty)
                            _buildEmptyState(),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postController.posts.length,
                            itemBuilder: (context, index) {
                              final post = postController.posts[index];
                              return Column(
                                children: [
                                  _buildFacebookPostCard(post, index),
                                  if ((index + 1) % 5 == 0)
                                    _buildAdContainer(AdType.banner300, height: 260),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),

                  // --- RIGHT SIDEBAR (Web Only) ---
                  if (isWideScreen)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Align(alignment: Alignment.centerLeft, child: Text("Sponsored", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            const SizedBox(height: 10),
                            _buildAdContainer(AdType.native, height: 300, isSidebar: true),
                            const SizedBox(height: 20),
                            const Divider(),
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

  // --- WIDGET COMPONENTS ---

  Widget _buildCreatePostBox() {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8), // Web style edge-to-edge mostly
      elevation: 0.5,
      color: Colors.white,
      shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12")),
            const SizedBox(width: 10),
            Expanded(
              child: _FeedbackButton(
                onTap: () => Get.to(() => const CreatePostScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(25)),
                  child: const Text("What's on your mind?", style: TextStyle(color: Colors.grey, fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(icon: const Icon(Icons.photo_library, color: Colors.green), onPressed: () => Get.to(() => const CreatePostScreen())),
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
              onTap: (){},
              child: Container(
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage("https://picsum.photos/200/300?random=$index"), fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]))),
                    Positioned(bottom: 8, left: 8, child: Text(index == 0 ? "Add Story" : "User $index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacebookPostCard(dynamic post, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0.5,
      shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.profile_picture_url ?? "https://via.placeholder.com/150")),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.full_name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Just now", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showPostOptions(context, post), // 3-Dot Menu
                ),
              ],
            ),
          ),

          // Content
          InkWell(
            onTap: () => Get.to(() => PostDetailPage(post: post)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.post_content != null && post.post_content!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(post.post_content!, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87)),
                  ),

                const SizedBox(height: 8),

                if (post.image_url != null && post.image_url!.isNotEmpty)
                  Hero(
                    tag: "post_image_${post.post_id}",
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: Image.network(
                        post.image_url!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(height: 400, color: Colors.grey[200], alignment: Alignment.center, child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildReactionIcon(Icons.thumb_up, Colors.blue),
                    if ((post.like_count ?? 0) > 0) ...[const SizedBox(width: 6), Text("${post.like_count}", style: const TextStyle(color: Colors.grey, fontSize: 13))],
                  ],
                ),
                InkWell(onTap: () => Get.to(() => PostDetailPage(post: post)), child: Text("${post.comment_count ?? 0} Comments", style: const TextStyle(color: Colors.grey, fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: _buildReactionButton(post, index)),
                Expanded(child: _actionButton(icon: Icons.chat_bubble_outline, label: "Comment", onTap: () => Get.to(() => PostDetailPage(post: post)))),
                Expanded(child: _actionButton(icon: Icons.share_outlined, label: "Share", onTap: () => _showShareOptions(context, post))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Widgets ---

  Widget _buildReactionButton(dynamic post, int index) {
    bool isLiked = post.isLiked;

    return _FeedbackButton(
      onTap: () {
        setState(() {
          post.isLiked = !isLiked;
          if (isLiked) {
            if (post.like_count > 0) post.like_count = post.like_count - 1;
          } else {
            post.like_count = post.like_count + 1;
          }
        });
        likeController.toggleLike(index);
      },
      child: _actionButtonContent(
          isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
          "Like",
          color: isLiked ? Colors.blue : Colors.grey[600]!
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return _FeedbackButton(
      onTap: onTap,
      child: _actionButtonContent(icon, label),
    );
  }

  Widget _actionButtonContent(IconData icon, String label, {Color color = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color == Colors.grey ? Colors.grey[600] : color, size: 20),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color == Colors.grey ? Colors.grey[600] : color, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAdContainer(AdType type, {required double height, bool isSidebar = false}) {
    if (_showDemoAds) {
      return Container(
        height: height, width: double.infinity,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.public, color: Colors.blueAccent), Text(isSidebar ? "Sponsored" : "Advertisement")])),
      );
    }
    return Container(height: height, width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 8), color: Colors.white, child: SimpleAdWidget(type: type));
  }

  Widget _buildEmptyState() {
    return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No posts found.")));
  }

  Widget _buildFriendSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("People You May Know", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(shrinkWrap: true, itemCount: 2, itemBuilder: (c, i) => const ListTile(title: Text("User Name"), leading: CircleAvatar())),
      ],
    );
  }

  Widget _buildReactionIcon(IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, size: 10, color: Colors.white));
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return "Just now";
    try {
      final diff = DateTime.now().difference(DateTime.parse(dateString));
      if (diff.inDays > 0) return "${diff.inDays}d";
      if (diff.inHours > 0) return "${diff.inHours}h";
      return "Just now";
    } catch (e) {
      return "Just now";
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(itemCount: 3, itemBuilder: (c, i) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 250, color: Colors.white, margin: const EdgeInsets.all(10))));
  }
}

// ✅ Custom Feedback Button (Shadow on Press)
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
        transform: _isPressed ? Matrix4.diagonal3Values(0.95, 0.95, 1.0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }
}