class Urls {
  // আপনার পিসির আইপি
  static const String _rootUrl = "http://192.168.1.112/api";

  static String loginApi = "$_rootUrl/login.php";
  static String registerApi = "$_rootUrl/register.php";
  static String get_all_posts = "$_rootUrl/get_all_posts.php";

  static String get getCommentsApi => "$_rootUrl/get_comments.php";
  static String get addCommentApi => "$_rootUrl/add_comment.php";
  static String get getUserProfileApi => "$_rootUrl/get_user_profile.php";

  static String get createPostApi => "$_rootUrl/create_post.php";
  static String get uploadImageApi => "$_rootUrl/upload_image.php";

  static String get likePostApi => "$_rootUrl/like_post.php";
}
