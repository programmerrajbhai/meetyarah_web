
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class PaymentController extends GetxController {
  // 🔴 IMPORTANT: আপনার Stripe ড্যাশবোর্ড থেকে এই Key গুলো নিন
  // টেস্টিং এর জন্য 'sk_test_...' এবং 'pk_test_...' ব্যবহার করবেন
  String secretKey = 'sk_test_YOUR_SECRET_KEY_HERE';
  String publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';

  Map<String, dynamic>? paymentIntent;

  @override
  void onInit() {
    super.onInit();
    Stripe.publishableKey = publishableKey;
  }

  // ১. পেমেন্ট প্রক্রিয়া শুরু করা
  Future<void> makePayment({required String amount, required String currency}) async {
    try {
      // পেমেন্ট ইনটেন্ট তৈরি (Backend Call Simulation)
      paymentIntent = await createPaymentIntent(amount, currency);

      // পেমেন্ট শিট সেটআপ
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Lara Rose VIP', // আপনার অ্যাপের নাম
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'USD',
            testEnv: true,
          ),
        ),
      );

      // পেমেন্ট শিট দেখানো
      displayPaymentSheet();

    } catch (e) {
      Get.snackbar("Error", "Payment Initialization Failed: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // ২. পেমেন্ট উইন্ডো দেখানো
  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // ✅ পেমেন্ট সফল হলে এখানে আসবে
      Get.snackbar("Success!", "Payment Successful. VIP Unlocked!",
          backgroundColor: Colors.green, colorText: Colors.white, icon: Icon(Icons.check_circle, color: Colors.white));

      paymentIntent = null;

    } on StripeException catch (e) {
      Get.snackbar("Cancelled", "Payment Cancelled", backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Payment Failed: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ৩. পেমেন্ট ইনটেন্ট API কল (এটি সাধারণত ব্যাকএন্ডে থাকে)
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount), // Stripe পয়সায় হিসাব করে (Cents)
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  // টাকার পরিমাণকে Cents এ কনভার্ট করা ($10.00 -> 1000 cents)
  String calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount) * 100);
    return calculatedAmount.toString();
  }
}