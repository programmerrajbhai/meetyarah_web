import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:meetyarah/ui/education/screens/education_screen.dart';
import 'package:meetyarah/ui/profile/screens/profile_screens.dart';
import '../../login_reg_screens/controllers/auth_service.dart';
import '../../profile/controllers/profile_controllers.dart';
import '../../spoken_english/screens/spoken_english_screen.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({Key? key}) : super(key: key);

  final AuthService authService = Get.find<AuthService>();
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // 🔹 Apple System Gray 6 Background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER (Title & Search/Settings) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Menu",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        _buildHeaderIcon(CupertinoIcons.search),
                        const SizedBox(width: 10),
                        _buildHeaderIcon(CupertinoIcons.gear_alt),
                      ],
                    )
                  ],
                ),
              ),

              // --- 2. PROFILE CARD (Modern iOS Style) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildModernProfileCard(),
              ),

              const SizedBox(height: 25),

              // --- 3. QUICK SHORTCUTS (Grid) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Shortcuts", style: _sectionTitleStyle()),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildShortcutsGrid(),
              ),

              const SizedBox(height: 30),

              // --- 4. LEARNING HUB (Horizontal Carousel) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Learning Hub 🚀", style: _sectionTitleStyle()),
                    Text("See All", style: GoogleFonts.inter(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildLearningHubCarousel(),

              const SizedBox(height: 30),

              // --- 5. PREFERENCES & SETTINGS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Preferences", style: _sectionTitleStyle()),
              ),
              const SizedBox(height: 12),
              _buildPreferencesSection(),

              const SizedBox(height: 30),

              // --- 6. LOGOUT BUTTON ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLogoutButton(),
              ),

              // --- 7. APP VERSION FOOTER ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    "Meetyarah v1.0.0",
                    style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================
  // 🎨 STYLES & REUSABLE WIDGETS
  // =====================================
  TextStyle _sectionTitleStyle() => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    letterSpacing: -0.3,
  );

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 22),
        onPressed: () {},
      ),
    );
  }

  // --- 1. PROFILE CARD ---
  Widget _buildModernProfileCard() {
    return Obx(() {
      final user = controller.profileUser.value;
      return GestureDetector(
        onTap: () => Get.to(() => const ProfilePage()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: NetworkImage(
                    user?.profilePictureUrl ?? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.fullName ?? 'User')}&background=random"
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? "Loading...",
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "View your profile",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.chevron_right, color: Colors.black54, size: 16),
              ),
            ],
          ),
        ),
      );
    });
  }

  // --- 2. SHORTCUTS GRID ---
  Widget _buildShortcutsGrid() {
    final List<Map<String, dynamic>> shortcuts = [
      {'icon': CupertinoIcons.bookmark_fill, 'label': 'Saved', 'color': Colors.purpleAccent},
      {'icon': CupertinoIcons.group_solid, 'label': 'Groups', 'color': Colors.blueAccent},
      {'icon': CupertinoIcons.calendar, 'label': 'Events', 'color': Colors.orangeAccent},
      {'icon': CupertinoIcons.clock_fill, 'label': 'Memories', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {}, // TODO: Navigate to respective screens
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(item['icon'], color: item['color'], size: 24),
                  const SizedBox(width: 12),
                  Text(item['label'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 3. LEARNING HUB (Horizontal Scroll) ---
  Widget _buildLearningHubCarousel() {
    return SizedBox(
      height: 160,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildCarouselCard(
            title: "Education Hub",
            subtitle: "SSC • HSC • Job Prep",
            icon: CupertinoIcons.book_fill,
            colors: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
            onTap: () => Get.to(() => const EducationScreen()),
          ),
          const SizedBox(width: 15),
          _buildCarouselCard(
            title: "Spoken English",
            subtitle: "Free Video Course 🎬",
            icon: CupertinoIcons.play_rectangle_fill,
            colors: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
            onTap: () => Get.to(() => const SpokenEnglishScreen()),
          ),
          const SizedBox(width: 15),
          _buildCarouselCard(
            title: "Freelancing",
            subtitle: "Coming Soon 🚀",
            icon: CupertinoIcons.desktopcomputer,
            colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
            onTap: () {}, // Dummy
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard({required String title, required String subtitle, required IconData icon, required List<Color> colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: colors[1].withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. PREFERENCES SECTION ---
  Widget _buildPreferencesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSettingsTile(CupertinoIcons.settings, "Settings & Privacy", Colors.blueGrey),
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200, indent: 50),
          _buildSettingsTile(CupertinoIcons.question_circle_fill, "Help & Support", Colors.teal),
          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200, indent: 50),
          _buildSettingsTile(CupertinoIcons.moon_fill, "Dark Mode", Colors.indigo, isToggle: true),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, Color iconColor, {bool isToggle = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
      trailing: isToggle
          ? CupertinoSwitch(value: false, onChanged: (val) {}, activeColor: Colors.black87)
          : const Icon(CupertinoIcons.chevron_right, size: 18, color: Colors.grey),
      onTap: isToggle ? null : () {},
    );
  }

  // --- 5. LOGOUT BUTTON ---
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White background
          foregroundColor: Colors.redAccent, // Red text/ripple
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1.5) // Subtle red border
          ),
        ),
        onPressed: () {
          Get.defaultDialog(
            title: "Log Out",
            titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
            middleText: "Are you sure you want to leave?",
            middleTextStyle: GoogleFonts.inter(color: Colors.grey.shade700),
            textConfirm: "Yes, Logout",
            textCancel: "Cancel",
            confirmTextColor: Colors.white,
            buttonColor: Colors.redAccent,
            cancelTextColor: Colors.black87,
            radius: 16,
            onConfirm: () => authService.logout(),
          );
        },
        child: Text("Log Out", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}