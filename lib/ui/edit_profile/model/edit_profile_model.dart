class ProfileUserModel {
  String? userId;
  String? username;
  String? fullName;
  String? email;
  String? profilePictureUrl;
  String? bio; // ✅ এই নতুন ফিল্ডটি যুক্ত করা হয়েছে

  ProfileUserModel({
    this.userId,
    this.username,
    this.fullName,
    this.email,
    this.profilePictureUrl,
    this.bio, // ✅ কনস্ট্রাক্টরে যুক্ত করা হলো
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      userId: json['user_id']?.toString(),
      username: json['username']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      profilePictureUrl: json['profile_picture_url']?.toString(),
      bio: json['bio']?.toString(), // ✅ JSON থেকে রিড করা হচ্ছে
    );
  }
}