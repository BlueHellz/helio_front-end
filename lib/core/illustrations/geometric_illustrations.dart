import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/limye_theme.dart';

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
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final wallPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final wallShadePaint = Paint()
      ..color = LimyeColors.background
      ..style = PaintingStyle.fill;

    final roofPaint = Paint()
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;

    final panelPaint = Paint()
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;

    final panelBorderPaint = Paint()
      ..color = LimyeColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final panelGreenPaint = Paint()
      ..color = LimyeColors.green
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
              i == 0 ? LimyeColors.border : LimyeColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(center, radii[i], paint);
      } else {
        final corePaint = Paint()
          ..color = LimyeColors.accent
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
      ..color = LimyeColors.border
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    // Diagonal lines
    final diagPaint = Paint()
      ..color = LimyeColors.border
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
      ..color = LimyeColors.accent
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
      ..color = LimyeColors.border
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
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;
    final borderP = Paint()
      ..color = LimyeColors.border
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
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;
    final panelBorder = Paint()
      ..color = LimyeColors.accent
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
      ..color = LimyeColors.border
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
      ..color = LimyeColors.background
      ..style = PaintingStyle.fill;
    final borderP = Paint()
      ..color = LimyeColors.border
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
      ..color = LimyeColors.green
      ..style = PaintingStyle.fill;
    final greenBorder = Paint()
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bluePaint = Paint()
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;
    final blueBorder = Paint()
      ..color = LimyeColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final grayPaint = Paint()
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;
    final grayBorder = Paint()
      ..color = LimyeColors.border
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
      ..color = LimyeColors.border
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

/// Richer hero art: isometric house + sun rays (landing hero right rail).
class LandingHeroIsometricIllustration extends StatelessWidget {
  final double width;
  final double height;

  const LandingHeroIsometricIllustration({
    super.key,
    this.width = 480,
    this.height = 400,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _LandingHeroSolarPainter()),
    );
  }
}

class _LandingHeroSolarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _IsometricHousePainter().paint(canvas, size);

    final rayPaint = Paint()
      ..color = LimyeColors.accent.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final sunCenter = Offset(size.width * 0.82, size.height * 0.12);
    for (int i = 0; i < 9; i++) {
      final angle = -math.pi * 0.35 + (i / 8) * math.pi * 0.45;
      final len = size.shortestSide * 0.5;
      canvas.drawLine(
        sunCenter,
        sunCenter + Offset(math.cos(angle) * len, math.sin(angle) * len),
        rayPaint,
      );
    }
    final sunCore = Paint()
      ..color = LimyeColors.amber.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 10, sunCore);
    canvas.drawCircle(
      sunCenter,
      10,
      Paint()
        ..color = LimyeColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small isometric-style icons for landing “How it works” (40×40).
class LandingHowItWorksIsoIcon extends StatelessWidget {
  final int stepIndex;

  const LandingHowItWorksIsoIcon({super.key, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(painter: _HowItWorksIsoPainter(stepIndex)),
    );
  }
}

class _HowItWorksIsoPainter extends CustomPainter {
  _HowItWorksIsoPainter(this.stepIndex);
  final int stepIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()
      ..color = LimyeColors.surface
      ..style = PaintingStyle.fill;
    final acc = Paint()
      ..color = LimyeColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (stepIndex == 0) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 10, 28, 22),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, fill);
      canvas.drawRRect(r, border);
      canvas.drawCircle(const Offset(20, 8), 4, fill);
      canvas.drawCircle(const Offset(20, 8), 4, acc);
    } else if (stepIndex == 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(8, 6, 24, 28), const Radius.circular(2)),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(8, 6, 24, 28), const Radius.circular(2)),
        border,
      );
      for (double y = 14.0; y < 28; y += 5) {
        canvas.drawLine(Offset(12, y), Offset(28, y), acc);
      }
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(6, 8, 28, 26), const Radius.circular(2)),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(6, 8, 28, 26), const Radius.circular(2)),
        border,
      );
      canvas.drawLine(const Offset(20, 12), const Offset(26, 22), acc);
      canvas.drawLine(const Offset(20, 12), const Offset(14, 22), acc);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Browser-frame mockup: chat + roof sketch (homeowner workflow).
class BrowserMockupHomeownerIllustration extends StatelessWidget {
  final double width;
  final double height;

  const BrowserMockupHomeownerIllustration({
    super.key,
    this.width = 420,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _BrowserHomeownerPainter()),
    );
  }
}

class _BrowserHomeownerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBrowserChrome(canvas, size);

    final inner = Rect.fromLTWH(14, 48, size.width - 28, size.height - 62);
    final roofTop = inner.top + 8.0;
    final path = Path()
      ..moveTo(inner.left + inner.width * 0.5, roofTop)
      ..lineTo(inner.right - 16, roofTop + 48)
      ..lineTo(inner.left + 16, roofTop + 48)
      ..close();
    canvas.drawPath(path, Paint()..color = LimyeColors.surface);
    canvas.drawPath(path, Paint()
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    final panelP = Paint()
      ..color = LimyeColors.green.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            inner.left + 28.0 + i * 22, roofTop + 14, 18, 14),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, panelP);
      canvas.drawRRect(
        r,
        Paint()
          ..color = LimyeColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(inner.left + 12, inner.bottom - 72, inner.width * 0.65, 48),
      const Radius.circular(10),
    );
    canvas.drawRRect(bubble, Paint()..color = LimyeColors.background);
    canvas.drawRRect(
      bubble,
      Paint()
        ..color = LimyeColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(bubble.outerRect.left + 14, bubble.outerRect.top + 14.0 + i * 12),
        Offset(bubble.outerRect.right - 40, bubble.outerRect.top + 14.0 + i * 12),
        Paint()
          ..color = LimyeColors.border
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Browser-frame mockup: sidebar + KPI cards (installer).
class BrowserMockupOrgDashboardIllustration extends StatelessWidget {
  final double width;
  final double height;

  const BrowserMockupOrgDashboardIllustration({
    super.key,
    this.width = 420,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _BrowserOrgDashPainter()),
    );
  }
}

class _BrowserOrgDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBrowserChrome(canvas, size);
    final inner = Rect.fromLTWH(14, 48, size.width - 28, size.height - 62);
    final sidebar = RRect.fromRectAndRadius(
      Rect.fromLTWH(inner.left + 4, inner.top + 4, 48, inner.height - 8),
      const Radius.circular(6),
    );
    canvas.drawRRect(sidebar, Paint()..color = LimyeColors.background);
    canvas.drawRRect(
      sidebar,
      Paint()
        ..color = LimyeColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              sidebar.outerRect.left + 8, sidebar.outerRect.top + 12.0 + i * 20, 32, 8),
          const Radius.circular(2),
        ),
        Paint()..color = LimyeColors.border.withValues(alpha: 0.4),
      );
    }

    final originX = sidebar.outerRect.right + 12.0;
    final originY = inner.top + 8;
    final cardW = (inner.right - originX - 8) / 2;
    for (int c = 0; c < 2; c++) {
      for (int r = 0; r < 2; r++) {
        final card = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              originX + c * (cardW + 8), originY + r * 56, cardW, 48),
          const Radius.circular(8),
        );
        canvas.drawRRect(card, Paint()..color = LimyeColors.surface);
        canvas.drawRRect(
          card,
          Paint()
            ..color = LimyeColors.border
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                card.outerRect.left + 12, card.outerRect.top + 14, cardW * 0.35, 8),
            const Radius.circular(2),
          ),
          Paint()..color = LimyeColors.accent.withValues(alpha: 0.3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _paintBrowserChrome(Canvas canvas, Size size) {
  final outer = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size.width, size.height),
    Radius.circular(LimyeRadius.card),
  );
  canvas.drawRRect(outer, Paint()..color = LimyeColors.surface);
  canvas.drawRRect(
    outer,
    Paint()
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
  for (int i = 0; i < 3; i++) {
    canvas.drawCircle(Offset(18.0 + i * 14, 22), 4,
        Paint()..color = LimyeColors.border);
  }
  final bar = RRect.fromRectAndRadius(
    Rect.fromLTWH(54, 14, size.width - 68, 18),
    const Radius.circular(6),
  );
  canvas.drawRRect(bar, Paint()..color = LimyeColors.background);
  canvas.drawRRect(
    bar,
    Paint()
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
}

/// EV marketing hero: isometric car + pedestal charger (~200px tall).
class IsometricEvCarChargerIllustration extends StatelessWidget {
  final double width;
  final double height;

  const IsometricEvCarChargerIllustration({
    super.key,
    this.width = 360,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _EvIsoPainter()),
    );
  }
}

class _EvIsoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = LimyeColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()..color = LimyeColors.surface;
    final cx = size.width * 0.5;
    final cy = size.height * 0.62;

    // Charger base
    final base = Path()
      ..moveTo(cx - 18, cy + 28)
      ..lineTo(cx + 8, cy + 18)
      ..lineTo(cx + 28, cy + 28)
      ..lineTo(cx + 2, cy + 38)
      ..close();
    canvas.drawPath(base, fill);
    canvas.drawPath(base, border);

    // Pedestal
    final ped = Path()
      ..moveTo(cx + 8, cy + 18)
      ..lineTo(cx + 8, cy - 8)
      ..lineTo(cx + 22, cy + 2)
      ..lineTo(cx + 22, cy + 22);
    canvas.drawPath(
      ped,
      Paint()
        ..color = LimyeColors.background
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Cable arc
    canvas.drawPath(
      Path()
        ..moveTo(cx + 18, cy - 4)
        ..quadraticBezierTo(cx - 10, cy - 40, cx - 52, cy - 12),
      Paint()
        ..color = LimyeColors.accent
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // Car body (isometric box)
    final car = Path()
      ..moveTo(cx - 70, cy - 20)
      ..lineTo(cx - 10, cy - 48)
      ..lineTo(cx + 38, cy - 22)
      ..lineTo(cx + 38, cy + 6)
      ..lineTo(cx - 22, cy + 22)
      ..lineTo(cx - 70, cy - 4)
      ..close();
    canvas.drawPath(car, fill);
    canvas.drawPath(car, border);

    // Window strip
    canvas.drawPath(
      Path()
        ..moveTo(cx - 48, cy - 14)
        ..lineTo(cx - 18, cy - 32)
        ..lineTo(cx + 18, cy - 14)
        ..lineTo(cx - 12, cy + 0)
        ..close(),
      Paint()..color = LimyeColors.accent.withValues(alpha: 0.12),
    );

    // Connector head
    canvas.drawCircle(Offset(cx - 52, cy - 12), 5,
        Paint()..color = LimyeColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pool “How it works”: stylised figures around a solar roof island.
class IsometricPoolCommunityIllustration extends StatelessWidget {
  final double width;
  final double height;

  const IsometricPoolCommunityIllustration({
    super.key,
    this.width = 320,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _PoolPeopleRoofPainter()),
    );
  }
}

class _PoolPeopleRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final roof = Path()
      ..moveTo(cx, cy - 36)
      ..lineTo(cx + 88, cy + 6)
      ..lineTo(cx, cy + 38)
      ..lineTo(cx - 88, cy + 6)
      ..close();
    canvas.drawPath(roof, Paint()..color = LimyeColors.surface);
    canvas.drawPath(
      roof,
      Paint()
        ..color = LimyeColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final panel = Paint()..color = LimyeColors.green.withValues(alpha: 0.28);
    for (int i = -2; i <= 2; i++) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + i * 14.0 - 10, cy - 4 + i * 3.0, 22, 12),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, panel);
      canvas.drawRRect(
        r,
        Paint()
          ..color = LimyeColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }

    void person(Offset o, Color c) {
      canvas.drawCircle(o, 5, Paint()..color = c);
      final b = Path()
        ..moveTo(o.dx - 6, o.dy + 20)
        ..lineTo(o.dx + 6, o.dy + 20)
        ..lineTo(o.dx + 4, o.dy + 8)
        ..lineTo(o.dx - 4, o.dy + 8)
        ..close();
      canvas.drawPath(b, Paint()..color = c.withValues(alpha: 0.35));
      canvas.drawPath(
        b,
        Paint()
          ..color = LimyeColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    person(Offset(cx - 108, cy + 18), LimyeColors.accent);
    person(Offset(cx + 108, cy + 18), LimyeColors.textBody);
    person(Offset(cx - 40, cy + 52), LimyeColors.green);
    person(Offset(cx + 44, cy + 52), LimyeColors.textBody);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
