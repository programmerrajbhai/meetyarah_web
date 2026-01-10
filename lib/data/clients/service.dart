import 'dart:convert';
import 'dart:io';
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
    };

    // ✅ Token যুক্ত করা (Safe Check)
    try {
      if (Get.isRegistered<AuthService>()) {
        final AuthService authService = Get.find<AuthService>();
        // নাল চেক সহ টোকেন নেওয়া
        final String token = authService.token.value.toString().trim();
        if (token.isNotEmpty && token != "null") {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      print("Token Error: $e");
    }

    return headers;
  }

  // --- ২. GET Request ---
  static Future<networkResponse> getRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      print("GET Request URL: $url");
      Uri uri = Uri.parse(url);

      // ✅ Merge headers
      final mergedHeaders = {..._getHeaders(), ...(headers ?? {})};

      final http.Response response = await http.get(uri, headers: mergedHeaders);

      print("Status Code: ${response.statusCode}");
      // print("Response: ${response.body}"); // দরকার হলে ডিবাগিং এর জন্য আনকমেন্ট করুন

      return _handleResponse(response);
    } catch (e) {
      print("Network Error: $e");
      return networkResponse(
        isSuccess: false,
        errorMessage: "Connection Error: $e",
        statusCode: -1,
      );
    }
  }

  // --- ৩. POST Request (JSON Body) ---
  static Future<networkResponse> postRequest({
    required String url,
    required Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      print("POST Request URL: $url");
      Uri uri = Uri.parse(url);

      // ✅ Merge headers
      final mergedHeaders = {..._getHeaders(), ...(headers ?? {})};

      final http.Response response = await http.post(
        uri,
        headers: mergedHeaders,
        body: jsonEncode(body),
      );

      print("Status Code: ${response.statusCode}");

      return _handleResponse(response);
    } catch (e) {
      print("Network Error: $e");
      return networkResponse(
        isSuccess: false,
        errorMessage: "Connection Error: $e",
        statusCode: -1,
      );
    }
  }

  // --- ৪. Multipart Request (ছবি আপলোডের জন্য - 🔥 FIXED) ---
  static Future<networkResponse> multipartRequest({
    required String url,
    required Map<String, String> fields,
    required String? imagePath,
    required String imageKey,
  }) async {
    try {
      print("Multipart Request URL: $url");
      Uri uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);

      // 🔥 [CRITICAL FIX]
      // সাধারণ রিকোয়েস্টে Content-Type: application/json থাকে।
      // কিন্তু ছবি আপলোডের সময় এটা থাকলে সার্ভার ফাইল রিড করতে পারে না।
      // তাই আমরা 헤ডার কপি করে Content-Type রিমুভ করে দিচ্ছি।
      Map<String, String> headers = Map.from(_getHeaders());
      headers.remove("Content-Type");

      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (imagePath != null && imagePath.isNotEmpty) {
        // ফাইলটি আছে কি না চেক করে নেওয়া ভালো
        File file = File(imagePath);
        if (await file.exists()) {
          var multipartFile = await http.MultipartFile.fromPath(imageKey, imagePath);
          request.files.add(multipartFile);
        } else {
          print("File does not exist at path: $imagePath");
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");

      return _handleResponse(response);
    } catch (e) {
      print("Network Error: $e");
      return networkResponse(
        isSuccess: false,
        errorMessage: "Upload Error: $e",
        statusCode: -1,
      );
    }
  }

  // --- ৫. কমন রেসপন্স হ্যান্ডলার (Code Reuse) ---
  static networkResponse _handleResponse(http.Response response) {
    try {
      // ✅ 200 এবং 201 দুটোই সাকসেস হিসেবে ধরা হয়
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedJson = jsonDecode(response.body);
        return networkResponse(
          isSuccess: true,
          data: decodedJson,
          statusCode: response.statusCode,
        );
      } else {
        // এরর হ্যান্ডলিং
        String msg = "Request failed (Code: ${response.statusCode})";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            msg = decoded['message'];
          } else if (decoded['error'] != null) {
            msg = decoded['error'];
          }
        } catch (_) {
          // JSON না হলে ডিফল্ট মেসেজ থাকবে
        }

        return networkResponse(
          isSuccess: false,
          errorMessage: msg,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // যদি সার্ভার 200 দেয় কিন্তু Valid JSON না দেয় (যেমন HTML Error Page)
      return networkResponse(
        isSuccess: false,
        errorMessage: "Invalid Response Format: $e",
        statusCode: response.statusCode,
      );
    }
  }
}