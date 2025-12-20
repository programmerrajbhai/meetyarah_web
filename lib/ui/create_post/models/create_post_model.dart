class GetPostModel {
  String? post_id;
  String? post_content;
  String? image_url;
  String? created_at;
  int? user_id;
  String? username;
  String? full_name;
  String? profile_picture_url;
  int like_count;
  int comment_count;
  bool isLiked;

  // ✅ Direct Link ফিল্ড রিমুভ করা হয়েছে
  GetPostModel({
    this.post_id,
    this.post_content,
    this.image_url,
    this.created_at,
    this.user_id,
    this.username,
    this.full_name,
    this.profile_picture_url,
    this.like_count = 0,
    this.comment_count = 0,
    this.isLiked = false,
  });

  factory GetPostModel.fromJson(Map<String, dynamic> json) {
    return GetPostModel(
      post_id: json['post_id']?.toString(),
      post_content: json['post_content']?.toString(),
      image_url: json['image_url']?.toString(),
      created_at: json['created_at']?.toString(),
      user_id: _toInt(json['user_id']),
      username: json['username']?.toString(),
      full_name: json['full_name']?.toString(),
      profile_picture_url: json['profile_picture_url']?.toString(),
      like_count: int.tryParse(json['like_count'].toString()) ?? 0,
      comment_count: int.tryParse(json['comment_count'].toString()) ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1 || json['is_liked'] == "1",
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}