import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Cached Image Package

// Controllers & Models
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../profile/controllers/profile_controllers.dart';

// Screens & Widgets
import '../widgets/story_list_widget.dart';
import '../widgets/create_post_box.dart';
import '../widgets/post_card_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // ✅ Memory Optimization: Get.put এর বদলে চেক করে ইনজেক্ট করা হচ্ছে
  late final GetPostController postController;
  late final LikeController likeController;
  late final ProfileController profileController;

  List<GetPostModel> _feedVideos = [];
  GetPostModel? _pinnedVideo;
  GetPostModel? _pinnedPost;

  @override
  void initState() {
    super.initState();
    // ✅ Controllers Initialize
    postController = Get.isRegistered<GetPostController>() ? Get.find<GetPostController>() : Get.put(GetPostController());
    likeController = Get.isRegistered<LikeController>() ? Get.find<LikeController>() : Get.put(LikeController());
    profileController = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

    _initializeFeedData();
  }

  // ✅ Memory Optimization: স্ক্রিন থেকে বের হলে কন্ট্রোলারগুলো রিমুভ করে মেমোরি ফ্রি করা
  @override
  void dispose() {
    // যদি ফিড স্ক্রিন মেইন স্ক্রিন হয়, তবে GetPostController ডিলিট না করাই ভালো।
    // তবে অন্য স্ক্রিনে গেলে মেমোরি ফ্রি করতে চাইলে নিচের লাইনগুলো আনকমেন্ট করে দিবেন:
    // Get.delete<GetPostController>();
    // Get.delete<LikeController>();
    super.dispose();
  }

  Future<void> _initializeFeedData() async {
    await postController.getAllPost(isRefresh: true);
    _extractVideosFromPosts();
    _checkDeepLinkForPosts();
  }

  void _extractVideosFromPosts() {
    if(mounted) {
      setState(() {
        _feedVideos = postController.posts.where((post) {
          String url = post.directUrl ?? post.image_url ?? "";
          return url.toLowerCase().endsWith('.mp4') || post.isDirectLink == true;
        }).toList();
      });
    }
  }

  void _checkDeepLinkForPosts() {
    if (kIsWeb) {
      try {
        String? targetId = Uri.base.queryParameters['id'] ?? Uri.base.queryParameters['post_id'];
        if (targetId != null && targetId.isNotEmpty) {
          int index = postController.posts.indexWhere((p) => p.post_id.toString() == targetId);
          if (index != -1) {
            var post = postController.posts.removeAt(index);
            if(mounted) {
              setState(() {
                String url = post.directUrl ?? post.image_url ?? "";
                if (url.toLowerCase().endsWith('.mp4') || post.isDirectLink == true) {
                  _pinnedVideo = post;
                } else {
                  _pinnedPost = post;
                }
                postController.posts.insert(0, post);
              });
            }
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

                          if (_pinnedVideo != null)
                            SliverToBoxAdapter(
                              child: FeedVideoCard(key: ValueKey("pinned_${_pinnedVideo!.post_id}"), postData: _pinnedVideo!),
                            ),

                          if (_pinnedPost != null)
                            SliverToBoxAdapter(
                              child: PostCardWidget(post: _pinnedPost!, index: 0),
                            ),

                          if (postController.posts.isEmpty && !postController.hasError.value)
                            const SliverToBoxAdapter(
                              child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No posts found."))),
                            ),

                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final post = postController.posts[index];
                                Widget videoWidget = const SizedBox.shrink();

                                if (_feedVideos.isNotEmpty && (index + 1) % 10 == 0) {
                                  int videoIndex = ((index + 1) ~/ 10) % _feedVideos.length;
                                  videoWidget = Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: FeedVideoCard(postData: _feedVideos[videoIndex]),
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
                          // Pagination Loader
                          SliverToBoxAdapter(child: SizedBox(height: 100)),
                        ],
                      );
                    }),
                  ),
                  if (isWideScreen)
                    Container(width: 350, padding: const EdgeInsets.all(16), child: _buildFriendSuggestions()),
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
            )),
      ],
    );
  }

  Widget _buildShimmer() => const Center(child: CircularProgressIndicator());
}

// ==========================================
// 🔹 INLINE FEED VIDEO CARD WIDGET (Muted for AutoPlay)
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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    String videoUrl = widget.postData.directUrl ?? widget.postData.image_url ?? "";
    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller?.setLooping(true);
          // ✅ Web Auto-Play Policy Fix: Volume MUST be 0
          _controller?.setVolume(0);
          _controller?.play(); // Auto Play on Feed
          _isPlaying = true;
        }
      }).catchError((e) => debugPrint("Video Error: $e"));
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postData;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              // ✅ Cached Network Image for Profile Picture
              backgroundImage: CachedNetworkImageProvider(post.profile_picture_url ?? "https://via.placeholder.com/150"),
            ),
            title: Text(post.full_name ?? post.username ?? "Unknown User", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post.created_at ?? "Just now"),
          ),

          if (post.post_content != null && post.post_content!.isNotEmpty)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Text(post.post_content!)),

          GestureDetector(
            onTap: () {
              setState(() {
                _controller!.value.isPlaying ? _controller?.pause() : _controller?.play();
                _isPlaying = _controller!.value.isPlaying;
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
                    if (!_isPlaying) const Icon(Icons.play_circle_fill, color: Colors.white70, size: 60),
                    Positioned(
                      bottom: 10, right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isMuted = !_isMuted;
                          _controller?.setVolume(_isMuted ? 0 : 1);
                        }),
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
        ],
      ),
    );
  }
}