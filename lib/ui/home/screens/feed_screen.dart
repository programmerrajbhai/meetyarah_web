import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/get_post_controllers.dart';
import '../controllers/like_controller.dart';
import '../../reels/screens/reel_screens.dart';
import '../../profile/controllers/profile_controllers.dart';

// ✅ Custom Widgets Gulo Import Kora Holo
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

  List<VideoDataModel> _feedVideos = [];
  VideoDataModel? _pinnedVideo;
  dynamic _pinnedPost;

  @override
  void initState() {
    super.initState();
    _initializeFeedData();
  }

  Future<void> _initializeFeedData() async {
    await postController.getAllPost(isRefresh: true);
    _checkDeepLinkForPosts();
    _loadFeedVideos();
  }

  void _checkDeepLinkForPosts() {
    if (kIsWeb) {
      try {
        String? targetId = Uri.base.queryParameters['id'];
        if (targetId != null && targetId.isNotEmpty) {
          int index = postController.posts.indexWhere((p) => p.post_id.toString() == targetId);
          if (index != -1) {
            var post = postController.posts.removeAt(index);
            setState(() {
              _pinnedPost = post;
              postController.posts.insert(0, post);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar("Shared Post", "Showing shared post at the top.",
                  backgroundColor: Colors.blueAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
            });
          }
        }
      } catch (e) {
        debugPrint("Error parsing Post ID: $e");
      }
    }
  }

  void _loadFeedVideos() {
    var videos = VideoDataHelper.generateAllVideos();
    if (kIsWeb) {
      try {
        String? targetPostId = Uri.base.queryParameters['post_id'];
        if (targetPostId != null && targetPostId.isNotEmpty) {
          int targetIndex = videos.indexWhere((video) => video.url.contains(targetPostId));
          if (targetIndex != -1) {
            var foundVideo = videos.removeAt(targetIndex);
            setState(() {
              _pinnedVideo = foundVideo;
              videos.insert(0, foundVideo);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar("Shared Video", "Showing video at the top.",
                  backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
            });
          }
        }
      } catch (e) {
        debugPrint("Error parsing Video ID: $e");
      }
    }
    if (mounted) setState(() => _feedVideos = videos);
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
                _checkDeepLinkForPosts();
                _loadFeedVideos();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: feedWidth,
                    child: Obx(() {
                      if (postController.isLoading.value) return _buildShimmer();

                      return CustomScrollView(
                        controller: postController.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: CreatePostBox()), // ✅ Refactored Widget
                          const SliverToBoxAdapter(child: StoryListWidget()),

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
                                    FacebookVideoCard(
                                      key: ValueKey("pinned_${_pinnedVideo!.url}"),
                                      videoData: _pinnedVideo!,
                                      allVideosList: _feedVideos.map((e) => e.url).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

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
                                    PostCardWidget(post: _pinnedPost, index: 0), // ✅ Refactored Widget
                                  ],
                                ),
                              ),
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
                                    child: FacebookVideoCard(
                                      key: ValueKey("feed_video_${_feedVideos[videoIndex].url}"),
                                      videoData: _feedVideos[videoIndex],
                                      allVideosList: _feedVideos.map((e) => e.url).toList(),
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    PostCardWidget(post: post, index: index), // ✅ Refactored Widget
                                    videoWidget,
                                  ],
                                );
                              },
                              childCount: postController.posts.length,
                            ),
                          ),

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
            shrinkWrap: true, itemCount: 2,
            itemBuilder: (c, i) => const ListTile(title: Text("User Name"), leading: CircleAvatar())),
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