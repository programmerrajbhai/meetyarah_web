import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart'; // kIsWeb এর জন্য
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/image_url.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/loginController.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/forget_screen.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/reg_screen.dart';
import '../widgets/Textfromfield.dart';
import '../widgets/containnerBox.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // কন্ট্রোলার ইনিশিয়ালাইজ
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    // রেসপন্সিভ সাইজ হ্যান্ডেলিং
    final size = MediaQuery.of(context).size;
    final bool isDesktop = kIsWeb || size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      // কীবোর্ড হাইড করার জন্য GestureDetector
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                // বড় স্ক্রিনে সর্বোচ্চ ৫০০ পিক্সেল চওড়া হবে
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // লোগো
                    Image.asset(
                      ImagePath.appLogotransparent,
                      width: isDesktop ? 200 : Get.width * 0.6,
                      height: isDesktop ? 150 : Get.height * 0.25,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),

                    // ইনপুট ফিল্ডস
                    textfromfield(
                      icon: Icons.account_box,
                      text: 'Email or Phone Number',
                      controller: loginController.emailOrPhoneCtrl,
                    ),
                    const SizedBox(height: 16),

                    // পাসওয়ার্ড ফিল্ড (Enter চাপলে লগইন হবে)
                    TextFormField(
                      controller: loginController.passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onFieldSubmitted: (value) => loginController.LoginUser(),
                    ),

                    // ফরগট পাসওয়ার্ড
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => const ForgotScreens());
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: ColorPath.deepBlue, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // লগইন বাটন (লোডিং ইন্ডিকেটর সহ)
                    Obx(() {
                      return loginController.isLoading.value
                          ? const CircularProgressIndicator(color: ColorPath.deepBlue)
                          : InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus(); // কীবোর্ড নামানো
                          loginController.LoginUser();
                        },
                        child: const containnerBox(
                          bgColors: ColorPath.deepBlue,
                          text: "LOGIN",
                          textColors: Colors.white,
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // OR ডিভাইডার
                    Row(
                      children: <Widget>[
                        Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('or', style: TextStyle(color: Colors.grey[600])),
                        ),
                        Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // গুগল সাইন ইন
                    containnerBox(
                      bgColors: Colors.grey.shade100, // একটু শেড দেওয়া হয়েছে দেখার সুবিধার জন্য
                      text: 'Sign in by Google',
                      prefixIcons: ImagePath.gogoleIcon,
                      textColors: Colors.black87,
                    ),
                    const SizedBox(height: 40),

                    // সাইন আপ লিংক
                    RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => const RegistrationScreens());
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}