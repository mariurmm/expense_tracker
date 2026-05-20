import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  const LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas
      // Wallet body
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + size.height * 0.05),
            width: size.width * 0.78,
            height: size.height * 0.52,
          ),
          Radius.circular(size.width * 0.12),
        ),
        white,
      )
      // Wallet top flap
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cx - size.width * 0.39,
            cy - size.height * 0.32,
            size.width * 0.46,
            size.height * 0.22,
          ),
          Radius.circular(size.width * 0.07),
        ),
        white,
      );

    // ₸ symbol
    final tp = TextPainter(
      text: TextSpan(
        text: '₸',
        style: TextStyle(
          color: const Color(0xFF1A237E),
          fontSize: size.width * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        cx - tp.width / 2,
        cy - tp.height / 2 + size.height * 0.05,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
