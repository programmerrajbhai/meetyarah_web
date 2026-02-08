import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/ui/education/screens/subject_selection_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100, right: -50,
            child: _buildBlurCircle(300, const Color(0xFF6C63FF).withOpacity(0.15)),
          ),
          Positioned(
            bottom: 100, left: -50,
            child: _buildBlurCircle(250, const Color(0xFFFF6584).withOpacity(0.12)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernHeader(),
                  const SizedBox(height: 25),
                  _buildGlassSearchBar(),
                  const SizedBox(height: 30),
                  _buildHeroBanner(),
                  const SizedBox(height: 35),

                  _buildSectionHeader("Academic Zone 📚", "School & College"),
                  const SizedBox(height: 15),
                  _buildGridMenu(context, [
                    {'t': 'SSC', 's': 'Class 9-10', 'icon': '📘', 'c1': 0xFF4facfe, 'c2': 0xFF00f2fe},
                    {'t': 'HSC', 's': 'College', 'icon': '🎓', 'c1': 0xFFa18cd1, 'c2': 0xFFfbc2eb},
                    {'t': 'Diploma', 's': 'Polytechnic', 'icon': '⚙️', 'c1': 0xFFff9a9e, 'c2': 0xFFfecfef},
                    {'t': 'Honours', 's': 'Varsity', 'icon': '🏛️', 'c1': 0xFF84fab0, 'c2': 0xFF8fd3f4},
                  ]),

                  const SizedBox(height: 35),

                  _buildSectionHeader("Dream Career 🚀", "Govt & Private Jobs"),
                  const SizedBox(height: 15),
                  _buildGridMenu(context, [
                    {'t': 'BCS Prep', 's': 'Civil Service', 'icon': '🇧🇩', 'c1': 0xFF00c6fb, 'c2': 0xFF005bea},
                    {'t': 'Medical', 's': 'Admission', 'icon': '🩺', 'c1': 0xFFeb3349, 'c2': 0xFFf45c43},
                    {'t': 'Job Prep', 's': 'Bank/Govt', 'icon': '💼', 'c1': 0xFF43e97b, 'c2': 0xFF38f9d7},
                    {'t': 'Viva', 's': 'Interview', 'icon': '🎤', 'c1': 0xFFfa709a, 'c2': 0xFFfee140},
                  ]),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Bottom Sheet Selector ---
  void _showSubCategorySheet(BuildContext context, String category, Color themeColor) {
    List<Map<String, dynamic>> subCategories = [];

    if (category == 'SSC') {
      subCategories = [
        {'title': 'Science', 'icon': Icons.science, 'color': Colors.blue},
        {'title': 'Business', 'icon': Icons.pie_chart, 'color': Colors.green},
        {'title': 'Humanities', 'icon': Icons.history_edu, 'color': Colors.orange},
      ];
    } else if (category == 'HSC') {
      subCategories = [
        {'title': 'Science', 'icon': Icons.science_outlined, 'color': Colors.purple},
        {'title': 'Commerce', 'icon': Icons.bar_chart, 'color': Colors.teal},
        {'title': 'Arts', 'icon': Icons.menu_book, 'color': Colors.deepOrange},
      ];
    } else {
      Get.to(() => SubjectSelectionScreen(className: category, subCategory: "General", themeColor: themeColor));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("Select Department", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.3,
                  ),
                  itemCount: subCategories.length,
                  itemBuilder: (context, index) {
                    final item = subCategories[index];
                    return InkWell(
                      onTap: () {
                        Get.back();
                        Get.to(() => SubjectSelectionScreen(
                          className: category, subCategory: item['title'], themeColor: item['color'],
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: (item['color'] as Color).withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'], color: item['color'], size: 30),
                            const SizedBox(height: 10),
                            Text(item['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Helper Widgets (Same as before)
  Widget _buildBlurCircle(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  
  Widget _buildModernHeader() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    InkWell(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios_new_rounded)),
    Text("Education Hub", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
    const CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12")),
  ]);

  Widget _buildGlassSearchBar() => Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const TextField(decoration: InputDecoration(border: InputBorder.none, hintText: "Search...", icon: Icon(Icons.search))));

  Widget _buildHeroBanner() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]), borderRadius: BorderRadius.circular(24)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("🔥 LIVE EXAM", style: TextStyle(color: Colors.white, fontSize: 10)),
        Text("Daily Quiz Challenge", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ])),
      const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
    ]),
  );

  Widget _buildSectionHeader(String t, String s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)), Text(s, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))]);

  Widget _buildGridMenu(BuildContext context, List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => _showSubCategorySheet(context, item['t'], Color(item['c2'])),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item['icon'], style: const TextStyle(fontSize: 24)),
              Text(item['t'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ]),
          ),
        );
      },
    );
  }
}