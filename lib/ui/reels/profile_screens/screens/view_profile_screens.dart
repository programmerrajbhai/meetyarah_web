import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

// ✅ আপনার API Model & Controller ইম্পোর্ট করুন
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import 'package:meetyarah/ui/home/controllers/get_post_controllers.dart';

// -----------------------------------------------------------------------------
// 🎨 APP THEME & CONSTANTS
// -----------------------------------------------------------------------------
class AppColors {
  static const Color brand = Color(0xFF00AFF0);
  static const Color textDark = Color(0xFF242529);
  static const Color textGrey = Color(0xFF8A96A3);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color success = Colors.green;
}

class AppStyles {
  static const TextStyle header = TextStyle(
      fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5
  );
  static const TextStyle subHeader = TextStyle(
      color: AppColors.textGrey, fontSize: 15, fontWeight: FontWeight.w500
  );
  static const TextStyle body = TextStyle(
      fontSize: 15, height: 1.5, color: Color(0xFF424242)
  );
  static const TextStyle sectionTitle = TextStyle(
      fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1.0
  );
}

// -----------------------------------------------------------------------------
// 📱 MAIN SCREEN
// -----------------------------------------------------------------------------
class ProfileViewScreen extends StatefulWidget {
  final GetPostModel userData; // 🔹 VideoDataModel এর বদলে GetPostModel
  const ProfileViewScreen({super.key, required this.userData});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final ProfileController controller = Get.put(ProfileController());

  // 🔹 ইউজারের পোস্টগুলো বের করার জন্য GetPostController নিয়ে আসছি
  final GetPostController _postController = Get.find<GetPostController>();

  bool _isLoading = true;
  List<GetPostModel> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // 🔹 নির্দিষ্ট ইউজারের পোস্টগুলো ফিল্টার করা হচ্ছে
    _userPosts = _postController.posts.where((post) => post.user_id == widget.userData.user_id).toList();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    // Get.delete<ProfileController>(); // প্রয়োজন হলে আনকমেন্ট করবেন
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

    // 🔹 পোস্ট থেকে ইমেজ বা ভিডিও থাম্বনেইল ইউআরএল আলাদা করা হচ্ছে
    List<String> contentUrls = _userPosts
        .map((p) => p.image_url ?? p.directUrl ?? "")
        .where((url) => url.isNotEmpty)
        .toList();

    String contactPrice = "\$50"; // API তে প্রাইস না থাকায় ডিফল্ট প্রাইস দিলাম

    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(user: user, controller: controller),
                      const SizedBox(height: 20),
                      _StatsRow(userPosts: _userPosts), // 🔹 রিয়েল ডেটা পাঠানো হলো
                      const SizedBox(height: 25),
                      Obx(() => _SubscriptionCard(
                          isVip: controller.isVip.value,
                          price: contactPrice,
                          onTap: controller.unlockContent
                      )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildStickyTabBar(),
            ];
          },
          body: TabBarView(
            children: [


              _ContentGrid(
                images: contentUrls, // 🔹 রিয়েল ইউজারের পোস্ট
                isLoading: _isLoading,
                isPremium: false,
                price: contactPrice,
                controller: controller,
              ),

              _ContentGrid(
                images: contentUrls.isNotEmpty ? [contentUrls.first] : [], // ডেমো হিসেবে প্রথম পোস্টটি প্রিমিয়ামে দেখালাম
                isLoading: _isLoading,
                isPremium: true,
                price: contactPrice,
                controller: controller,
              ),


            ],
          ),
        ),
      ),
    );
  }

  // --- Sliver Components ---

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      floating: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  SliverPersistentHeader _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        const TabBar(
          labelColor: AppColors.textDark,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.brand,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: [
            Tab(text: "POSTS"),
            Tab(text: "PREMIUM 💎"),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧩 REUSABLE WIDGETS
// -----------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final GetPostModel user; // 🔹 API Model
  final ProfileController controller;

  const _ProfileHeader({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    String name = user.full_name ?? user.username ?? "Unknown User";
    String handle = user.username?.replaceAll(' ', '').toLowerCase() ?? "user";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar & Actions Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.profile_picture_url ?? "https://via.placeholder.com/150"),
                backgroundColor: Colors.grey[200],
              ),
            ),
            const Spacer(),
            _CircleBtn(icon: Icons.mail_outline, onTap: () => controller.tryPaidContact("\$50", name)),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.share_outlined, onTap: () => Get.snackbar("Share", "Sharing...")),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.star_border, onTap: () => Get.snackbar("Liked", "Added to favorites")),
          ],
        ),

        const SizedBox(height: 20),

        // Name
        Text(name, style: AppStyles.header, maxLines: 1, overflow: TextOverflow.ellipsis),

        // Handle
        Text("@$handle", style: AppStyles.subHeader),
        const SizedBox(height: 15),

        // Bio (API তে Bio না থাকলে ডিফল্ট টেক্সট)
        const Text("Welcome to my profile! Checkout my latest posts and videos.", style: AppStyles.body),
        const SizedBox(height: 20),

        // Services
        const Text("ABOUT ME", style: AppStyles.sectionTitle),
        const SizedBox(height: 8),
        Text("Digital Creator & Content Maker.", style: AppStyles.body.copyWith(color: Colors.grey[700])),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<GetPostModel> userPosts; // 🔹 ইউজারের পোস্ট থেকে স্ট্যাটাস হিসেব করার জন্য
  const _StatsRow({required this.userPosts});

  @override
  Widget build(BuildContext context) {
    // 🔹 ইউজারের মোট লাইক এবং পোস্ট সংখ্যা হিসেব করা
    int totalLikes = userPosts.fold(0, (sum, post) => sum + post.like_count);
    int totalPosts = userPosts.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.bgLight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(totalLikes.toString(), "LIKES"),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          _buildItem(totalPosts.toString(), "POSTS"),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          _buildItem("0", "PREMIUM"), // 🔹 ডামি ডেটা
        ],
      ),
    );
  }

  Widget _buildItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final bool isVip;
  final String price;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.isVip, required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVip ? AppColors.success.withOpacity(0.06) : const Color(0xFFF2F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isVip ? AppColors.success.withOpacity(0.5) : AppColors.brand.withOpacity(0.3)
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isVip ? Icons.check_circle : Icons.lock, color: isVip ? AppColors.success : AppColors.brand, size: 16),
              const SizedBox(width: 6),
              Text(
                isVip ? "PREMIUM MEMBER" : "UNLOCK EXCLUSIVE ACCESS",
                style: TextStyle(fontWeight: FontWeight.bold, color: isVip ? AppColors.success : AppColors.brand, fontSize: 12, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: isVip ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                elevation: isVip ? 0 : 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledBackgroundColor: Colors.transparent,
              ),
              child: Text(
                isVip ? "YOU ARE A MEMBER ✅" : "SUBSCRIBE FOR $price",
                style: TextStyle(color: isVip ? AppColors.success : Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentGrid extends StatelessWidget {
  final List<String> images;
  final bool isLoading;
  final bool isPremium;
  final String price;
  final ProfileController controller;

  const _ContentGrid({
    required this.images,
    required this.isLoading,
    required this.isPremium,
    required this.price,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
          child: Container(margin: const EdgeInsets.all(1), color: Colors.white),
        ),
      );
    }

    if (images.isEmpty) {
      return Center(child: Text("No posts available", style: TextStyle(color: Colors.grey[400])));
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 0.75),
      itemBuilder: (context, index) {
        return Obx(() {
          bool isLocked = isPremium && !controller.isVip.value;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isLocked) {
                  Get.snackbar("LOCKED 🔒", "Subscribe for $price to see this.", backgroundColor: Colors.black, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20));
                } else {
                  // 🔹 ভিডিও বা ইমেজের প্রিভিউ অপেন করার জন্য
                  Get.to(() => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
                    // যদি ভিডিও লিংক হয় তাহলে ইমেজ উইজেট দিয়ে লোড হবে না, সেক্ষেত্রে আপনার ভিডিও প্লেয়ার কল করতে হবে
                    body: Center(child: images[index].endsWith('.mp4')
                        ? const Icon(Icons.play_circle_fill, color: Colors.white, size: 60)
                        : Image.network(images[index])
                    ),
                  ));
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 🔹 ভিডিও থাম্বনেইল বা ইমেজ
                  images[index].endsWith('.mp4')
                      ? Container(color: Colors.black87, child: const Icon(Icons.play_arrow, color: Colors.white54, size: 40))
                      : Image.network(images[index], fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.grey[200])),

                  if (isLocked) Container(color: Colors.black.withOpacity(0.5), child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white, size: 28))),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧠 CONTROLLER & UTILS
// -----------------------------------------------------------------------------

class ProfileController extends GetxController {
  var isVip = false.obs;

  void unlockContent() {
    isVip.value = true;
    Get.snackbar("SUCCESS", "Welcome to the VIP Club! 👑", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
  }

  void tryPaidContact(String price, String name) {
    if (isVip.value) {
      Get.snackbar("Chat", "Opening chat...", backgroundColor: AppColors.brand, colorText: Colors.white);
    } else {
      Get.defaultDialog(
        title: "Paid Contact 💲",
        middleText: "Pay $price to chat with $name.",
        textConfirm: "PAY NOW",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.brand,
        onConfirm: () { Get.back(); unlockContent(); },
      );
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
    decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
    child: _tabBar,
  );
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}