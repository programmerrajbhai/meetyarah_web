class SpokenVideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String duration;
  final String level; // Beginner, Intermediate, Advanced
  final bool isLocked; // Premium video check
  final double progress; // 0.0 to 1.0 (কতটুকু দেখা হয়েছে)

  SpokenVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
    required this.level,
    this.isLocked = false,
    this.progress = 0.0,
  });
}