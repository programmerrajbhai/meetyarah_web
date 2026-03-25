import 'package:flutter/material.dart';

class FeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const FeedbackButton({super.key, required this.child, required this.onTap});

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed ? Matrix4.diagonal3Values(0.95, 0.95, 1.0) : Matrix4.identity(),
        decoration: BoxDecoration(
            color: _isPressed ? Colors.grey.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: widget.child,
      ),
    );
  }
}