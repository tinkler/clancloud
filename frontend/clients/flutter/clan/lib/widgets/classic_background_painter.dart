import 'package:flutter/material.dart';

class ClassicBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define the gradient colors and stops
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffEDEAE5),
        Color(0xffC7B7A4),
        Color(0xff9F8069),
      ],
      stops: [0.0, 0.50, 1.0],
    );

    // Create a Paint object with the gradient
    final paint = Paint()..shader = gradient.createShader(Offset.zero & size);

    // Draw a rectangle filled with the gradient
    canvas.drawRect(Offset.zero & size, paint);

    // Draw a border around the rectangle
    final borderPaint = Paint()
      ..color = Color(0xff493B2A)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(20.0, 20.0, size.width - 40.0, size.height - 40.0),
      borderPaint,
    );

    // Draw some beautiful decorations
    final redCirclePaint = Paint()
      ..color = Color(0xffEC5F67)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.25), 40.0, redCirclePaint);

    final yellowCirclePaint = Paint()
      ..color = Color(0xffF3B143)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.25), 40.0, yellowCirclePaint);

    final blueSquarePaint = Paint()
      ..color = Color(0xff3BAFDA)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.75),
        width: 100.0,
        height: 100.0,
      ),
      blueSquarePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
