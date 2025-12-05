import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import '../widgets/like_button.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = Get.put(GetPostController());
  final likeController = Get.put(LikeController());
  final adController = Get.put(AdsterraController());

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text("Ad Blocker Detected", style: TextStyle(color: Colors.red)),
            content: const Text("Please disable your AdBlocker."),
            actions: [
              if (!kIsWeb)
                TextButton(
                  onPressed: () async {
                    const intent = AndroidIntent(action: 'android.settings.SETTINGS', flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK]);
                    await intent.launch();
                  },
                  child: const Text("Settings"),
                ),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Retry")),
            ],
          ),
        );
      },
    );
  }

  String formatTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Just now';
    try {
      final difference = DateTime.now().difference(DateTime.parse(dateString));
      if (difference.inDays >= 1) return '${difference.inDays}d ago';
      if (difference.inHours >= 1) return '${difference.inHours}h ago';
      return 'Just now';
    } catch (e) {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async { await postController.getAllPost(); },
          child: Obx(() {
            if (postController.isLoading.value) return _buildShimmer();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Social Bar (Invisible but active)
                  const SizedBox(height: 1, child: SimpleAdWidget(type: AdType.socialBar)),

                  // Stories
                  Container(
                    height: 110,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) => _storyCard(index),
                    ),
                  ),

                  // ✅ Top Banner (728x90)
                  // ওয়েবে কন্টেইনার হাইট ফিক্স না করলে আইফ্রেম কলাপ্স করে
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[100],
                    alignment: Alignment.center,
                    child: const SimpleAdWidget(type: AdType.banner728),
                  ),

                  if (postController.posts.isEmpty)
                    const Padding(padding: EdgeInsets.all(20), child: Text("No posts found")),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: postController.posts.length,
                    itemBuilder: (context, index) {
                      final post = postController.posts[index];
                      return Column(
                        children: [
                          _buildPostContent(post, index),

                          // ✅ Ads Logic: Every 5th post = Banner (300x250)
                          if ((index + 1) % 5 == 0)
                            Container(
                              height: 260,
                              width: double.infinity,
                              color: Colors.grey[50],
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: const SimpleAdWidget(type: AdType.banner300),
                            ),

                          // ✅ Ads Logic: Every 4th post = Native Ad
                          if ((index + 1) % 4 == 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SimpleAdWidget(type: AdType.native),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPostContent(post, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.profile_picture_url ?? "https://via.placeholder.com/150")),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.full_name ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(formatTimeAgo(post.created_at), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (post.post_content != null) Text(post.post_content!, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            if (post.image_url != null)
              InkWell(
                onTap: () async {
                  // SmartLink Ad on Image Click
                  if (DateTime.now().millisecond % 2 == 0) { await adController.openSmartLink(); }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    post.image_url!,
                    height: 300, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c,o,s) => Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.error)),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LikeButton(isLiked: post.isLiked, likeCount: post.like_count ?? 0, onTap: () => likeController.toggleLike(index)),

                // Comment Button (Fixed: No Ads here)
                interactionButton(Icons.comment, "${post.comment_count}", onTap: () {
                  Get.to(() => PostDetailPage(post: post));
                }),

                // Share Button (Has Popunder Ad)
                interactionButton(Icons.share, "Share", onTap: () {
                  adController.openPopunder();
                  Share.share("Check post: ${post.post_id}");
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      itemBuilder: (c, i) => Padding(padding: const EdgeInsets.all(15), child: Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 200, color: Colors.white))),
    );
  }

  Widget _storyCard(int index) {
    return Container(
      width: 80, margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
      child: Center(child: Text("Story $index")),
    );
  }

  Widget interactionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [Icon(icon, size: 20, color: Colors.grey[700]), const SizedBox(width: 5), Text(label, style: TextStyle(color: Colors.grey[700]))])),
    );
  }
}