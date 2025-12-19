import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/image_url.dart'; // আপনার ইমেজের পাথ
import '../../../logo_widget.dart';
import '../controllers/splash_controllers.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার কানেক্ট করা হলো
    Get.put(SplashController());

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ব্যবহার করার উদাহরণ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MeetyarahLogo(size: 120), // লোগো উইজেট
                  SizedBox(height: 20),
                  Text(
                    "Meetyarah",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}