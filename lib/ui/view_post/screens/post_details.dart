import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart'; // 🔹 Video Player যুক্ত করা হলো

import '../../home/models/get_post_model.dart';
import '../../home/controllers/like_controller.dart';
import '../controllers/comments_controllers.dart';
import '../models/comments_model.dart';

class PostDetailPage extends StatefulWidget {
  final GetPostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late CommentController commentController;
  final LikeController likeController = Get.put(LikeController());

  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    int postId = int.tryParse(widget.post.post_id.toString()) ?? 0;

    commentController = Get.put(
      CommentController(postId: postId),
      tag: postId.toString(),
    );

    isLiked = widget.post.isLiked;
    likeCount = widget.post.like_count ?? 0;
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

      if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y";
      if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo";
      if (diff.inDays > 0) return "${diff.inDays}d";
      if (diff.inHours > 0) return "${diff.inHours}h";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m";
      return "Now";
    } catch (e) {
      return "Now";
    }
  }

  void _handleAction({required String message, VoidCallback? action}) {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    if (action != null) action();
    Get.snackbar(
      "Success", message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void _copyPostLink() {
    Clipboard.setData(ClipboardData(text: "https://meetyarah.com/post/${widget.post.post_id}"));
    _handleAction(message: "Link copied! 📋");
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        children: [
          Text("Share Post", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _shareOptionItem(Icons.copy_rounded, "Copy Link", Colors.blueAccent, _copyPostLink),
              _shareOptionItem(Icons.ios_share_rounded, "Share via...", Colors.green, () {
                _handleAction(message: "Opening options...", action: () => Share.share("Check this post: https://meetyarah.com/post/${widget.post.post_id}"));
              }),
              _shareOptionItem(Icons.send_rounded, "Message", Colors.purpleAccent, () => _handleAction(message: "Sent! 🚀")),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        children: [
          _buildOptionTile(Icons.bookmark_outline_rounded, "Save Post", () => _handleAction(message: "Post saved! 💾")),
          _buildOptionTile(Icons.visibility_off_outlined, "Hide Post", () => _handleAction(message: "Post hidden. 🙈")),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _buildOptionTile(Icons.report_gmailerrorred_rounded, "Report Post", () => _handleAction(message: "Reported. 🛡️"), isDestructive: true),
        ],
      ),
    );
  }

  void _openFullImage() {
    String mediaUrl = widget.post.directUrl ?? widget.post.image_url ?? "";
    bool isVideo = mediaUrl.toLowerCase().endsWith('.mp4') || widget.post.isDirectLink == true;

    if (mediaUrl.isEmpty || isVideo) return; // 🔹 ভিডিও হলে ফুল স্ক্রিন ইমেজ ওপেন হবে না

    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: InteractiveViewer(child: CachedNetworkImage(imageUrl: mediaUrl))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Post", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black87), onPressed: _showPostOptions),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWeb = constraints.maxWidth > 700;
            return Center(
              child: Container(
                width: isWeb ? 600 : double.infinity,
                decoration: isWeb ? BoxDecoration(
                    color: Colors.white,
                    border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade200))
                ) : null,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildPostContent(),
                            Container(height: 8, color: const Color(0xFFF2F2F7)),
                            _buildCommentHeader(),
                            _buildCommentSection(),
                          ],
                        ),
                      ),
                    ),
                    _buildCommentInput(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 🎨 POST CONTENT WIDGET ---
  Widget _buildPostContent() {
    String mediaUrl = widget.post.directUrl ?? widget.post.image_url ?? "";
    bool isVideo = mediaUrl.toLowerCase().endsWith('.mp4') || widget.post.isDirectLink == true;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(widget.post.profile_picture_url ?? "https://via.placeholder.com/150"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.post.full_name != null && widget.post.full_name!.isNotEmpty) ? widget.post.full_name! : "ID: ${widget.post.user_id}",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87),
                      ),
                      Text(
                        _formatTimeAgo(widget.post.created_at),
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Caption Text
          if (widget.post.post_content != null && widget.post.post_content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                widget.post.post_content!,
                style: GoogleFonts.inter(fontSize: 15, height: 1.4, color: Colors.black87),
              ),
            ),

          // 🔹 MEDIA RENDERER (IMAGE OR VIDEO)
          if (mediaUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isVideo
                    ? _DetailsVideoPlayer(videoUrl: mediaUrl) // ✅ ভিডিও প্লেয়ার
                    : GestureDetector(
                  onTap: _openFullImage,
                  child: CachedNetworkImage( // ✅ ইমেজ
                    imageUrl: mediaUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => AspectRatio(aspectRatio: 1, child: Container(color: Colors.grey.shade100)),
                  ),
                ),
              ),
            ),

          // Likes & Comments Count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text("$likeCount", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
                const Spacer(),
                Text("${widget.post.comment_count ?? 0} Comments", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),

          // Actions
          Row(
            children: [
              Expanded(child: _buildReactionButton()),
              Expanded(child: _actionButton(Icons.chat_bubble_outline_rounded, "Comment", () {})),
              Expanded(child: _actionButton(Icons.ios_share_rounded, "Share", _showShareOptions)),
            ],
          ),
        ],
      ),
    );
  }

  // --- 💬 COMMENT SECTION ---
  Widget _buildCommentHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text("Comments", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87)),
          const Spacer(),
          Icon(Icons.unfold_more_rounded, size: 18, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Obx(() {
      if (commentController.isLoading.value) {
        return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
      }
      if (commentController.comments.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(50),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text("No comments yet", style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: commentController.comments.length,
        itemBuilder: (context, index) {
          return _buildSingleComment(commentController.comments[index]);
        },
      );
    });
  }

  Widget _buildSingleComment(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: CachedNetworkImageProvider(comment.profilePictureUrl ?? 'https://i.pravatar.cc/150?img=5'),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(comment.fullName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                    const SizedBox(width: 8),
                    Text(_formatTimeAgo(comment.createdAt), style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(comment.commentText, style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, height: 1.3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ⌨️ BOTTOM INPUT FIELD ---
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundImage: CachedNetworkImageProvider("https://i.pravatar.cc/150?img=12")),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: commentController.commentTextController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (commentController.commentTextController.text.trim().isNotEmpty) {
                  commentController.addComment();
                  FocusScope.of(context).unfocus();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton() {
    return _FeedbackButton(
      onTap: () {
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        int idx = int.tryParse(widget.post.post_id.toString()) ?? 0;
        likeController.toggleLike(idx);
        HapticFeedback.lightImpact();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isLiked ? Colors.redAccent : Colors.black54, size: 22),
            const SizedBox(width: 6),
            Text("Like", style: GoogleFonts.inter(color: isLiked ? Colors.redAccent : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return _FeedbackButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black54, size: 20),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return _FeedbackButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87, size: 24),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, color: isDestructive ? Colors.red : Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildBottomSheetContainer({required List<Widget> children}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 20),
        ...children,
      ]),
    );
  }
}

// ✅ Smooth Bounce Feedback Button
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
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: _isPressed ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
        decoration: BoxDecoration(color: _isPressed ? Colors.black.withOpacity(0.05) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: widget.child,
      ),
    );
  }
}

// ==========================================
// 🔹 INLINE VIDEO PLAYER FOR DETAILS PAGE
// ==========================================
class _DetailsVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _DetailsVideoPlayer({required this.videoUrl});

  @override
  State<_DetailsVideoPlayer> createState() => _DetailsVideoPlayerState();
}

class _DetailsVideoPlayerState extends State<_DetailsVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller?.setLooping(true);
          _controller?.setVolume(1.0); // ডিটেইলস পেজে সাউন্ড থাকবে
          _controller?.play(); // অটো প্লে
          _isPlaying = true;
        }
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller!.value.isPlaying) {
            _controller?.pause();
            _isPlaying = false;
          } else {
            _controller?.play();
            _isPlaying = true;
          }
        });
      },
      child: Container(
        color: Colors.black,
        width: double.infinity,
        child: _isInitialized
            ? AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),
              if (!_isPlaying)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                ),
              Positioned(
                bottom: 10, right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMuted = !_isMuted;
                      _controller?.setVolume(_isMuted ? 0 : 1);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 20),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(playedColor: Colors.blueAccent, bufferedColor: Colors.white24, backgroundColor: Colors.transparent),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
              )
            ],
          ),
        )
            : const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: Colors.grey))),
      ),
    );
  }
}