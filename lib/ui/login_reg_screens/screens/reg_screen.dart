import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetyarah/assetsPath/image_url.dart';
import 'package:meetyarah/ui/login_reg_screens/controllers/registrationController.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/login_screen.dart';

import '../../../assetsPath/textColors.dart';
import '../widgets/Textfromfield.dart';
import '../widgets/containnerBox.dart';

class RegistrationScreens extends StatefulWidget {
  const RegistrationScreens({super.key});

  @override
  State<RegistrationScreens> createState() => _RegistrationScreensState();
}

class _RegistrationScreensState extends State<RegistrationScreens> {
  final _regcontroller = Get.put(RegistrationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                ImagePath.appLogotransparent,
                height: Get.height * 0.38,
                width: Get.width * 1,
              ),
              textfromfield(
                icon: Icons.account_box,
                text: 'First Name',
                controller: _regcontroller.firstnameCtrl,
              ),
              SizedBox(height: 8),
              textfromfield(
                icon: Icons.account_box,
                text: 'Last Name',
                controller: _regcontroller.lastnameCtrl,
              ),
              SizedBox(height: 8),
              textfromfield(
                icon: Icons.email,
                text: 'Email Address',
                controller: _regcontroller.emailCtrl,
              ),
              SizedBox(height: 8),
              textfromfield(
                icon: Icons.lock,
                text: 'f1q aPassword',
                controller: _regcontroller.passwordCtrl,
              ),
              SizedBox(height: 8),

              SizedBox(height: 16),
              containnerBox(
                onTap: () {
                  _regcontroller.RegisterUser();
                },
                bgColors: ColorPath.deepBlue,
                text: "Registration",
                textColors: Colors.white,
              ),
              SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10.0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              containnerBox(
                bgColors: Colors.white,
                text: 'Sign up by google',
                prefixIcons: ImagePath.gogoleIcon,
                textColors: Colors.black,
              ),
              SizedBox(height: 40),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(LoginScreen());
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
