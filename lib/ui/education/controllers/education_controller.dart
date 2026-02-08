import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EducationController extends GetxController {
  // ✅ ei URL ta apnar education folder e point korbe
  final String eduBaseUrl = "https://yourdomain.com/education_api/api.php"; 
  
  var categories = [].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchEducationData();
    super.onInit();
  }

  void fetchEducationData() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse("$eduBaseUrl?action=get_all_data"));
      
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if(json['status'] == 'success') {
          categories.value = json['data'];
        }
      }
    } catch (e) {
      print("Edu API Error: $e");
    } finally {
      isLoading(false);
    }
  }
}