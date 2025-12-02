import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../screens/reel_screens.dart';

// ==========================================
// 1. CONTROLLER (REAL STRIPE PAYMENT)
// ==========================================
class ProfileController extends GetxController {
  var isVip = false.obs;
  var isProcessing = false.obs;

  // 🔴 আপনার Stripe Secret Key এখানে দিন (Stripe Dashboard থেকে)
  // দ্রষ্টব্য: রিয়েল অ্যাপে এটি সার্ভারে (Backend) রাখা উচিত
  final String _secretKey = 'sk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  Future<void> makeRealPayment() async {
    try {
      isProcessing.value = true;

      // ১. পেমেন্ট ইনটেন্ট তৈরি করা (Stripe API কল)
      Map<String, dynamic>? paymentIntent = await _createPaymentIntent('999', 'USD'); // 999 cents = $9.99

      if (paymentIntent == null) throw Exception("Payment Intent creation failed");

      // ২. পেমেন্ট শিট ইনিশিয়ালাইজ করা
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'LaraBook Premium',
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'USD',
            testEnv: true, // লাইভ হলে false করবেন
          ),
        ),
      );

      // ৩. পেমেন্ট শিট ওপেন করা
      await _displayPaymentSheet();

    } catch (e) {
      print("Error: $e");
      Get.snackbar("Failed", "Payment Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _displayPaymentSheet() async {
    try {
      // ইউজার এখানে কার্ড ডিটেইলস দেবে
      await Stripe.instance.presentPaymentSheet();

      // ✅ পেমেন্ট সফল হলে এখানে আসবে
      isVip.value = true;
      Get.back(); // মোডাল বন্ধ

      Get.snackbar(
        "Payment Successful! 💎",
        "Welcome to VIP! All content unlocked.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
      );

    } on StripeException catch (e) {
      if(e.error.code == FailureCode.Canceled) {
        Get.snackbar("Cancelled", "Payment process cancelled", backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Stripe Error: ${e.error.localizedMessage}", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  // Stripe API তে রিকোয়েস্ট পাঠানোর ফাংশন
  Future<Map<String, dynamic>?> _createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('Err creating payment intent: $err');
      return null;
    }
  }
}

// ==========================================
// 2. PROFILE VIEW SCREEN (UI Same as before)
// ==========================================
class ProfileViewScreen extends StatefulWidget {
  final VideoDataModel videoData;
  const ProfileViewScreen({super.key, required this.videoData});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> with TickerProviderStateMixin {
  final ProfileController controller = Get.put(ProfileController());
  late TabController _tabController;
  final Color _accentColor = const Color(0xFFE91E63);
  final Color _verifiedColor = const Color(0xFF1DA1F2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Obx(() => Container(
        height: 550,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.green),
                const SizedBox(width: 10),
                const Text("Secure Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text("Unlock VIP Access to @${widget.videoData.channelName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            const Text("Get full access to exclusive photos & videos.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            _paymentOption("Credit / Debit Card", Icons.credit_card, true),
            _paymentOption("Google Pay", Icons.account_balance_wallet, false),

            const Spacer(),

            // 🔥 REAL PAY BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value ? null : () => controller.makeRealPayment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: controller.isProcessing.value
                    ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text("PAY \$9.99 / MONTH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text("Secure payment by Stripe. Cancel anytime.", style: TextStyle(color: Colors.grey, fontSize: 11))),
          ],
        ),
      )),
    );
  }

  Widget _paymentOption(String name, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? _accentColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? _accentColor.withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? _accentColor : Colors.grey),
          const SizedBox(width: 15),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _accentColor : Colors.black)),
          const Spacer(),
          if (isSelected) Icon(Icons.check_circle, color: _accentColor),
        ],
      ),
    );
  }

  // ... (বাকি UI কোড আগের মতোই থাকবে, যেমন build মেথড, _buildLockedPost ইত্যাদি)
  // আপনি আগের কোড থেকে UI অংশটুকু কপি করে এখানে বসাতে পারেন।

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 340,
                backgroundColor: Colors.white,
                pinned: true,
                leading: IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          "https://images.pexels.com/photos/1386604/pexels-photo-1386604.jpeg?auto=compress&cs=tinysrgb&w=600",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundImage: NetworkImage(widget.videoData.profileImage),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ... বাকি UI কোড আগের উত্তর থেকে হুবহু নিন
              // শুধু সাবস্ক্রাইব বাটনে _showPaymentModal কল করুন
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(widget.videoData.channelName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Obx(() => !controller.isVip.value
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _showPaymentModal,
                          style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                          child: const Text("SUBSCRIBE FOR FREE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                        : const Text("VIP Unlocked ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}