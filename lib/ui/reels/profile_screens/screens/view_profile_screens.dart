import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../screens/reel_screens.dart';
// import '../../screens/reel_screens.dart'; // ⚠️ Ensure this path is correct, otherwise use the Model below.

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
  final VideoDataModel userData;
  const ProfileViewScreen({super.key, required this.userData});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  // ✅ FIX: Using lazyPut or ensuring controller stays alive.
  // For stateful widget, simple put is fine, but we handle dispose to be clean.
  final ProfileController controller = Get.put(ProfileController());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate API Delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    // ✅ OPTIONAL: Delete controller when leaving screen to free memory
    // Get.delete<ProfileController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

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
                      _StatsRow(user: user),
                      const SizedBox(height: 25),
                      Obx(() => _SubscriptionCard(
                          isVip: controller.isVip.value,
                          price: user.contactPrice,
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
                images: user.freeContentImages,
                isLoading: _isLoading,
                isPremium: false,
                price: user.contactPrice,
                controller: controller, // ✅ FIX: Passing controller directly
              ),
              _ContentGrid(
                images: user.premiumContentImages,
                isLoading: _isLoading,
                isPremium: true,
                price: user.contactPrice,
                controller: controller, // ✅ FIX: Passing controller directly
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
  final VideoDataModel user;
  final ProfileController controller;

  const _ProfileHeader({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                backgroundImage: NetworkImage(user.profileImage),
                backgroundColor: Colors.grey[200],
              ),
            ),
            const Spacer(),
            _CircleBtn(icon: Icons.mail_outline, onTap: () => controller.tryPaidContact(user.contactPrice, user.channelName)),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.share_outlined, onTap: () => Get.snackbar("Share", "Sharing...")),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.star_border, onTap: () => Get.snackbar("Liked", "Added to favorites")),
          ],
        ),

        const SizedBox(height: 20),

        // Name & Verification
        Row(
          children: [
            Flexible(
              child: Text(user.channelName, style: AppStyles.header, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: AppColors.brand, size: 24),
            ],
          ],
        ),

        // Handle
        Text("@${user.channelName.replaceAll(' ', '').toLowerCase()}", style: AppStyles.subHeader),
        const SizedBox(height: 15),

        // Bio
        Text(user.bio, style: AppStyles.body),
        const SizedBox(height: 20),

        // Services
        const Text("ABOUT ME & SERVICES", style: AppStyles.sectionTitle),
        const SizedBox(height: 8),
        Text(user.serviceOverview, style: AppStyles.body.copyWith(color: Colors.grey[700])),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final VideoDataModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.bgLight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(user.likes, "LIKES"),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          _buildItem(user.subscribers, "FANS"),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          _buildItem(user.premiumSubscribers, "PREMIUM"),
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
        physics: const NeverScrollableScrollPhysics(), // Loading shouldn't scroll
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
      // ✅ FIX: Bouncing Physics ensures smooth scrolling inside NestedScrollView
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 0.75),
      itemBuilder: (context, index) {
        return Obx(() {
          bool isLocked = isPremium && !controller.isVip.value;
          return Material( // ✅ FIX: Added Material for Ripple Effect
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isLocked) {
                  Get.snackbar("LOCKED 🔒", "Subscribe for $price to see this.", backgroundColor: Colors.black, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20));
                } else {
                  Get.to(() => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
                    body: Center(child: Image.network(images[index])),
                  ));
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(images[index], fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.grey[200])),
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