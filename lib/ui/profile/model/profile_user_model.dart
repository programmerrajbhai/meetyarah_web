class ProfileUserModel {
  final int userId;
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final String? bio; // ✅ ১. এখানে ভেরিয়েবল হিসেবে ডিক্লেয়ার করুন
  final String createdAt;

  ProfileUserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    this.bio,
    required this.createdAt,
  });


  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,

      username: json['username']?.toString() ?? "Unknown",
      fullName: json['full_name']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture_url'],
      bio: json['bio']?.toString(),
      createdAt: json['created_at']?.toString() ?? "",
    );
  }
}