import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Logic: Liked hole Filled Icon, nahole Outlined
            Icon(
              isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
              color: isLiked ? Colors.blue : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 6),
            // Text Logic: Liked hole "Liked", nahole "Like"
            Text(
              isLiked ? "Liked" : "Like",
              style: TextStyle(
                color: isLiked ? Colors.blue : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}