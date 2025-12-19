import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/create_post/screens/create_post.dart';
import 'package:meetyarah/ui/dashboard/screens/dashboard_screens.dart';
import 'package:meetyarah/ui/home/screens/feed_screen.dart' hide ReelScreens;
import 'package:meetyarah/ui/menu_list/screens/menu_item_screens.dart';
import 'package:meetyarah/ui/profile/screens/profile_screens.dart';
import '../../reels/screens/reel_screens.dart';
// ✅ লোগো ইমপোর্ট করা হলো
import '../../../logo_widget.dart';

class Basescreens extends StatefulWidget {
  const Basescreens({super.key});

  @override
  State<Basescreens> createState() => _BasescreensState();
}

class _BasescreensState extends State<Basescreens> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    const FeedScreen(),
    const ReelScreens(),
    const SizedBox(), // ✅ Create Post এখন আলাদা ওপেন হবে, তাই এখানে খালি রাখা হলো
    const ActivityDashboardScreens(),
    MenuScreen(),
  ];

  void _onItemTapped(int index) {
    // ✅ ফিক্স: ৩ নম্বর বাটন (Create) ক্লিক করলে ট্যাব চেঞ্জ না করে নতুন পেজ ওপেন হবে
    if (index == 2) {
      Get.to(
            () => const CreatePostScreen(),
        transition: Transition.downToUp, // সুন্দর নিচ থেকে উপরে আসার অ্যানিমেশন
        duration: const Duration(milliseconds: 300),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isWebDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: isWebDesktop ? 30 : 20,
        // ✅ লোগো এবং টেক্সট একসাথে দেখানোর জন্য Row ব্যবহার করা হয়েছে
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ আপনার কাস্টম লোগো (ছোট সাইজে)
            const MeetyarahLogo(size: 40, animate: true),
            const SizedBox(width: 12),
            // ✅ ব্র্যান্ড নেম আপডেট
            Text(
              "Meetyarah",
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: ColorPath.deepBlue,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          _buildActionButton(Icons.search_rounded, () {}),
          const SizedBox(width: 10),
          _buildActionButton(Icons.forum_rounded, () {}, isNotification: true),
          SizedBox(width: isWebDesktop ? 30 : 15),
        ],
      ),

      body: isWebDesktop
          ? _buildWebLayout()
          : IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: isWebDesktop
          ? null
          : Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)
            )
          ],
        ),
        child: BottomNavigationBar(
          items: _getNavItems(),
          currentIndex: _selectedIndex,
          selectedItemColor: ColorPath.deepBlue,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 26,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          labelType: NavigationRailLabelType.all,
          backgroundColor: Colors.white,
          groupAlignment: -1.0,
          indicatorColor: ColorPath.deepBlue.withOpacity(0.1),
          selectedIconTheme: const IconThemeData(color: ColorPath.deepBlue),
          unselectedIconTheme: const IconThemeData(color: Colors.grey),
          unselectedLabelTextStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          selectedLabelTextStyle: GoogleFonts.inter(color: ColorPath.deepBlue, fontWeight: FontWeight.bold, fontSize: 12),
          destinations: _getNavRailDestinations(),
        ),
        VerticalDivider(thickness: 1, width: 1, color: Colors.grey.shade200),
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),
        ),
        if(MediaQuery.of(context).size.width > 1200)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Center(
              child: Text(
                "Suggestions / Ads",
                style: GoogleFonts.inter(color: Colors.grey[400]),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isNotification = false}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: IconButton(icon: Icon(icon, color: Colors.black87, size: 22), onPressed: onTap, splashRadius: 20),
        ),
        if (isNotification)
          Positioned(right: 6, top: 10, child: Container(height: 9, width: 9, decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
      ],
    );
  }

  List<BottomNavigationBarItem> _getNavItems() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.style_outlined), activeIcon: Icon(Icons.style), label: "Feed"),
      const BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle_fill), label: "Reels"),
      BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [ColorPath.deepBlue, Colors.purpleAccent]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: ColorPath.deepBlue.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))]
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        label: "Create",
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
      const BottomNavigationBarItem(icon: Icon(Icons.menu), activeIcon: Icon(Icons.menu_open), label: "Menu"),
    ];
  }

  List<NavigationRailDestination> _getNavRailDestinations() {
    return [
      const NavigationRailDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: Text("Feed")),
      const NavigationRailDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle_fill), label: Text("Reels")),
      const NavigationRailDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: Text("Create")),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text("Profile")),
      const NavigationRailDestination(icon: Icon(Icons.menu), selectedIcon: Icon(Icons.menu_open), label: Text("Menu")),
    ];
  }
}