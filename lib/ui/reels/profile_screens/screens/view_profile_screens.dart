import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../screens/reel_screens.dart';


// -----------------------------------------------------------------------------
// 🎨 APP THEME
// -----------------------------------------------------------------------------
class AppColors {
  static const Color brand = Color(0xFF1877F2); // Facebook Blue Style
  static const Color textDark = Color(0xFF242529);
  static const Color textGrey = Color(0xFF8A96A3);
  static const Color bgLight = Color(0xFFF0F2F5);
  static const Color success = Colors.green;
}

// -----------------------------------------------------------------------------
// 📱 MAIN PROFILE SCREEN
// -----------------------------------------------------------------------------
class ProfileViewScreen extends StatefulWidget {
  final VideoDataModel userData;
  const ProfileViewScreen({super.key, required this.userData});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  // কন্ট্রোলারকে ট্যাগ দিয়ে ইউনিক করা হয়েছে যাতে এক প্রোফাইলের ডাটা অন্য প্রোফাইলে না যায়
  late final ProfileController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController(), tag: widget.userData.url);

    // লোডিং সিমুলেশন (যেন মনে হয় সার্ভার থেকে ডাটা আসছে)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
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
                controller: controller,
              ),
              _ContentGrid(
                images: user.premiumContentImages,
                isLoading: _isLoading,
                isPremium: true,
                price: user.contactPrice,
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
      title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
    );
  }

  SliverPersistentHeader _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        const TabBar(
          labelColor: AppColors.brand,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.brand,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
// 🧩 WIDGETS
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
        Row(
          children: [
            // Profile Pic with Hero Animation
            Hero(
              tag: user.url + user.channelName,
              child: Container(
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
            ),
            const Spacer(),
            _CircleBtn(icon: Icons.mail_outline, onTap: () => controller.tryPaidContact(user.contactPrice, user.channelName)),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.share_outlined, onTap: () => Get.snackbar("Share", "Sharing profile link...")),
            const SizedBox(width: 10),
            _CircleBtn(icon: Icons.star_border, onTap: () => Get.snackbar("Liked", "Added to favorites")),
          ],
        ),
        const SizedBox(height: 15),

        // Name & Verification
        Row(
          children: [
            Flexible(
              child: Text(user.channelName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: AppColors.brand, size: 22),
            ],
          ],
        ),
        Text("@${user.channelName.replaceAll(' ', '').toLowerCase()}", style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),

        const SizedBox(height: 15),
        Text(user.bio, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),

        const SizedBox(height: 20),
        const Text("ABOUT ME & SERVICES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1.0)),
        const SizedBox(height: 5),
        Text(user.serviceOverview, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
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
        borderRadius: BorderRadius.circular(12),
        color: AppColors.bgLight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(user.likes, "LIKES"),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          _buildItem(user.subscribers, "FANS"),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          _buildItem(user.premiumSubscribers, "VIP"),
        ],
      ),
    );
  }

  Widget _buildItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVip ? AppColors.success.withOpacity(0.08) : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isVip ? AppColors.success.withOpacity(0.3) : AppColors.brand.withOpacity(0.2)
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isVip ? Icons.check_circle : Icons.lock, color: isVip ? AppColors.success : AppColors.brand, size: 18),
              const SizedBox(width: 8),
              Text(
                isVip ? "PREMIUM MEMBER" : "UNLOCK EXCLUSIVE CONTENT",
                style: TextStyle(fontWeight: FontWeight.bold, color: isVip ? AppColors.success : AppColors.brand, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 45,
            child: ElevatedButton(
              onPressed: isVip ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                isVip ? "MEMBER ACTIVE" : "SUBSCRIBE $price / MO",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.only(top: 2),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 0.8),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        ),
      );
    }

    if (images.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No posts available yet.", style: TextStyle(color: Colors.grey)),
      ));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 0.75),
      itemBuilder: (context, index) {
        return Obx(() {
          bool isLocked = isPremium && !controller.isVip.value;
          return GestureDetector(
            onTap: () {
              if (isLocked) {
                Get.snackbar("Premium Only 💎", "Subscribe for $price to view this content.", backgroundColor: Colors.black87, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20));
              } else {
                _showFullImage(context, images[index]);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(images[index], fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.grey[200], child: const Icon(Icons.error, color: Colors.grey))),
                if (isLocked) Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white, size: 30)),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showFullImage(BuildContext context, String url) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: Image.network(url)),
    ));
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
        width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧠 CONTROLLER
// -----------------------------------------------------------------------------
class ProfileController extends GetxController {
  var isVip = false.obs;

  void unlockContent() {
    isVip.value = true;
    Get.snackbar("Subscribed! 🎉", "You now have full access.", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20));
  }

  void tryPaidContact(String price, String name) {
    if (isVip.value) {
      Get.snackbar("Chat", "Opening chat with $name...", backgroundColor: AppColors.brand, colorText: Colors.white);
    } else {
      Get.defaultDialog(
        title: "Paid Service",
        middleText: "Pay $price to chat personally with $name.",
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
    decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
    child: _tabBar,
  );
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}