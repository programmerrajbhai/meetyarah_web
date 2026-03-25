import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart'; // ScrollController এর জন্য
import 'package:get/get.dart';
import 'package:meetyarah/data/clients/service.dart';
import 'package:meetyarah/data/utils/urls.dart';
import 'package:meetyarah/ui/home/models/get_post_model.dart';
import '../../login_reg_screens/controllers/auth_service.dart';

class GetPostController extends GetxController {
  var posts = <GetPostModel>[].obs;
  var isLoading = true.obs;          // প্রথমবার লোডিং এর জন্য
  var isMoreDataLoading = false.obs; // নিচে স্ক্রোল করলে প্যাজিনেশন লোডিং এর জন্য
  var hasError = false.obs;
  var errorMessage = ''.obs;

  final AuthService _authService = Get.find<AuthService>();
  final ScrollController scrollController = ScrollController(); // স্ক্রোল ডিটেক্ট করার জন্য

  int currentPage = 1;
  final int limit = 10; // প্রতিবার ১০টি করে পোস্ট আসবে
  bool hasMoreData = true; // ডাটাবেসে আরো পোস্ট আছে কিনা

  @override
  void onInit() {
    super.onInit();
    getAllPost(isRefresh: true);
    _addScrollListener();
  }

  // স্ক্রোল লিসেনার: ইউজার লিস্টের একদম নিচে পৌঁছালে নতুন ডেটা কল করবে
  void _addScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
        // নিচে পৌঁছানোর একটু আগেই ডেটা কল করা শুরু করবে যাতে ইউজার স্মুথ এক্সপেরিয়েন্স পায়
        if (hasMoreData && !isMoreDataLoading.value && !isLoading.value) {
          loadMorePosts();
        }
      }
    });
  }

  // ডেটা লোড করার মেইন ফাংশন
  Future<void> getAllPost({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
        hasMoreData = true;
        isLoading(true);
      } else {
        isMoreDataLoading(true);
      }
      hasError(false);

      String? myUserId = _authService.userId;

      // URL এর সাথে page এবং limit পাঠানো হচ্ছে
      String url = "${Urls.get_all_posts}?page=$currentPage&limit=$limit";

      if (myUserId != null && myUserId.isNotEmpty) {
        url = "$url&user_id=$myUserId";
      }

      print("🔹 Fetching Posts from: $url");

      NetworkResponse response = await NetworkClient.getRequest(url: url);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'success') {
          final List data = response.data['posts'] ?? [];
          List<GetPostModel> fetchedPosts = data.map((e) => GetPostModel.fromJson(e)).toList();

          // যদি limit-এর চেয়ে কম ডেটা আসে বা ডেটা না থাকে, তারমানে আর পোস্ট নেই
          if (fetchedPosts.isEmpty || fetchedPosts.length < limit) {
            hasMoreData = false;
          }

          if (isRefresh) {
            posts.value = fetchedPosts; // রিফ্রেশ হলে লিস্ট রিপ্লেস হবে
          } else {
            posts.addAll(fetchedPosts); // প্যাজিনেশন হলে আগের লিস্টের সাথে অ্যাড হবে
          }

          if (fetchedPosts.isNotEmpty) {
            currentPage++; // পরের পেজের জন্য নাম্বার বাড়িয়ে রাখা হলো
          }
          print("✅ Posts Loaded: ${posts.length}");
        } else {
          hasError(true);
          errorMessage.value = response.data['message'] ?? "No posts found";
        }
      } else {
        hasError(true);
        errorMessage.value = "Failed to load data (Status: ${response.statusCode})";

        if (kIsWeb && response.statusCode == 0) {
          errorMessage.value = "CORS Error or Connection Failed.\nWeb browsers block local IP.";
        }
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      hasError(true);
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading(false);
      isMoreDataLoading(false);
    }
  }

  // প্যাজিনেশনের জন্য আলাদা মেথড
  Future<void> loadMorePosts() async {
    await getAllPost(isRefresh: false);
  }

  // উপর থেকে টান দিয়ে রিফ্রেশ করার জন্য
  Future<void> refreshPosts() async {
    await getAllPost(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose(); // মেমরি লিক থেকে বাঁচতে কন্ট্রোলার ডিসপোজ
    super.onClose();
  }
}