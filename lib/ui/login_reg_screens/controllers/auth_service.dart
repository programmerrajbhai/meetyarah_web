import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meetyarah/ui/login_reg_screens/model/user_model.dart';
import 'package:meetyarah/ui/login_reg_screens/screens/login_screen.dart';

class AuthService extends GetxService {
  late SharedPreferences _prefs;
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxString token = ''.obs;

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserSession();
    return this;
  }

  Future<void> saveUserSession(String userToken, Map<String, dynamic> userMap) async {
    await _prefs.setString('token', userToken);
    UserModel loggedInUser = UserModel.fromJson(userMap);
    await _prefs.setString('user_data', jsonEncode(loggedInUser.toJson()));

    token.value = userToken;
    user.value = loggedInUser;
  }

  Future<void> _loadUserSession() async {
    final String? savedToken = _prefs.getString('token');
    final String? savedUserData = _prefs.getString('user_data');

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
    }
    if (savedUserData != null && savedUserData.isNotEmpty) {
      try {
        user.value = UserModel.fromJson(jsonDecode(savedUserData));
      } catch (e) {
        print("Error loading user: $e");
      }
    }
  }

  Future<void> logout() async {
    await _prefs.clear();
    token.value = '';
    user.value = null;
    Get.offAll(() => const LoginScreen());
  }

  bool get isLoggedIn => token.value.isNotEmpty;
// ✅ এই Getter টি অ্যাড করুন
  String? get userId => user.value?.user_id;
}