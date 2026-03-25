import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/education/screens/education_screen.dart';
import 'package:meetyarah/ui/profile/screens/profile_screens.dart';

import '../../login_reg_screens/controllers/auth_service.dart';
import '../../profile/controllers/profile_controllers.dart';
// ✅ ফিক্সড: নতুন স্ক্রিনটি ইমপোর্ট করা হলো
import '../../spoken_english/screens/spoken_english_screen.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({Key? key}) : super(key: key);

  final AuthService authService = Get.find<AuthService>();
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Ultra Light Blue-Grey Background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Top Bar & Title ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Menu",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1D1E),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.black87),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 25),

                // --- 2. Modern Profile Card ---
                _buildModernProfileCard(),

                const SizedBox(height: 30),

                // --- 3. Education & Career (Hero Section) ---
                Text("Learning Hub 🚀", style: _sectionTitleStyle()),
                const SizedBox(height: 15),
                _buildEducationHeroCard(),

                const SizedBox(height: 15),

                // ✅ ফিক্সড: নতুন Spoken English Card যুক্ত করা হলো
                _buildSpokenEnglishCard(),

                const SizedBox(height: 30),

                // --- 4. Quick Actions (Social & Fun) ---
                Text("Explore", style: _sectionTitleStyle()),
                const SizedBox(height: 15),
                _buildModernGrid(),

                const SizedBox(height: 30),

                // --- 5. Settings & More ---
                Text("Preferences", style: _sectionTitleStyle()),
                const SizedBox(height: 15),
                _buildModernSettingsTile(Icons.settings_outlined, "Settings & Privacy", Colors.blue),
                _buildModernSettingsTile(Icons.help_outline_rounded, "Help & Support", Colors.purple),
                _buildModernSettingsTile(Icons.shield_outlined, "Safety & Terms", Colors.orange),

                const SizedBox(height: 30),

                // --- 6. Logout Button ---
                _buildLogoutButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- STYLES ---
  TextStyle _sectionTitleStyle() => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.grey[800],
  );

  // --- WIDGETS ---

  // 1. Modern Profile Card
  Widget _buildModernProfileCard() {
    return Obx(() {
      final user = controller.profileUser.value;
      return GestureDetector(
        onTap: () => Get.to(() => const ProfilePage()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                        user?.profilePictureUrl ?? "https://i.pravatar.cc/150?img=12"
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? "Loading...",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "View Profile",
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
            ],
          ),
        ),
      );
    });
  }

  // 2. Education Hero Card
  Widget _buildEducationHeroCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const EducationScreen()),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2575FC).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.school, size: 120, color: Colors.white.withOpacity(0.15)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Education Hub",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "SSC • HSC • Job Prep",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 3. NEW: Spoken English Video Course Card
  Widget _buildSpokenEnglishCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const SpokenEnglishScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)], // Warm Red to Orange
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Spoken English",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Free Video Course 🎬",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  // 4. Modern Grid for Social/Games
  Widget _buildModernGrid() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.group_rounded, 'label': 'Community', 'color': Colors.blueAccent},
      {'icon': Icons.play_circle_fill_rounded, 'label': 'Videos', 'color': Colors.redAccent},
      {'icon': Icons.gamepad_rounded, 'label': 'Games', 'color': Colors.deepPurpleAccent},
      {'icon': Icons.storefront_rounded, 'label': 'Market', 'color': Colors.teal},
      {'icon': Icons.bookmark_rounded, 'label': 'Saved', 'color': Colors.amber},
      {'icon': Icons.event_note_rounded, 'label': 'Events', 'color': Colors.pinkAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item['label'],
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 5. Modern Settings Tile
  Widget _buildModernSettingsTile(IconData icon, String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  // 6. Gen Z Style Logout Button
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFECEC),
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          Get.defaultDialog(
            title: "Hold on!",
            titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            middleText: "Are you sure you want to log out?",
            textConfirm: "Yes, Logout",
            textCancel: "Cancel",
            confirmTextColor: Colors.white,
            buttonColor: Colors.red,
            radius: 16,
            onConfirm: () {
              authService.logout();
            },
          );
        },
        child: Text(
          "Log Out",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}