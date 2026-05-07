import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/illustrations/geometric_illustrations.dart';
import 'package:kooyoh_app/core/models/solar_design_data.dart';
import 'package:kooyoh_app/core/providers/solar_design_provider.dart';
import 'package:kooyoh_app/core/solar/solar_design_calculator.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

const double _kCanvasPx = 4400;

Matrix4 _isometricMatrix() {
  return Matrix4.identity()
    ..rotateZ(-0.048)
    ..setEntry(0, 1, -0.2);
}

Size _panelFootprint(CanvasSolarPanel p) {
  const shortEdge = KooyohSpacing.sm + KooyohSpacing.xs * 2;
  const longEdge = KooyohSpacing.sm * 5 + KooyohSpacing.xs;
  return p.portrait
      ? const Size(shortEdge, longEdge)
      : const Size(longEdge, shortEdge);
}

Color _orientationFill(double score, BuildContext context) {
  Color base;
  if (score >= 0.9) {
    base = KooyohColors.green;
  } else if (score >= 0.7) {
    base = KooyohColors.accent;
  } else if (score >= 0.5) {
    base = KooyohColors.amber;
  } else {
    base = context.colors.outline;
  }
  return base.withValues(alpha: 0.28);
}

Color _orientationBorder(double score) {
  if (score >= 0.9) return KooyohColors.green.withValues(alpha: 0.95);
  if (score >= 0.7) return KooyohColors.accent.withValues(alpha: 0.9);
  if (score >= 0.5) return KooyohColors.amber.withValues(alpha: 0.9);
  return KooyohColors.border;
}

List<_PreparedRoofSegment> _roofLayers(
  List<RoofSegmentData> segments,
  BuildContext context,
) {
  return [
    for (final seg in segments)
      if (seg.polygon.length >= 3)
        _PreparedRoofSegment(
          path: Path()..addPolygon(seg.polygon, true),
          fillColor: _orientationFill(seg.orientationScore, context),
          strokeColor: _orientationBorder(seg.orientationScore),
        ),
  ];
}

class _PreparedRoofSegment {
  _PreparedRoofSegment({
    required this.path,
    required this.fillColor,
    required this.strokeColor,
  });

  final Path path;
  final Color fillColor;
  final Color strokeColor;
}

String _formatThousands(num n) {
  final s = n.round().abs().toString();
  final buf = StringBuffer();
  if (n.round() < 0) buf.write('-');
  final len = s.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

bool _liveMatches(InteractiveDesignLiveState? live, SolarDesignData data) =>
    liveDesignStateMatchesCanvas(live, data);

Rect _roofBounds(List<RoofSegmentData> segments) {
  if (segments.isEmpty) {
    return const Rect.fromLTWH(0, 0, _kCanvasPx, _kCanvasPx);
  }
  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;
  for (final seg in segments) {
    for (final o in seg.polygon) {
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx);
      maxY = math.max(maxY, o.dy);
    }
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY).inflate(KooyohSpacing.md);
}

void _fitToScreen(Rect roofBounds, Size viewport, TransformationController tc) {
  final margin = KooyohSpacing.xl.toDouble();
  final contentW = roofBounds.width + margin;
  final contentH = roofBounds.height + margin;
  final sx = viewport.width / contentW;
  final sy = viewport.height / contentH;
  final s = math.min(sx, sy).clamp(0.05, 6.0);
  final scaledW = roofBounds.width * s;
  final scaledH = roofBounds.height * s;
  final tx = (viewport.width - scaledW) / 2 - roofBounds.left * s;
  final ty = (viewport.height - scaledH) / 2 - roofBounds.top * s;
  tc.value = Matrix4.translationValues(tx, ty, 0) *
      Matrix4.diagonal3Values(s, s, 1);
}

/// Non-interactive isometric solar roof preview with pan/zoom (desktop chat split pane).
class DesignDisplayWidget extends ConsumerStatefulWidget {
  const DesignDisplayWidget({super.key});

  @override
  ConsumerState<DesignDisplayWidget> createState() =>
      _DesignDisplayWidgetState();
}

class _DesignDisplayWidgetState extends ConsumerState<DesignDisplayWidget> {
  final TransformationController _transformation = TransformationController();

  SolarDesignData? _lastFitDesignRef;
  int _fitGen = 0;

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  List<CanvasSolarPanel> _panelsForMetrics(
    SolarDesignData data,
    InteractiveDesignLiveState? live,
  ) {
    final useLive = _liveMatches(live, data);
    if (useLive) return live!.panels;
    return data.activeConfig?.panels ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final vs = ref.watch(designProvider);
    final live = ref.watch(interactiveDesignLiveProvider);

    if (vs.hasBackendError) {
      return _DesignMessageCard(text: InteractiveCanvasContent.backendErrorBody);
    }

    if (vs.data == null) {
      _lastFitDesignRef = null;
      return Semantics(
        container: true,
        label: InteractiveCanvasContent.waitingBody,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(KooyohSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SunRingsIllustration(size: 300),
                const SizedBox(height: KooyohSpacing.md),
                Text(
                  InteractiveCanvasContent.waitingBody,
                  textAlign: TextAlign.center,
                  style: KooyohTextStyles.body(
                    color: context.colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = vs.data!;
    if (data.roofSegments.isEmpty) {
      return _DesignMessageCard(text: InteractiveCanvasContent.noRoofDataBody);
    }

    final panels = _panelsForMetrics(data, live);
    final financials = recalculateSolarFinancials(
      panels: panels,
      segments: data.roofSegments,
    );

    final annualProduction =
        data.yearlyEnergyDcKwh ?? financials.annualProductionKwh;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);

        if (!identical(_lastFitDesignRef, data)) {
          final captured = data;
          final vp = viewport;
          final gen = ++_fitGen;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || gen != _fitGen) return;
            if (vp.width < 8 || vp.height < 8) return;
            _fitToScreen(
              _roofBounds(captured.roofSegments),
              vp,
              _transformation,
            );
            _lastFitDesignRef = captured;
          });
        }

        final pad = KooyohSpacing.cardGap;
        final roofLayers =
            _roofLayers(data.roofSegments, context);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            ColoredBox(
              color: KooyohColors.background,
              child: InteractiveViewer(
                transformationController: _transformation,
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.12,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                constrained: false,
                child: SizedBox(
                  width: _kCanvasPx,
                  height: _kCanvasPx,
                  child: Transform(
                    transform: _isometricMatrix(),
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.low,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: const Size.square(_kCanvasPx),
                          painter: _DesignDotGridPainter(
                            spacing: KooyohSpacing.md,
                            dotColor: KooyohColors.border
                                .withValues(alpha: 0.45),
                            background: KooyohColors.background,
                          ),
                        ),
                        CustomPaint(
                          size: const Size.square(_kCanvasPx),
                          painter: _RoofSegmentsDisplayPainter(layers: roofLayers),
                        ),
                        CustomPaint(
                          size: const Size.square(_kCanvasPx),
                          painter: _PanelMarkersPainter(panels: panels),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: pad,
              top: pad,
              child: _DesignMetricsCard(
                panelCount: financials.panelCount,
                systemSizeKw: financials.systemSizeKw,
                annualProductionKwh: annualProduction.round(),
              ),
            ),
            Positioned(
              left: pad,
              bottom: pad,
              child: const _OrientationLegendDisplay(),
            ),
          ],
        );
      },
    );
  }
}

class _DesignMetricsCard extends StatelessWidget {
  const _DesignMetricsCard({
    required this.panelCount,
    required this.systemSizeKw,
    required this.annualProductionKwh,
  });

  final int panelCount;
  final double systemSizeKw;
  final int annualProductionKwh;

  Widget _row(String label, String value, {required bool divider}) {
    return Padding(
      padding: EdgeInsets.only(bottom: divider ? KooyohSpacing.cardGap : 0),
      child: Container(
        padding:
            EdgeInsets.only(bottom: divider ? KooyohSpacing.cardGap : 0),
        decoration: divider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: KooyohColors.border.withValues(alpha: 0.85),
                  ),
                ),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: KooyohTextStyles.caption(color: KooyohColors.textCaption),
              ),
            ),
            Text(
              value,
              style: KooyohTextStyles.data(color: KooyohColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
        decoration: BoxDecoration(
          color: KooyohColors.surface,
          borderRadius: BorderRadius.circular(KooyohRadius.md),
          border: Border.all(color: KooyohColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(
              InteractiveCanvasContent.metricSystemKw,
              systemSizeKw.toStringAsFixed(1),
              divider: true,
            ),
            _row(
              InteractiveCanvasContent.metricPanelCount,
              '$panelCount',
              divider: true,
            ),
            _row(
              InteractiveCanvasContent.metricAnnualProduction,
              _formatThousands(annualProductionKwh),
              divider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrientationLegendDisplay extends StatelessWidget {
  const _OrientationLegendDisplay();

  Widget _chip(Color fill, String label, {required bool addGapBelow}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: addGapBelow ? KooyohSpacing.cardGap : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: KooyohSpacing.sm,
            height: KooyohSpacing.sm,
            decoration: BoxDecoration(
              color: fill.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(KooyohRadius.sm / 4),
              border: Border.all(color: KooyohColors.border, width: 1),
            ),
          ),
          const SizedBox(width: KooyohSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: KooyohTextStyles.caption(color: KooyohColors.textCaption),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
        decoration: BoxDecoration(
          color: KooyohColors.surface,
          borderRadius: BorderRadius.circular(KooyohRadius.md),
          border: Border.all(color: KooyohColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip(KooyohColors.green, InteractiveCanvasContent.designDisplayLegendGreen,
                addGapBelow: true),
            _chip(KooyohColors.accent, InteractiveCanvasContent.designDisplayLegendBlue,
                addGapBelow: true),
            _chip(KooyohColors.amber, InteractiveCanvasContent.designDisplayLegendAmber,
                addGapBelow: true),
            _chip(
              context.colors.outline,
              InteractiveCanvasContent.designDisplayLegendGray,
              addGapBelow: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignDotGridPainter extends CustomPainter {
  _DesignDotGridPainter({
    required this.spacing,
    required this.dotColor,
    required this.background,
  });

  final double spacing;
  final Color dotColor;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()..color = dotColor;
    for (double y = spacing; y < size.height; y += spacing) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), KooyohSpacing.xs / 16 + 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DesignDotGridPainter oldDelegate) =>
      oldDelegate.spacing != spacing ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.background != background;
}

class _RoofSegmentsDisplayPainter extends CustomPainter {
  _RoofSegmentsDisplayPainter({required this.layers});

  final List<_PreparedRoofSegment> layers;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = KooyohSpacing.xs / 16 + 1;
    for (final layer in layers) {
      canvas.drawPath(layer.path, Paint()..color = layer.fillColor);
      canvas.drawPath(
        layer.path,
        Paint()
          ..color = layer.strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoofSegmentsDisplayPainter oldDelegate) =>
      oldDelegate.layers.length != layers.length;
}

class _PanelMarkersPainter extends CustomPainter {
  _PanelMarkersPainter({required this.panels});

  final List<CanvasSolarPanel> panels;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = KooyohColors.accent.withValues(alpha: 0.92);
    final borderPaint = Paint()
      ..color = KooyohColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final r = KooyohRadius.sm / 3;

    for (final p in panels) {
      final fp = _panelFootprint(p);
      final rect = Rect.fromCenter(
        center: p.center,
        width: fp.width,
        height: fp.height,
      );
      final rrect =
          RRect.fromRectAndRadius(rect, Radius.circular(r.toDouble()));
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PanelMarkersPainter oldDelegate) =>
      oldDelegate.panels.length != panels.length;
}

class _DesignMessageCard extends StatelessWidget {
  const _DesignMessageCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KooyohSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(KooyohSpacing.md),
          decoration: BoxDecoration(
            color: KooyohColors.surface,
            borderRadius: BorderRadius.circular(KooyohRadius.card),
            border: Border.all(color: KooyohColors.border, width: 1),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style:
                KooyohTextStyles.body(color: context.colors.onSurfaceMuted),
          ),
        ),
      ),
    );
  }
}
