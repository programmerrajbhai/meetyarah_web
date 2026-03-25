import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart'; // Shimmer import kora holo

import '../../view_profile/screens/view_profile_screens.dart';
import '../../view_post/screens/post_details.dart';
import '../controllers/like_controller.dart';
import 'like_button.dart';
import 'simple_video_player.dart';
import 'feedback_button.dart';

class PostCardWidget extends StatelessWidget {
  final dynamic post;
  final int index;

  const PostCardWidget({super.key, required this.post, required this.index});

  bool isVideo(String url) {
    String ext = url.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  void _handlePostClick() {
    Get.to(() => PostDetailPage(post: post));
  }

  void _handleAction({required String message, VoidCallback? action}) {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    if (action != null) action();
    Get.snackbar(
      "Success", message,
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

  String _getUserName() {
    if (post.full_name != null && post.full_name!.isNotEmpty) {
      return post.full_name!;
    }
    if (post.username != null && post.username!.isNotEmpty) {
      return post.username!;
    }
    return "Unknown User";
  }

  String _getPostLink() {
    String postId = post.post_id.toString();
    if (kIsWeb) return "${Uri.base.origin}/?id=$postId";
    return "https://meetyarah.com/?id=$postId";
  }

  void _copyPostLink() {
    Clipboard.setData(ClipboardData(text: _getPostLink()));
  }

  void _showShareOptions(BuildContext context) {
    String shareUrl = _getPostLink();
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text("Share this post", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(shareUrl, style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOptionItem(Icons.copy, "Copy Link", Colors.blue, () {
                  _handleAction(message: "Link copied to clipboard! 📋", action: _copyPostLink);
                }),
                _shareOptionItem(Icons.share, "More Options", Colors.green, () {
                  _handleAction(message: "Opening share options...", action: () => Share.share("Check out this post: $shareUrl"));
                }),
                _shareOptionItem(Icons.send_rounded, "Send in App", Colors.purple, () {
                  _handleAction(message: "Sent to friend successfully! 🚀");
                }),
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
    return FeedbackButton(
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

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            _buildOptionTile(Icons.bookmark_border, "Save Post", "Add this to your saved items.",
                    () => _handleAction(message: "Post saved to collection! 💾")),
            _buildOptionTile(Icons.visibility_off_outlined, "Hide Post", "See fewer posts like this.",
                    () => _handleAction(message: "Post hidden from feed. 🙈")),
            const Divider(),
            _buildOptionTile(Icons.copy, "Copy Link", "Copy post url to clipboard.",
                    () => _handleAction(message: "Link copied! 🔗", action: _copyPostLink)),
            _buildOptionTile(Icons.report_gmailerrorred, "Report Post", "I'm concerned about this post.",
                    () => _handleAction(message: "Report submitted. Thanks! 🛡️"), isDestructive: true),
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
    final likeController = Get.find<LikeController>();

    String profileImageUrl = (post.profile_picture_url != null && post.profile_picture_url.toString().isNotEmpty)
        ? post.profile_picture_url.toString()
        : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(_getUserName())}&background=random";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0.5,
      shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      int userId = int.tryParse(post.user_id.toString()) ?? 0;
                      if (userId != 0) Get.to(() => ViewProfileScreen(userId: userId));
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CachedNetworkImage(
                            imageUrl: profileImageUrl, width: 40, height: 40, fit: BoxFit.cover,
                            memCacheWidth: 150, // 🚀 Profile picture memory fix
                            memCacheHeight: 150,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white, width: 40, height: 40),
                            ),
                            errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getUserName(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(_formatTimeAgo(post.created_at), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: () => _showPostOptions(context)),
              ],
            ),
          ),

          InkWell(
            onTap: _handlePostClick,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.post_content != null && post.post_content!.isNotEmpty)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(post.post_content!, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87))),
                const SizedBox(height: 8),

                if (post.image_url != null && post.image_url!.isNotEmpty)
                  Container(
                    width: double.infinity, decoration: const BoxDecoration(color: Colors.black),
                    child: isVideo(post.image_url!)
                        ? ClipRRect(child: SimpleVideoPlayer(videoUrl: post.image_url!))
                        : Hero(
                      tag: "post_image_${post.post_id}_$index",
                      child: CachedNetworkImage(
                        imageUrl: post.image_url!, fit: BoxFit.contain,
                        memCacheWidth: 800, // 🚀 Main Image Memory Fix (Smooth Scrolling)
                        maxWidthDiskCache: 1000,
                        placeholder: (context, url) => SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[600]!,
                            child: Container(color: Colors.white),
                          ),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(height: 300, child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: const Icon(Icons.thumb_up, size: 10, color: Colors.white)),
                  if ((post.like_count ?? 0) > 0) ...[const SizedBox(width: 6), Text("${post.like_count}", style: const TextStyle(color: Colors.grey, fontSize: 13))]
                ]),
                InkWell(onTap: _handlePostClick, child: Text("${post.comment_count ?? 0} Comments", style: const TextStyle(color: Colors.grey, fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 0.5),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: LikeButton(isLiked: post.isLiked, onTap: () => likeController.toggleLike(index))),
                Expanded(child: FeedbackButton(onTap: _handlePostClick, child: _actionButtonContent(Icons.chat_bubble_outline, "Comment"))),
                Expanded(child: FeedbackButton(onTap: () => _showShareOptions(context), child: _actionButtonContent(Icons.share_outlined, "Share"))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtonContent(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14))
      ]),
    );
  }
}