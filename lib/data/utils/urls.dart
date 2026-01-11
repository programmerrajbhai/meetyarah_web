class Urls {
  static const String _rootUrl = "https://meetyarah.com/api";

  static String loginApi = "$_rootUrl/login.php";
  static String registerApi = "$_rootUrl/register.php";
  static String get_all_posts = "$_rootUrl/get_all_posts.php";

  static String googleLoginApi = "$_rootUrl/google_login.php";
  static String get getCommentsApi => "$_rootUrl/get_comments.php";
  static String get addCommentApi => "$_rootUrl/add_comment.php";
  static String get getUserProfileApi => "$_rootUrl/get_user_profile.php";

  static String get createPostApi => "$_rootUrl/create_post.php";
  static String get uploadImageApi => "$_rootUrl/upload_image.php";
  static String get likePostApi => "$_rootUrl/like_post.php";

  // --- 🔥 নতুন API গুলো (New Added) ---
  static String get searchUsersApi => "$_rootUrl/global_search.php";
  static String get followUserApi => "$_rootUrl/follow_user.php";
  static String get unfollowUserApi => "$_rootUrl/unfollow_user.php";
  static String get getNotificationsApi => "$_rootUrl/get_notifications.php";


  static String get updateProfileApi => "$_rootUrl/update_profile.php";


  static String get uploadStoryApi => "$_rootUrl/upload_story.php";
  static String get getActiveStoriesApi => "$_rootUrl/get_active_stories.php";
  static String get getSinglePostApi => "$_rootUrl/get_single_post.php";

  static String get uploadStoryTextApi => "$_rootUrl/upload_story_text.php";


  static String get blockUserApi => "$_rootUrl/block_user.php";
  static String get unblockUserApi => "$_rootUrl/unblock_user.php";
  static String get getBlockedUsersApi => "$_rootUrl/get_blocked_users.php";



}
