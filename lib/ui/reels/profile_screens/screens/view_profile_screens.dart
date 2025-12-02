import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

// ✅ আপনার মডেল ইম্পোর্ট
import '../../screens/reel_screens.dart';

class ProfileViewScreen extends StatefulWidget {
  final VideoDataModel userData;

  const ProfileViewScreen({super.key, required this.userData});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final ProfileController controller = Get.put(ProfileController());

  // 🔥 Brand Colors
  final Color brandColor = const Color(0xFF00AFF0);
  final Color darkText = const Color(0xFF242529);
  final Color greyText = const Color(0xFF8A96A3);

  // 🔥 Dimensions
  final double coverHeight = 220.0;
  final double profileHeight = 110.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData; // ✅ এই 'user' ভেরিয়েবলটিই নিচে ব্যবহার করা হচ্ছে
    final double topOverlap = coverHeight - (profileHeight / 2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. App Bar
              SliverAppBar(
                backgroundColor: innerBoxIsScrolled ? Colors.white : Colors.transparent,
                elevation: 0,
                pinned: true,
                iconTheme: IconThemeData(
                    color: innerBoxIsScrolled ? Colors.black : Colors.white
                ),
                leading: _buildCircleIcon(
                    innerBoxIsScrolled, Icons.arrow_back, () => Get.back()),
                actions: [
                  _buildCircleIcon(
                      innerBoxIsScrolled, Icons.more_horiz, () {}),
                  const SizedBox(width: 8),
                ],
                expandedHeight: 680,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildFullHeaderWidget(user, topOverlap),
                ),
              ),

              // 2. Tab Bar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: darkText,
                    unselectedLabelColor: greyText,
                    indicatorColor: brandColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    tabs: const [
                      Tab(text: "POSTS"),
                      Tab(text: "PREMIUM 💎"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // ✅ FIX: এখানে 'user' পাস করা হয়েছে
              _buildContentGrid(images: user.freeContentImages, isPremium: false, user: user),
              _buildContentGrid(images: user.premiumContentImages, isPremium: true, user: user),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 MAIN HEADER WIDGET
  Widget _buildFullHeaderWidget(VideoDataModel user, double topMargin) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Cover Image
        Positioned(
          top: 0, left: 0, right: 0,
          height: coverHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _networkImageSafe(user.coverImage, fit: BoxFit.cover),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black12, Colors.black45],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. White Info Box
        Container(
          margin: EdgeInsets.only(top: coverHeight - 30),
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _circleActionBtn(Icons.mail_outline),
                  const SizedBox(width: 10),
                  _circleActionBtn(Icons.share_outlined),
                  const SizedBox(width: 10),
                  _circleActionBtn(Icons.star_border),
                ],
              ),
              const SizedBox(height: 5),

              // Name & Verified
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.channelName,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: darkText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified, color: brandColor, size: 22),
                  ]
                ],
              ),
              Text(
                "@${user.channelName.replaceAll(' ', '').toLowerCase()}",
                style: TextStyle(color: greyText, fontSize: 15, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 15),

              // Bio
              Text(
                user.bio,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
              ),

              const SizedBox(height: 20),

              // 🔥 SERVICE OVERVIEW SECTION
              _buildSectionTitle("ABOUT ME & SERVICES"),
              const SizedBox(height: 8),
              Text(
                user.serviceOverview,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
              ),

              const SizedBox(height: 20),

              // Stats Box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(user.likes, "LIKES"),
                    _verticalDivider(),
                    _statItem(user.subscribers, "FANS"),
                    _verticalDivider(),
                    _statItem(user.premiumSubscribers, "PREMIUM"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 CLIENT FEEDBACK SECTION
              _buildSectionTitle("CLIENT LOVE ❤️"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFFE082), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.clientFeedback,
                        style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.brown[700],
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Subscription Card
              Obx(() => _buildSubscriptionCard(controller.isVip.value, user)),
            ],
          ),
        ),

        // 3. Avatar (Floating)
        Positioned(
          top: topMargin,
          left: 20,
          child: Container(
            width: profileHeight,
            height: profileHeight,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
                ]
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.profileImage),
              backgroundColor: Colors.grey[200],
            ),
          ),
        ),
      ],
    );
  }

  // --- Helpers ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: greyText,
          letterSpacing: 1.0),
    );
  }

  Widget _buildCircleIcon(bool isScrolled, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isScrolled ? Colors.white : Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: isScrolled ? Border.all(color: Colors.grey.shade100) : null,
      ),
      child: IconButton(
        icon: Icon(icon, color: isScrolled ? Colors.black : Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _circleActionBtn(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.black54, size: 20),
    );
  }

  Widget _buildSubscriptionCard(bool isVip, VideoDataModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isVip ? Colors.green.withOpacity(0.06) : const Color(0xFFF2F9FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isVip ? Colors.green.withOpacity(0.5) : brandColor.withOpacity(0.3))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isVip ? Icons.check_circle : Icons.lock,
                  color: isVip ? Colors.green : brandColor, size: 16),
              const SizedBox(width: 6),
              Text(
                  isVip ? "PREMIUM MEMBER" : "UNLOCK EXCLUSIVE ACCESS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isVip ? Colors.green : brandColor,
                      fontSize: 12,
                      letterSpacing: 0.5)
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isVip ? null : controller.unlockContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                elevation: isVip ? 0 : 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledBackgroundColor: Colors.transparent,
              ),
              child: Text(
                  isVip ? "YOU ARE A MEMBER ✅" : "SUBSCRIBE FOR ${user.contactPrice}",
                  style: TextStyle(
                      color: isVip ? Colors.green : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _statItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: greyText, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _verticalDivider() => Container(height: 20, width: 1, color: Colors.grey.shade300);

  Widget _networkImageSafe(String url, {BoxFit fit = BoxFit.cover}) {
    return Image.network(url, fit: fit,
      errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.error, color: Colors.grey)),
    );
  }

  // ✅ FIX: 'VideoDataModel user' প্যারামিটার যোগ করা হয়েছে
  Widget _buildContentGrid({
    required List<String> images,
    required bool isPremium,
    required VideoDataModel user // 🔥 এটি যোগ করা হয়েছে
  }) {
    if (_isLoading) {
      return GridView.builder(
        padding: EdgeInsets.zero,
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
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 0.75),
      itemBuilder: (context, index) {
        return Obx(() {
          bool isLocked = isPremium && !controller.isVip.value;
          return GestureDetector(
            onTap: () {
              if (isLocked) {
                // ✅ এখন 'user' এক্সেস করা যাবে
                Get.snackbar("PREMIUM CONTENT 💎", "Subscribe for ${user.contactPrice} to unlock!",
                    backgroundColor: Colors.black87, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
              } else {
                Get.to(() => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
                    body: Center(child: Image.network(images[index]))
                ));
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                _networkImageSafe(images[index]),
                if (isLocked)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                        child: Icon(Icons.lock_rounded, color: Colors.white, size: 28)
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}

// Controller
class ProfileController extends GetxController {
  var isVip = false.obs;
  void unlockContent() {
    isVip.value = true;
    Get.snackbar("SUCCESS", "Welcome to the VIP Club! 👑",
        backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
  }
}

// Header Delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: _tabBar
      );
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}