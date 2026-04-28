import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/blacklight_theme.dart';

// ─────────────────────────────────────────────────────────
// ALL ILLUSTRATIONS ARE GEOMETRIC CUSTOMPAINT — ZERO PHOTOS
// ─────────────────────────────────────────────────────────

/// Geometric isometric house with solar panel rectangles
class IsometricHouseIllustration extends StatelessWidget {
  final double width;
  final double height;

  const IsometricHouseIllustration({
    super.key,
    this.width = 480,
    this.height = 420,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _IsometricHousePainter()),
    );
  }
}

class _IsometricHousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    final borderPaint = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final wallPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final wallShadePaint = Paint()
      ..color = BlackLightColors.background
      ..style = PaintingStyle.fill;

    final roofPaint = Paint()
      ..color = BlackLightColors.surface
      ..style = PaintingStyle.fill;

    final panelPaint = Paint()
      ..color = BlackLightColors.surface
      ..style = PaintingStyle.fill;

    final panelBorderPaint = Paint()
      ..color = BlackLightColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final panelGreenPaint = Paint()
      ..color = BlackLightColors.green
      ..style = PaintingStyle.fill;

    // House dimensions in isometric projection
    final w = size.width * 0.38;
    final h = size.height * 0.28;
    final d = size.height * 0.18; // depth

    // Front face (left wall)
    final frontPath = Path()
      ..moveTo(cx - w, cy)
      ..lineTo(cx, cy - h * 0.5)
      ..lineTo(cx, cy + d - h * 0.5)
      ..lineTo(cx - w, cy + d)
      ..close();
    canvas.drawPath(frontPath, wallPaint);
    canvas.drawPath(frontPath, borderPaint);

    // Right face (right wall)
    final rightPath = Path()
      ..moveTo(cx, cy - h * 0.5)
      ..lineTo(cx + w, cy)
      ..lineTo(cx + w, cy + d)
      ..lineTo(cx, cy + d - h * 0.5)
      ..close();
    canvas.drawPath(rightPath, wallShadePaint);
    canvas.drawPath(rightPath, borderPaint);

    // Roof left slope
    final roofLeftPath = Path()
      ..moveTo(cx - w, cy)
      ..lineTo(cx, cy - h)
      ..lineTo(cx, cy - h * 0.5)
      ..close();
    canvas.drawPath(roofLeftPath, roofPaint);
    canvas.drawPath(roofLeftPath, borderPaint);

    // Roof right slope (main panel area)
    final roofRightPath = Path()
      ..moveTo(cx, cy - h)
      ..lineTo(cx + w, cy)
      ..lineTo(cx + w * 0.5, cy - h * 0.5)
      ..close();
    // Draw panels on right slope
    canvas.save();
    canvas.clipPath(roofRightPath);
    _drawPanelGrid(
      canvas,
      topLeft: Offset(cx, cy - h),
      topRight: Offset(cx + w, cy),
      cols: 5,
      rows: 3,
      greenCols: 2,
      panelPaint: panelPaint,
      panelGreenPaint: panelGreenPaint,
      panelBorderPaint: panelBorderPaint,
    );
    canvas.restore();
    canvas.drawPath(roofRightPath, borderPaint);
  }

  void _drawPanelGrid(
    Canvas canvas, {
    required Offset topLeft,
    required Offset topRight,
    required int cols,
    required int rows,
    required int greenCols,
    required Paint panelPaint,
    required Paint panelGreenPaint,
    required Paint panelBorderPaint,
  }) {
    final dx = (topRight.dx - topLeft.dx) / cols;
    final dy = (topRight.dy - topLeft.dy) / cols;
    final colH = (topRight.dy - topLeft.dy).abs() / rows * 1.4;

    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        final px = topLeft.dx + dx * c + dx * 0.1;
        final py = topLeft.dy + dy * c + colH * r + 4;
        final pw = dx * 0.8;
        final ph = colH * 0.75;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(px, py, pw, ph),
          const Radius.circular(1),
        );
        canvas.drawRRect(rect, c < greenCols ? panelGreenPaint : panelPaint);
        canvas.drawRRect(rect, panelBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Geometric concentric rings sun — used on sign-in right panel
class SunRingsIllustration extends StatelessWidget {
  final double size;

  const SunRingsIllustration({super.key, this.size = 420});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SunRingsPainter()),
    );
  }
}

class _SunRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radii = [
      size.width * 0.48,
      size.width * 0.36,
      size.width * 0.24,
      size.width * 0.12
    ];
    for (int i = 0; i < radii.length; i++) {
      if (i < radii.length - 1) {
        final paint = Paint()
          ..color =
              i == 0 ? BlackLightColors.border : BlackLightColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(center, radii[i], paint);
      } else {
        final corePaint = Paint()
          ..color = BlackLightColors.accent
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radii[i], corePaint);
        final icon = Icons.light_mode;
        final tp = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 40,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Cross-hair lines
    final linePaint = Paint()
      ..color = BlackLightColors.border
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // Diagonal lines
    final diagPaint = Paint()
      ..color = BlackLightColors.border
      ..strokeWidth = 1.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawLine(Offset(0, -size.height), Offset(0, size.height), diagPaint);
    canvas.rotate(math.pi / 2);
    canvas.drawLine(Offset(0, -size.height), Offset(0, size.height), diagPaint);
    canvas.restore();

    // Small accent dots
    final dotPaint = Paint()
      ..color = BlackLightColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center + const Offset(-120, -100), 6, dotPaint);
    canvas.drawCircle(center + const Offset(110, 90), 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Roof preview placeholder for chat + design screens
class RoofPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const RoofPlaceholder(
      {super.key, this.width = double.infinity, this.height = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _RoofPlaceholderPainter()),
    );
  }
}

class _RoofPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid background
    final gridPaint = Paint()
      ..color = BlackLightColors.border
      ..strokeWidth = 0.5;

    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.35;
    final h = size.height * 0.42;

    final roofPaint = Paint()
      ..color = BlackLightColors.surface
      ..style = PaintingStyle.fill;
    final borderP = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Simplified isometric house outline
    final path = Path()
      ..moveTo(cx, cy - h * 0.55)
      ..lineTo(cx + w * 0.9, cy - h * 0.1)
      ..lineTo(cx + w * 0.9, cy + h * 0.38)
      ..lineTo(cx, cy + h * 0.52)
      ..lineTo(cx - w * 0.9, cy + h * 0.38)
      ..lineTo(cx - w * 0.9, cy - h * 0.1)
      ..close();
    canvas.drawPath(path, roofPaint);
    canvas.drawPath(path, borderP);

    // Panel grid hint
    final panelPaint = Paint()
      ..color = BlackLightColors.surface
      ..style = PaintingStyle.fill;
    final panelBorder = Paint()
      ..color = BlackLightColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int c = 0; c < 5; c++) {
      for (int r = 0; r < 3; r++) {
        final px = cx - w * 0.7 + c * w * 0.28;
        final py = cy - h * 0.05 + r * h * 0.15;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(px, py, w * 0.22, h * 0.12),
          const Radius.circular(2),
        );
        canvas.drawRRect(rect, panelPaint);
        canvas.drawRRect(rect, panelBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Active roof design with colored panels
class ActiveRoofDesign extends StatelessWidget {
  final double width;
  final double height;

  const ActiveRoofDesign(
      {super.key, this.width = double.infinity, this.height = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _ActiveRoofPainter()),
    );
  }
}

class _ActiveRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = BlackLightColors.border
      ..strokeWidth = 0.4;

    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.38;
    final h = size.height * 0.44;

    // Roof surface
    final roofPaint = Paint()
      ..color = BlackLightColors.background
      ..style = PaintingStyle.fill;
    final borderP = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final roofPath = Path()
      ..moveTo(cx, cy - h * 0.55)
      ..lineTo(cx + w * 0.95, cy - h * 0.08)
      ..lineTo(cx + w * 0.95, cy + h * 0.4)
      ..lineTo(cx, cy + h * 0.54)
      ..lineTo(cx - w * 0.95, cy + h * 0.4)
      ..lineTo(cx - w * 0.95, cy - h * 0.08)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Green panels (ideal zones)
    final greenPaint = Paint()
      ..color = BlackLightColors.green
      ..style = PaintingStyle.fill;
    final greenBorder = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bluePaint = Paint()
      ..color = BlackLightColors.surface
      ..style = PaintingStyle.fill;
    final blueBorder = Paint()
      ..color = BlackLightColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final grayPaint = Paint()
      ..color = BlackLightColors.surface
      ..style = PaintingStyle.fill;
    final grayBorder = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.save();
    canvas.clipPath(roofPath);

    for (int c = 0; c < 6; c++) {
      for (int r = 0; r < 3; r++) {
        final px = cx - w * 0.85 + c * w * 0.285;
        final py = cy - h * 0.22 + r * h * 0.2;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(px, py, w * 0.24, h * 0.16),
          const Radius.circular(2),
        );
        Paint fillP;
        Paint strokeP;
        if (c < 2) {
          fillP = greenPaint;
          strokeP = greenBorder;
        } else if (c < 5) {
          fillP = bluePaint;
          strokeP = blueBorder;
        } else {
          fillP = grayPaint;
          strokeP = grayBorder;
        }
        canvas.drawRRect(rect, fillP);
        canvas.drawRRect(rect, strokeP);
      }
    }

    canvas.restore();
    canvas.drawPath(roofPath, borderP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Empty state house icon
class EmptyHouseIllustration extends StatelessWidget {
  const EmptyHouseIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 80,
      child: CustomPaint(painter: _EmptyHousePainter()),
    );
  }
}

class _EmptyHousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BlackLightColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    // Roof
    final roofPath = Path()
      ..moveTo(cx, 4)
      ..lineTo(size.width - 8, size.height * 0.45)
      ..lineTo(8, size.height * 0.45)
      ..close();
    canvas.drawPath(roofPath, paint);

    // Walls
    final wallPath = Path()
      ..moveTo(16, size.height * 0.45)
      ..lineTo(16, size.height - 2)
      ..lineTo(size.width - 16, size.height - 2)
      ..lineTo(size.width - 16, size.height * 0.45);
    canvas.drawPath(wallPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
