import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchNotifications();
        },
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const NotificationShimmerList();
          }

          if (controller.notifications.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: _buildEmptyState(),
              ),
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              var notif = controller.notifications[index];
              return _buildNotificationItem(notif, controller);
            },
          );
        }),
      ),
    );
  }

  // --- নোটিফিকেশন আইটেম ---
  Widget _buildNotificationItem(var notif, NotificationController controller) {
    String type = notif['type'] ?? "";
    String message = notif['message'] ?? "";
    String username = notif['username'] ?? "Unknown";
    String userPic = notif['profile_picture_url'] ?? "";
    String rawDate = notif['created_at'] ?? "";

    // 🔥 ফিক্সড: টাইমজোন সমস্যা সমাধান
    String displayTime = "Just now";
    if (rawDate.isNotEmpty) {
      try {
        // ১. যদি শেষে 'Z' না থাকে, তবে যোগ করে UTC হিসেবে মার্ক করি
        if (!rawDate.endsWith("Z")) {
          rawDate = "$rawDate" "Z";
        }
        // ২. এরপর লোকাল টাইমে কনভার্ট করি
        DateTime date = DateTime.parse(rawDate).toLocal();
        displayTime = timeago.format(date);
      } catch (e) {
        displayTime = "Just now";
      }
    }

    bool isRead = (int.tryParse(notif['is_read'].toString()) ?? 1) == 1;

    IconData actionIcon;
    Color actionColor;

    if (type == 'like') {
      actionIcon = Icons.favorite_rounded;
      actionColor = const Color(0xFFFF5252);
    } else if (type == 'comment') {
      actionIcon = Icons.chat_bubble_rounded;
      actionColor = const Color(0xFF448AFF);
    } else {
      actionIcon = Icons.person_add_rounded;
      actionColor = const Color(0xFF00C853);
    }

    return Material(
      color: isRead ? Colors.white : const Color(0xFFE3F2FD).withOpacity(0.4),
      child: InkWell(
        onTap: () {
          controller.handleNotificationTap(notif);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: userPic.isNotEmpty ? NetworkImage(userPic) : null,
                      child: userPic.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
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
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(actionIcon, size: 12, color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            color: Colors.black87, fontSize: 15, height: 1.4),
                        children: [
                          TextSpan(
                            text: username,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: " "),
                          TextSpan(
                            text: message,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayTime,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(top: 8, left: 8),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border_rounded,
                size: 50, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          Text(
            "No Activity Yet",
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            "When someone likes or comments on your\nposts, you'll see them here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// --- Shimmer Loading ---
class NotificationShimmerList extends StatelessWidget {
  const NotificationShimmerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      padding: const EdgeInsets.symmetric(vertical: 10),
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
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