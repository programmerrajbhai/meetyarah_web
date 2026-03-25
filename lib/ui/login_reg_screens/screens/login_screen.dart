import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetyarah/assetsPath/image_url.dart';
import 'package:meetyarah/assetsPath/textColors.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/loginController.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/forget_screen.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/reg_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());
    final size = MediaQuery.of(context).size;
    bool isWebDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // --- LEFT SIDE: HERO IMAGE (Only for Desktop/Web) ---
          if (isWebDesktop)
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1516054575922-f0b8eeadec1a?q=80&w=2070&auto=format&fit=crop"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPath.deepBlue.withOpacity(0.9),
                        Colors.black.withOpacity(0.3),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Discover\nReal Connections.",
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Join millions of people finding their perfect match and building meaningful relationships every day.",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

          // --- RIGHT SIDE: LOGIN FORM ---
          Expanded(
            flex: isWebDesktop ? 4 : 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isWebDesktop) ...[
                      Image.asset(
                        ImagePath.appLogotransparent,
                        height: 80,
                      ),
                      const SizedBox(height: 30),
                    ],

                    Text(
                      "Welcome Back! 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: isWebDesktop ? TextAlign.start : TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please enter your details to sign in.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: isWebDesktop ? TextAlign.start : TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // EMAIL FIELD
                    _buildLabel("Email or Phone"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: loginController.emailOrPhoneCtrl,
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    _buildLabel("Password"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: loginController.passwordCtrl,
                      hint: "Enter your password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      onSubmitted: (_) => loginController.loginUser(), // FIXED HERE
                    ),

                    // FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.to(() => const ForgotScreens()),
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.inter(
                            color: ColorPath.deepBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // LOGIN BUTTON
                    Obx(() => SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loginController.isLoading.value
                            ? null
                            : () => loginController.loginUser(), // FIXED HERE
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPath.deepBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: loginController.isLoading.value
                            ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : Text(
                          "Log In",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 20),

                    // DIVIDER
                    Row(children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ]),
                    const SizedBox(height: 20),

                    // --- GUEST BUTTON ---
                    Obx(() => SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: loginController.isGuestLoading.value
                            ? null
                            : () => loginController.loginAsGuest(),
                        icon: const Icon(Icons.travel_explore, size: 20),
                        label: Text(
                          loginController.isGuestLoading.value ? "Processing..." : "Continue as Guest",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 40),

                    // SIGN UP LINK
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: GoogleFonts.inter(
                                color: ColorPath.deepBlue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Get.to(() => const RegistrationScreens()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  // Helper Widget for TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPath.deepBlue, width: 1.5),
        ),
      ),
    );
  }
}