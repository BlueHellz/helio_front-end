import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/blacklight_theme.dart';
import 'providers/org_providers.dart';

/// Wraps sections that gain edit chrome when org design mode is enabled.
class DesignModeWrapper extends ConsumerWidget {
  const DesignModeWrapper({
    super.key,
    required this.sectionId,
    required this.child,
    this.onRemove,
  });

  final String sectionId;
  final Widget child;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(designModeProvider);
    final enabled = mode.valueOrNull ?? false;

    if (!enabled) {
      return child;
    }

    final accent = Theme.of(context).colorScheme.primary;
    final handleColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _DashedRoundedRectPainter(
            color: accent,
            radius: BlackLightRadius.md,
          ),
          child: Padding(
            padding: const EdgeInsets.all(BlackLightSpacing.sm),
            child: child,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.drag_indicator,
                size: 20,
                color: handleColor,
              ),
              if (onRemove != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: handleColor,
                  ),
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        const dash = 5.0;
        const gap = 4.0;
        final end = (d + dash).clamp(0.0, metric.length);
        final seg = metric.extractPath(d, end);
        canvas.drawPath(seg, paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter old) =>
      old.color != color || old.radius != radius;
}
