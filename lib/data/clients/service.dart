import 'dart:convert';
import 'package:http/http.dart' as http;
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
  // --- ১. হেডার তৈরি (Token + Content Type) ---
  static Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    };

    // টোকেন যুক্ত করা (যদি থাকে)
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

  // --- ২. GET Request ---
  static Future<networkResponse> getRequest({required String url}) async {
    try {
      print("GET Request URL: $url");
      Uri uri = Uri.parse(url);

      http.Response response = await http.get(uri, headers: _getHeaders());

      print("Status Code: ${response.statusCode}");
      // print("Response Body: ${response.body}"); // বেশি ডাটা হলে ল্যাগ করতে পারে, তাই কমেন্ট আউট করা ভালো

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

  // --- ৩. POST Request (JSON Body) ---
  static Future<networkResponse> postRequest({
    required String url,
    required Map<String, dynamic>? body,
  }) async {
    try {
      print("POST Request URL: $url");
      // print("Request Body: $body");

      Uri uri = Uri.parse(url);

      http.Response response = await http.post(
        uri,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return networkResponse(
          isSuccess: true,
          data: decodedJson,
          statusCode: response.statusCode,
        );
      } else {
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

  // --- ৪. Multipart Request (ছবি আপলোডের জন্য) ---
  static Future<networkResponse> multipartRequest({
    required String url,
    required Map<String, String> fields, // টেক্সট ডাটা (যেমন: নাম, বায়ো)
    required String? imagePath, // গ্যালারি থেকে নেওয়া ছবির পাথ
    required String imageKey,   // API তে ছবির key (যেমন: 'profile_image' বা 'story_image')
  }) async {
    try {
      print("Multipart Request URL: $url");

      Uri uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);

      // হেডার যুক্ত করা (Token সহ)
      request.headers.addAll(_getHeaders());

      // টেক্সট ফিল্ডগুলো যুক্ত করা
      request.fields.addAll(fields);

      // ছবি যুক্ত করা (যদি ছবি থাকে)
      if (imagePath != null && imagePath.isNotEmpty) {
        var multipartFile = await http.MultipartFile.fromPath(imageKey, imagePath);
        request.files.add(multipartFile);
      }

      // সার্ভারে পাঠানো
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

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
        return networkResponse(
          isSuccess: false,
          errorMessage: "Upload Failed. Code: ${response.statusCode}",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("Network Error: $e");
      return networkResponse(isSuccess: false, errorMessage: e.toString(), statusCode: -1);
    }
  }
}