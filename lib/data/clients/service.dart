import 'dart:convert';
import 'package:http/http.dart' as http; // http প্যাকেজ নাম ঠিক করা হয়েছে
import 'package:get/get.dart' hide Response;
import '../../ui/login_reg_screens/controllers/auth_service.dart';

class networkResponse {
  final bool isSuccess;
  final int statusCode;
  final dynamic data;
  final String? errorMessage;

  networkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.errorMessage,
  });
}

class networkClient {
  // --- হেডার তৈরি (Token + Content Type) ---
  static Map<String, String> _getHeaders() {
    // 1. বেসিক হেডার
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json", // PHP-র জন্য এটি জরুরি
      "Access-Control-Allow-Origin": "*", // ওয়েবের জন্য সেফটি
    };

    // 2. টোকেন যুক্ত করা (যদি থাকে)
    try {
      if (Get.isRegistered<AuthService>()) {
        final AuthService authService = Get.find<AuthService>();
        if (authService.token.value.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${authService.token.value}';
        }
      }
    } catch (e) {
      print("Token Error: $e");
    }
    return headers;
  }

  // --- GET Request ---
  static Future<networkResponse> getRequest({required String url}) async {
    try {
      print("GET Request URL: $url"); // ডিবাগিং এর জন্য
      Uri uri = Uri.parse(url);

      http.Response response = await http.get(uri, headers: _getHeaders());

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return networkResponse(
          isSuccess: true,
          data: decodedJson,
          statusCode: response.statusCode,
        );
      } else {
        return networkResponse(
          isSuccess: false,
          errorMessage: "Failed to load data (Code: ${response.statusCode})",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("Network Error: $e");
      return networkResponse(isSuccess: false, errorMessage: e.toString(), statusCode: -1);
    }
  }

  // --- POST Request ---
  static Future<networkResponse> postRequest({
    required String url,
    required Map<String, dynamic>? body,
  }) async {
    try {
      print("POST Request URL: $url");
      print("Request Body: $body");

      Uri uri = Uri.parse(url);

      http.Response response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return networkResponse(
          isSuccess: true,
          data: decodedJson,
          statusCode: response.statusCode,
        );
      } else {
        // এরর মেসেজ হ্যান্ডলিং
        String msg = "Request Failed";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) msg = decoded['message'];
        } catch (_) {}

        return networkResponse(
            isSuccess: false,
            errorMessage: msg,
            statusCode: response.statusCode
        );
      }
    } catch (e) {
      print("Network Error: $e");
      return networkResponse(isSuccess: false, errorMessage: e.toString(), statusCode: -1);
    }
  }
}