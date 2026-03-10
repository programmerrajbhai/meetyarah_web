class ProfileUserModel {
  final int userId;
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final String? bio;
  final String createdAt;

  // ✅ ফিক্সড: ফলোয়ার এবং ফলোয়িং এর ভেরিয়েবল যুক্ত করা হলো
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  ProfileUserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    this.bio,
    required this.createdAt,
    this.followersCount = 0, // ডিফল্ট 0
    this.followingCount = 0, // ডিফল্ট 0
    this.isFollowing = false,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? "Unknown",
      fullName: json['full_name']?.toString() ?? "Unknown",
      profilePictureUrl: json['profile_picture_url']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: json['created_at']?.toString() ?? "",

      // ✅ ফিক্সড: JSON থেকে ফলোয়ারের ডাটা রিসিভ করা হলো
      followersCount: int.tryParse(json['followers_count']?.toString() ?? '0') ?? 0,
      followingCount: int.tryParse(json['following_count']?.toString() ?? '0') ?? 0,
      isFollowing: json['is_following'] == true || json['is_following'] == 1 || json['is_following'] == "1",
    );
  }
}