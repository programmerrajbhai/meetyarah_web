import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import '../controller/notification_controller.dart';
// 🔹 Navigation er jonno dorkari imports
import '../../view_profile/screens/view_profile_screens.dart';
import '../../view_post/screens/post_details.dart';
import '../../home/models/get_post_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchNotifications();
        },
        color: Colors.black87,
        backgroundColor: Colors.white,
        child: Obx(() {
          // ১. লোডিং স্টেট
          if (controller.isLoading.value) {
            return const NotificationShimmerList();
          }

          // ২. এম্পটি স্টেট (নোটিফিকেশন না থাকলে)
          if (controller.notifications.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: _buildEmptyState(),
              ),
            );
          }

          // ৩. নোটিফিকেশন লিস্ট
          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              var notif = controller.notifications[index];
              return _buildNotificationItem(context, notif, controller);
            },
          );
        }),
      ),
    );
  }

  // --- 🎨 মডার্ন নোটিফিকেশন আইটেম ---
  Widget _buildNotificationItem(BuildContext context, var notif, NotificationController controller) {
    // 🔹 DEEP CHECK LOGIC: API থেকে যেই নামেই ডাটা আসুক, সেটা ধরে ফেলবে।
    String type = notif['type'] ?? "";
    String message = notif['message'] ?? notif['content'] ?? "";

    // ইউজারের নাম খোঁজার চেষ্টা (Nested object ও চেক করা হয়েছে)
    String username = notif['sender_name'] ??
        notif['full_name'] ??
        notif['username'] ??
        notif['name'] ??
        notif['user']?['name'] ??
        notif['sender']?['name'] ??
        "Someone";

    // প্রোফাইল পিকচার খোঁজার চেষ্টা
    String userPic = notif['sender_profile_pic'] ??
        notif['profile_picture_url'] ??
        notif['profile_image'] ??
        notif['avatar'] ??
        notif['user']?['profile_picture_url'] ??
        notif['sender']?['profile_picture_url'] ??
        "";

    String rawDate = notif['created_at'] ?? notif['time'] ?? "";

    // 🔹 আইডি কালেকশন
    String postId = notif['post_id']?.toString() ?? notif['reference_id']?.toString() ?? "";
    int senderId = int.tryParse(notif['sender_id']?.toString() ?? notif['user_id']?.toString() ?? "0") ?? 0;

    // 🕒 টাইমজোন ফিক্স ও TimeAgo লজিক
    String displayTime = "Just now";
    if (rawDate.isNotEmpty) {
      try {
        if (!rawDate.endsWith("Z")) {
          rawDate = "${rawDate}Z";
        }
        DateTime date = DateTime.parse(rawDate).toLocal();
        displayTime = timeago.format(date, locale: 'en_short');
      } catch (e) {
        displayTime = "Now";
      }
    }

    bool isRead = (int.tryParse(notif['is_read'].toString()) ?? 1) == 1;

    IconData actionIcon;
    Color actionColor;

    // 🔹 নোটিফিকেশনের টাইপ অনুযায়ী ব্যাজ আইকন এবং কালার
    if (type.toLowerCase().contains('like')) {
      actionIcon = CupertinoIcons.heart_fill;
      actionColor = const Color(0xFFFF3B30); // Red
    } else if (type.toLowerCase().contains('comment')) {
      actionIcon = CupertinoIcons.chat_bubble_fill;
      actionColor = const Color(0xFF007AFF); // Blue
    } else {
      actionIcon = CupertinoIcons.person_solid;
      actionColor = const Color(0xFF34C759); // Green
    }

    return Material(
      color: isRead ? Colors.white : const Color(0xFFF4F8FF), // আনরিড হলে হালকা নীল ব্যাকগ্রাউন্ড
      child: InkWell(
        onTap: () {
          // 🚀 1. রাউটিং লজিক (ক্লিক করলে কোথায় যাবে)
          if (type.toLowerCase().contains('follow')) {
            // ফলো করলে প্রোফাইলে যাবে
            if (senderId != 0) {
              Get.to(() => ViewProfileScreen(userId: senderId), transition: Transition.cupertino);
            }
          } else if (type.toLowerCase().contains('like') || type.toLowerCase().contains('comment')) {
            // লাইক বা কমেন্ট করলে পোস্ট ডিটেইলসে যাবে
            if (postId.isNotEmpty) {
              GetPostModel targetPost = GetPostModel.fromJson({
                "post_id": postId,
                "user_id": senderId,
                "username": username,
                "full_name": username,
                "profile_picture_url": userPic,
              });

              Get.to(() => PostDetailPage(post: targetPost), transition: Transition.cupertino);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Unread Indicator (Blue Dot) ---
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(top: 20, right: 10),
                  height: 8, width: 8,
                  decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                )
              else
                const SizedBox(width: 18), // অ্যালাইনমেন্ট ঠিক রাখার জন্য

              // --- Avatar & Badge (Professional Image Handle) ---
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: ClipOval(
                      child: userPic.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: userPic,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CupertinoActivityIndicator(),
                        errorWidget: (context, url, error) => const Icon(CupertinoIcons.person_fill, color: Colors.grey, size: 24),
                      )
                          : const Icon(CupertinoIcons.person_fill, color: Colors.grey, size: 24),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: actionColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                          ]
                      ),
                      child: Icon(actionIcon, size: 10, color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 14),

              // --- Notification Content (Rich Text) ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: GoogleFonts.inter(color: Colors.black87, fontSize: 14, height: 1.4),
                      children: [
                        TextSpan(text: username, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(text: " "),
                        TextSpan(text: message),
                        TextSpan(
                          text: "  $displayTime",
                          style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Trailing Action (Optional Follow Button) ---
              if (type.toLowerCase().contains('follow'))
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7), // Light Gray Button
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("View", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black87)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // --- 📭 EMPTY STATE (নোটিফিকেশন না থাকলে) ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.bell_slash, size: 45, color: Color(0xFF007AFF)),
          ),
          const SizedBox(height: 20),
          Text(
            "No notification available",
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            "When someone likes or comments on your\nposts, you'll see them here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// --- 🔄 SHIMMER LOADING ---
class NotificationShimmerList extends StatelessWidget {
  const NotificationShimmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 26),
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}