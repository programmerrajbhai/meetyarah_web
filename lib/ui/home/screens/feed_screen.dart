import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Controllers & Models
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../profile/controllers/profile_controllers.dart';

// ✅ Screens & Widgets
import '../widgets/story_list_widget.dart';
import '../widgets/create_post_box.dart';
import '../widgets/post_card_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final postController = Get.put(GetPostController());
  final likeController = Get.put(LikeController());
  final profileController = Get.put(ProfileController());

  // 🔹 Real API Models
  List<GetPostModel> _feedVideos = [];
  GetPostModel? _pinnedVideo;
  GetPostModel? _pinnedPost;

  @override
  void initState() {
    super.initState();
    _initializeFeedData();
  }

  Future<void> _initializeFeedData() async {
    await postController.getAllPost(isRefresh: true);

    // 🔹 API থেকে ভিডিও পোস্টগুলো আলাদা করা হচ্ছে
    _extractVideosFromPosts();

    // 🔹 Deep link চেক
    _checkDeepLinkForPosts();
  }

  void _extractVideosFromPosts() {
    setState(() {
      _feedVideos = postController.posts.where((post) {
        String url = post.directUrl ?? post.image_url ?? "";
        return url.toLowerCase().endsWith('.mp4') || post.isDirectLink == true;
      }).toList();
    });
  }

  void _checkDeepLinkForPosts() {
    if (kIsWeb) {
      try {
        String? targetId = Uri.base.queryParameters['id'] ?? Uri.base.queryParameters['post_id'];

        if (targetId != null && targetId.isNotEmpty) {
          int index = postController.posts.indexWhere((p) => p.post_id.toString() == targetId);
          if (index != -1) {
            var post = postController.posts.removeAt(index);

            setState(() {
              String url = post.directUrl ?? post.image_url ?? "";
              bool isVideo = url.toLowerCase().endsWith('.mp4') || post.isDirectLink == true;

              if (isVideo) {
                _pinnedVideo = post;
              } else {
                _pinnedPost = post;
              }

              postController.posts.insert(0, post);
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar(
                  "Shared Content",
                  "Showing shared content at the top.",
                  backgroundColor: Colors.blueAccent,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP
              );
            });
          }
        }
      } catch (e) {
        debugPrint("Error parsing Deep Link ID: $e");
      }
    }
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
                await postController.refreshPosts();
                _extractVideosFromPosts();
                _checkDeepLinkForPosts();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: feedWidth,
                    child: Obx(() {
                      if (postController.isLoading.value && postController.posts.isEmpty) {
                        return _buildShimmer();
                      }

                      return CustomScrollView(
                        controller: postController.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: CreatePostBox()),
                          const SliverToBoxAdapter(child: StoryListWidget()),

                          // --- Pinned Video (Shared) ---
                          if (_pinnedVideo != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: const Text("Shared Video", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    const SizedBox(height: 8),
                                    FeedVideoCard(
                                      key: ValueKey("pinned_${_pinnedVideo!.post_id}"),
                                      postData: _pinnedVideo!,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // --- Pinned Post (Shared) ---
                          if (_pinnedPost != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: const Text("Shared Post", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    const SizedBox(height: 8),
                                    PostCardWidget(post: _pinnedPost!, index: 0),
                                  ],
                                ),
                              ),
                            ),

                          // --- Empty State ---
                          if (postController.posts.isEmpty && !postController.hasError.value)
                            const SliverToBoxAdapter(
                              child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No posts found."))),
                            ),

                          // --- Main Feed Loop ---
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final post = postController.posts[index];
                                Widget videoWidget = const SizedBox.shrink();

                                // 🔹 প্রতি ১০টি পোস্টের পর ফিড থেকে একটি ভিডিও দেখানো হবে
                                if (_feedVideos.isNotEmpty && (index + 1) % 10 == 0) {
                                  int videoIndex = ((index + 1) ~/ 10) % _feedVideos.length;
                                  videoWidget = Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: FeedVideoCard(
                                      key: ValueKey("feed_video_${_feedVideos[videoIndex].post_id}"),
                                      postData: _feedVideos[videoIndex],
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    PostCardWidget(post: post, index: index),
                                    videoWidget,
                                  ],
                                );
                              },
                              childCount: postController.posts.length,
                            ),
                          ),

                          // --- Pagination Loading Indicator ---
                          SliverToBoxAdapter(
                            child: Obx(() {
                              if (postController.isMoreDataLoading.value) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.0),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.blue)),
                                        SizedBox(width: 12),
                                        Text("Loading more posts...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              if (!postController.hasMoreData && postController.posts.isNotEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25.0),
                                  child: Center(child: Text("You have reached the end!", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 50)),
                        ],
                      );
                    }),
                  ),

                  // --- Sidebar (Web Only) ---
                  if (isWideScreen)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(child: _buildFriendSuggestions()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFriendSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("People You May Know", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (c, i) => ListTile(
              title: Text("Suggested User ${i+1}"),
              leading: const CircleAvatar(child: Icon(Icons.person)),
              trailing: TextButton(onPressed: (){}, child: const Text("Add Friend")),
            )),
      ],
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
        itemCount: 3,
        itemBuilder: (c, i) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
            child: Container(height: 250, color: Colors.white, margin: const EdgeInsets.all(10))));
  }
}

// ==========================================
// 🔹 INLINE FEED VIDEO CARD WIDGET
// ==========================================
class FeedVideoCard extends StatefulWidget {
  final GetPostModel postData;

  const FeedVideoCard({super.key, required this.postData});

  @override
  State<FeedVideoCard> createState() => _FeedVideoCardState();
}

class _FeedVideoCardState extends State<FeedVideoCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.postData.isLiked;
    _initializeVideo();
  }

  void _initializeVideo() {
    String videoUrl = widget.postData.directUrl ?? widget.postData.image_url ?? "";
    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller?.setLooping(true);
          _controller?.setVolume(0); // Start muted
        }
      }).catchError((e) {
        debugPrint("Inline Video Error: $e");
      });
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller?.pause();
          _isPlaying = false;
        } else {
          _controller?.play();
          _isPlaying = true;
        }
      });
    }
  }

  void _toggleMute() {
    if (_controller != null && _isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        _controller?.setVolume(_isMuted ? 0 : 1);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postData;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.profile_picture_url ?? "https://via.placeholder.com/150"),
            ),
            title: Text(post.full_name ?? post.username ?? "Unknown User", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post.created_at ?? "Just now", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.more_horiz),
          ),

          // Caption
          if (post.post_content != null && post.post_content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(post.post_content!),
            ),

          // Video Player
          GestureDetector(
            onTap: _togglePlayPause,
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
                      const Icon(Icons.play_circle_fill, color: Colors.white70, size: 60),
                    Positioned(
                      bottom: 10, right: 10,
                      child: GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              )
                  : const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: Colors.grey))),
            ),
          ),

          // Footer (Likes & Comments)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thumb_up, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text("${post.like_count}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Text("${post.comment_count} Comments", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Actions
          Row(
            children: [
              _buildActionButton(
                  icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  label: "Like",
                  color: _isLiked ? Colors.blue : Colors.grey[700]!,
                  onTap: () {
                    setState(() => _isLiked = !_isLiked);
                    HapticFeedback.lightImpact();
                  }
              ),
              _buildActionButton(icon: Icons.comment_outlined, label: "Comment", color: Colors.grey[700]!, onTap: () {}),
              _buildActionButton(icon: Icons.share_outlined, label: "Share", color: Colors.grey[700]!, onTap: () {
                Share.share("Check this out: https://meetyarah.com/?post_id=${post.post_id}");
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}