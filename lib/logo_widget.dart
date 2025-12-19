import 'package:flutter/material.dart';
import 'dart:math' as math;

class MeetyarahLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const MeetyarahLogo({
    Key? key,
    this.size = 120,
    this.animate = true,
  }) : super(key: key);

  @override
  State<MeetyarahLogo> createState() => _MeetyarahLogoState();
}

class _MeetyarahLogoState extends State<MeetyarahLogo> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2962FF), Color(0xFF0091EA)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2962FF).withOpacity(0.4 + (_pulseController.value * 0.2)),
                    blurRadius: 15 + (_pulseController.value * 10),
                    spreadRadius: 2 + (_pulseController.value * 3),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [
                              _shimmerController.value - 0.4,
                              _shimmerController.value,
                              _shimmerController.value + 0.4,
                            ],
                            colors: [
                              Colors.white,
                              const Color(0xFFE3F2FD),
                              Colors.white,
                            ],
                          ).createShader(bounds);
                        },
                        child: CustomPaint(
                          size: Size(widget.size * 0.55, widget.size * 0.55),
                          painter: _MeetyarahPainter(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MeetyarahPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(0, h);
    path.lineTo(0, h * 0.1);
    path.quadraticBezierTo(0, 0, w * 0.2, h * 0.2);
    path.lineTo(w * 0.5, h * 0.6);
    path.lineTo(w * 0.8, h * 0.2);
    path.quadraticBezierTo(w, 0, w, h * 0.1);
    path.lineTo(w, h);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.75, h * 0.4);
    path.lineTo(w * 0.5, h * 0.75);
    path.lineTo(w * 0.25, h * 0.4);
    path.lineTo(w * 0.25, h);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}