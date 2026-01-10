import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response;
import 'package:image_picker/image_picker.dart';
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
  // ---------------- HEADERS ----------------
  static Map<String, String> _getHeaders() {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    try {
      if (Get.isRegistered<AuthService>()) {
        final token = Get.find<AuthService>().token.value.toString().trim();
        if (token.isNotEmpty && token != "null") {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {}

    return headers;
  }

  // ---------------- GET ----------------
  static Future<networkResponse> getRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {..._getHeaders(), ...(headers ?? {})},
      );
      return _handleResponse(response);
    } catch (e) {
      return networkResponse(
        isSuccess: false,
        errorMessage: e.toString(),
        statusCode: -1,
      );
    }
  }

  // ---------------- POST ----------------
  static Future<networkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {..._getHeaders(), ...(headers ?? {})},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return networkResponse(
        isSuccess: false,
        errorMessage: e.toString(),
        statusCode: -1,
      );
    }
  }

  // ---------------- MULTIPART (FIXED) ----------------
  static Future<networkResponse> multipartRequest({
    required String url,
    required Map<String, String> fields,

    /// ✅ NEW (Web + Mobile)
    XFile? imageFile,

    /// ✅ OLD SUPPORT (won’t break old code)
    String? imagePath,

    required String imageKey,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      final headers = Map<String, String>.from(_getHeaders());
      headers.remove("Content-Type"); // multipart fix
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      // ✅ Convert old imagePath → XFile
      if (imageFile == null && imagePath != null && imagePath.isNotEmpty) {
        imageFile = XFile(imagePath);
      }

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            imageKey,
            bytes,
            filename: imageFile.name,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      return networkResponse(
        isSuccess: false,
        errorMessage: e.toString(),
        statusCode: -1,
      );
    }
  }

  // ---------------- RESPONSE HANDLER ----------------
  static networkResponse _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return networkResponse(
          isSuccess: true,
          data: data,
          statusCode: response.statusCode,
        );
      }
      return networkResponse(
        isSuccess: false,
        errorMessage: data['message'] ?? "Request failed",
        statusCode: response.statusCode,
      );
    } catch (_) {
      return networkResponse(
        isSuccess: false,
        errorMessage: "Invalid server response",
        statusCode: response.statusCode,
      );
    }
  }
}
