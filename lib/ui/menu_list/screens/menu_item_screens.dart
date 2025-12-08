import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:meetyarah/ui/profile/screens/profile_screens.dart';
import '../../login_reg_screens/controllers/auth_service.dart';
import '../../profile/controllers/profile_controllers.dart';

class MenuScreen extends StatelessWidget {


   MenuScreen({Key? key}) : super(key: key);
   final AuthService authService = Get.find<AuthService>();
   // কন্ট্রোলার লোড করি
   final ProfileController controller = Get.put(ProfileController());

   @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          // --- সেকশন ১: প্রোফাইল কার্ড ---
         _buildProfileCard(
              context,
           controller.profileUser.value?.fullName ?? "Loading...",
           'See your profile', // সাবটাইটেল
           controller.profileUser.value?.profilePictureUrl ?? "Loading...",
         ),
          const SizedBox(height: 12),

          // --- সেকশন ২: শর্টকাট গ্রিড ---
          _buildShortcutGrid(context),
          const SizedBox(height: 12),

          // --- সেকশন ৩: সেটিংস মেনু লিস্ট ---
          _buildMenuList(context),
          const SizedBox(height: 12),

          // --- সেকশন ৪: লগআউট বাটন ---
          _buildLogoutButton(context),
        ],
      ),
    );
  }


  Widget _buildProfileCard(
      BuildContext context, String name, String subtitle, String imageUrl) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.to(ProfilePage());
        },
      ),
    );
  }


  Widget _buildShortcutGrid(BuildContext context) {
    // ডেমো শর্টকাট আইটেম
    final List<Map<String, dynamic>> shortcuts = [
      {'icon': Icons.group, 'label': 'Groups', 'color': Colors.blue},
      {'icon': Icons.storefront, 'label': 'Marketplace', 'color': Colors.green},
      {'icon': Icons.ondemand_video, 'label': 'Watch', 'color': Colors.red},
      {'icon': Icons.people, 'label': 'Friends', 'color': Colors.lightBlue},
      {'icon': Icons.history, 'label': 'Memories', 'color': Colors.purple},
      {'icon': Icons.bookmark, 'label': 'Saved', 'color': Colors.deepOrange},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // প্রতি সারিতে ২টি
            childAspectRatio: 2.5, // আইটেমগুলোর উচ্চতা
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: shortcuts.length,
          shrinkWrap: true, // ListView-এর ভিতরে GridView ব্যবহারের জন্য
          physics: const NeverScrollableScrollPhysics(), // ListView-এর স্ক্রল ব্যবহার করবে
          itemBuilder: (context, index) {
            final item = shortcuts[index];
            return _buildShortcutItem(item['icon'], item['label'], item['color']);
          },
        ),
      ),
    );
  }

  // একটি শর্টকাট আইটেমের ডিজাইন
  Widget _buildShortcutItem(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  /// 3. সেটিংস মেনু লিস্ট উইজেট
  Widget _buildMenuList(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias, // ListTile এর কোনাগুলো কার্ডের সাথে মেলানোর জন্য
      child: Column(
        children: [
          _buildMenuListItem(
            context,
            icon: Icons.settings,
            text: 'Settings & Privacy',
            onTap: () {},
          ),
          _buildMenuListItem(
            context,
            icon: Icons.help_outline,
            text: 'Help & Support',
            onTap: () {},
          ),
          _buildMenuListItem(
            context,
            icon: Icons.info_outline,
            text: 'About',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // একটি মেনু লিস্ট আইটেমের ডিজাইন
  Widget _buildMenuListItem(BuildContext context,
      {required IconData icon,
        required String text,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// 4. লগআউট বাটন উইজেট
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          authService.logout();
        },
        child: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}