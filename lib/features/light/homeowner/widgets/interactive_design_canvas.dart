import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/illustrations/geometric_illustrations.dart';
import 'package:kooyoh_app/core/models/solar_design_data.dart';
import 'package:kooyoh_app/core/providers/solar_design_provider.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

const double _kCanvasPx = 4000;
const double _kDotSpacing = 24;

/// Fixed module + pricing rules (matches product brief).
const double _kPanelKw = 0.4;
const double _kCostPerKwUsd = 2500;
const double _kElectricityRateUsdPerKwh = 0.17;
const double _kAnnualDegradation = 0.005;
const double _kFederalItcFraction = 0.30;

/// Panel footprint in canvas pixels (from [KooyohSpacing] tokens).
Size _panelFootprint(CanvasSolarPanel p) {
  const shortEdge = KooyohSpacing.sm + KooyohSpacing.xs * 2;
  const longEdge = KooyohSpacing.sm * 5 + KooyohSpacing.xs;
  return p.portrait
      ? const Size(shortEdge, longEdge)
      : const Size(longEdge, shortEdge);
}

RecalculatedFinancials _recalculateFinancials({
  required List<CanvasSolarPanel> panels,
  required List<RoofSegmentData> segments,
}) {
  final segById = {for (final s in segments) s.id: s};
  final n = panels.length;
  final systemKw = n * _kPanelKw;
  final totalCost = systemKw * _kCostPerKwUsd;
  var annualKwh = 0.0;
  for (final p in panels) {
    final seg = segById[p.roofSegmentId];
    if (seg == null) continue;
    annualKwh += _kPanelKw * seg.annualSunshineKwhPerKw;
  }
  var savings25 = 0.0;
  for (var y = 0; y < 25; y++) {
    savings25 +=
        annualKwh * math.pow(1 - _kAnnualDegradation, y) * _kElectricityRateUsdPerKwh;
  }
  final itc = totalCost * _kFederalItcFraction;
  final netCost = totalCost - itc;
  final y1 = annualKwh * _kElectricityRateUsdPerKwh;
  final payback = y1 > 1e-6 ? netCost / y1 : double.nan;
  return RecalculatedFinancials(
    panelCount: n,
    systemSizeKw: systemKw,
    annualProductionKwh: annualKwh,
    savings25YearUsd: savings25,
    paybackYears: payback,
    totalSystemCostUsd: totalCost,
    incentives: [
      SolarIncentiveLine(
        label: InteractiveCanvasContent.incentiveFederalItc,
        amountUsd: itc,
      ),
    ],
  );
}

Offset _polygonCentroid(List<Offset> poly) {
  var x = 0.0;
  var y = 0.0;
  for (final p in poly) {
    x += p.dx;
    y += p.dy;
  }
  final n = poly.length.clamp(1, 1000000);
  return Offset(x / n, y / n);
}

bool _rectFullyInsidePolygon(Rect r, List<Offset> poly) {
  final path = Path()..addPolygon(poly, true);
  for (final c in [
    r.topLeft,
    r.topRight,
    r.bottomLeft,
    r.bottomRight,
    r.center,
  ]) {
    if (!path.contains(c)) return false;
  }
  return true;
}

Offset _constrainPanelCenter(
  Offset desired,
  List<Offset> polygon,
  Size footprint,
) {
  final r = Rect.fromCenter(center: desired, width: footprint.width, height: footprint.height);
  if (_rectFullyInsidePolygon(r, polygon)) return desired;
  final centroid = _polygonCentroid(polygon);
  var lo = 0.0;
  var hi = 1.0;
  for (var i = 0; i < 48; i++) {
    final mid = (lo + hi) / 2;
    final p = Offset.lerp(desired, centroid, mid);
    if (p == null) return desired;
    final rr = Rect.fromCenter(center: p, width: footprint.width, height: footprint.height);
    if (_rectFullyInsidePolygon(rr, polygon)) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return Offset.lerp(desired, centroid, hi) ?? desired;
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

class InteractiveDesignCanvas extends ConsumerStatefulWidget {
  const InteractiveDesignCanvas({
    super.key,
    required this.onDesignChanged,
    this.compact = false,
  });

  final void Function(
    RecalculatedFinancials financials,
    List<CanvasSolarPanel> panels,
    String configurationId,
  ) onDesignChanged;

  /// Tighter overlays for modal / bottom sheet layouts.
  final bool compact;

  @override
  ConsumerState<InteractiveDesignCanvas> createState() =>
      _InteractiveDesignCanvasState();
}

class _InteractiveDesignCanvasState extends ConsumerState<InteractiveDesignCanvas> {
  final TransformationController _transformation = TransformationController();
  final GlobalKey _innerStackKey = GlobalKey();
  List<CanvasSolarPanel> _baselinePanels = [];
  List<CanvasSolarPanel> _panels = [];
  RecalculatedFinancials? _financials;
  String? _configId;

  SolarDesignData? _loadedData;

  bool _placementMode = false;
  bool _draggingPanel = false;
  String? _selectedId;

  Matrix4 _isometricMatrix() {
    return Matrix4.identity()
      ..rotateZ(-0.048)
      ..setEntry(0, 1, -0.2);
  }

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  void _applyDesignViewState(SolarDesignViewState vs) {
    final data = vs.data;
    if (identical(data, _loadedData)) return;
    _loadedData = data;
    if (data == null) {
      _baselinePanels = [];
      _panels = [];
      _configId = null;
      _financials = null;
      _selectedId = null;
      _placementMode = false;
      return;
    }
    final cfg = data.activeConfig;
    if (cfg == null) {
      _baselinePanels = [];
      _panels = [];
      _configId = null;
      _financials = _recalculateFinancials(
        panels: const [],
        segments: data.roofSegments,
      );
      return;
    }
    final copy = [
      ...cfg.panels.map(
        (p) => CanvasSolarPanel(
          id: p.id,
          roofSegmentId: p.roofSegmentId,
          center: p.center,
          portrait: p.portrait,
        ),
      ),
    ];
    _baselinePanels = [...copy];
    _panels = [...copy];
    _configId = cfg.id;
    _financials = _recalculateFinancials(
      panels: _panels,
      segments: data.roofSegments,
    );
  }

  List<CanvasSolarPanel> _clonePanels() =>
      [..._panels.map((p) => p.copyWith())];

  void _emitDesignChanged() {
    final data = _loadedData;
    if (data == null || _financials == null || _configId == null) return;
    widget.onDesignChanged(_financials!, _clonePanels(), _configId!);
  }

  void _recalcAndEmit({bool notifyParent = true}) {
    final data = _loadedData;
    if (data == null) return;
    _financials = _recalculateFinancials(
      panels: _panels,
      segments: data.roofSegments,
    );
    setState(() {});
    if (notifyParent) _emitDesignChanged();
  }

  void _resetPanels() {
    _panels = [..._baselinePanels.map((p) => p.copyWith())];
    _selectedId = null;
    _placementMode = false;
    _recalcAndEmit();
  }

  void _zoomStep(double factor, Size viewport) {
    final focal = Offset(viewport.width / 2, viewport.height / 2);
    final zoom = Matrix4.identity()
      ..translate(focal.dx, focal.dy)
      ..scale(factor)
      ..translate(-focal.dx, -focal.dy);
    _transformation.value = zoom * _transformation.value;
  }

  Rect _roofBounds() {
    final data = _loadedData;
    if (data == null || data.roofSegments.isEmpty) {
      return const Rect.fromLTWH(0, 0, _kCanvasPx, _kCanvasPx);
    }
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final seg in data.roofSegments) {
      for (final o in seg.polygon) {
        minX = math.min(minX, o.dx);
        minY = math.min(minY, o.dy);
        maxX = math.max(maxX, o.dx);
        maxY = math.max(maxY, o.dy);
      }
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY).inflate(KooyohSpacing.md);
  }

  void _fitToScreen(Size viewport) {
    final b = _roofBounds();
    final margin = KooyohSpacing.lg.toDouble();
    final contentW = b.width + margin;
    final contentH = b.height + margin;
    final sx = viewport.width / contentW;
    final sy = viewport.height / contentH;
    final s = math.min(sx, sy).clamp(0.05, 6.0);
    final scaledW = b.width * s;
    final scaledH = b.height * s;
    final tx = (viewport.width - scaledW) / 2 - b.left * s;
    final ty = (viewport.height - scaledH) / 2 - b.top * s;
    _transformation.value = Matrix4.translationValues(tx, ty, 0) *
        Matrix4.diagonal3Values(s, s, 1);
  }

  void _pickSegmentAt(Offset local) {
    final data = _loadedData;
    if (data == null) return;
    RoofSegmentData? hit;
    for (final seg in data.roofSegments.reversed) {
      final path = Path()..addPolygon(seg.polygon, true);
      if (path.contains(local)) {
        hit = seg;
        break;
      }
    }
    if (hit == null) return;
    final fp = _panelFootprint(CanvasSolarPanel(
      id: '_tmp',
      roofSegmentId: hit.id,
      center: Offset.zero,
      portrait: true,
    ));
    final center = _constrainPanelCenter(local, hit.polygon, fp);
    final id = 'panel_${DateTime.now().microsecondsSinceEpoch}';
    _panels.add(
      CanvasSolarPanel(
        id: id,
        roofSegmentId: hit.id,
        center: center,
        portrait: true,
      ),
    );
    _placementMode = false;
    _recalcAndEmit();
    setState(() {});
  }

  Future<void> _openPanelMenu(Offset tapGlobal, CanvasSolarPanel panel) async {
    setState(() => _selectedId = panel.id);
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final inset = mq.padding;

    final position = RelativeRect.fromLTRB(
      tapGlobal.dx.clamp(inset.left, size.width - 1),
      tapGlobal.dy.clamp(inset.top + KooyohSpacing.tapTarget, size.height - 1),
      (size.width - tapGlobal.dx).clamp(1, double.infinity),
      (size.height - tapGlobal.dy).clamp(1, double.infinity),
    );

    final choice = await showMenu<String>(
      context: context,
      position: position,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KooyohRadius.md),
        side: const BorderSide(color: KooyohColors.border, width: 1),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            InteractiveCanvasContent.contextDelete,
            style: KooyohTextStyles.body(color: KooyohColors.error),
          ),
        ),
        PopupMenuItem<String>(
          value: 'rotate',
          child: Text(
            InteractiveCanvasContent.contextRotate,
            style: KooyohTextStyles.body(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );

    if (!mounted) return;
    if (choice == 'delete') {
      _panels.removeWhere((e) => e.id == panel.id);
      _selectedId = null;
      _recalcAndEmit();
    } else if (choice == 'rotate') {
      final i = _panels.indexWhere((e) => e.id == panel.id);
      if (i >= 0) {
        final p = _panels[i];
        final poly = _segment(p.roofSegmentId)?.polygon;
        final fp = _panelFootprint(p.copyWith(portrait: !p.portrait));
        final cen = poly == null ? p.center : _constrainPanelCenter(p.center, poly, fp);
        _panels[i] = p.copyWith(portrait: !p.portrait, center: cen);
        _recalcAndEmit();
      }
    }
    setState(() {});
  }

  RoofSegmentData? _segment(String id) {
    for (final s in _loadedData?.roofSegments ?? const []) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vs = ref.watch(designProvider);
    _applyDesignViewState(vs);

    if (vs.hasBackendError) {
      return _MessageCard(text: InteractiveCanvasContent.backendErrorBody);
    }

    if (vs.data == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(
            widget.compact ? KooyohSpacing.md : KooyohSpacing.xl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SunRingsIllustration(
                size: widget.compact ? 200 : 300,
              ),
              SizedBox(
                height:
                    widget.compact ? KooyohSpacing.sm : KooyohSpacing.md,
              ),
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
      );
    }

    if (vs.data!.roofSegments.isEmpty) {
      return _MessageCard(text: InteractiveCanvasContent.noRoofDataBody);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final pad = widget.compact ? KooyohSpacing.sm : KooyohSpacing.md;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            ColoredBox(
              color: KooyohColors.background,
              child: InteractiveViewer(
                transformationController: _transformation,
                panEnabled: !_draggingPanel,
                scaleEnabled: !_draggingPanel,
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
                    child: Stack(
                      key: _innerStackKey,
                      clipBehavior: Clip.none,
                      children: [
                        CustomPaint(
                          size: const Size.square(_kCanvasPx),
                          painter: _DotGridPainter(
                            spacing: _kDotSpacing,
                            dotColor: KooyohColors.border
                                .withValues(alpha: 0.45),
                            background: KooyohColors.background,
                          ),
                        ),
                        IgnorePointer(
                          child: CustomPaint(
                            size: const Size.square(_kCanvasPx),
                            painter: _RoofSegmentsPainter(
                              layers: _roofLayers(
                                _loadedData!.roofSegments,
                                context,
                              ),
                            ),
                          ),
                        ),
                        ..._panels.map((p) => _buildPanelWidget(p)),
                        if (_placementMode)
                          Positioned.fill(
                            child: Listener(
                              behavior: HitTestBehavior.translucent,
                              onPointerDown: (e) {
                                final box =
                                    _innerStackKey.currentContext?.findRenderObject()
                                        as RenderBox?;
                                if (box == null) return;
                                final local = box.globalToLocal(e.position);
                                _pickSegmentAt(local);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: pad,
              top: pad,
              child: _Toolbar(
                compact: widget.compact,
                onReset: _resetPanels,
                onZoomIn: () => _zoomStep(1.15, viewport),
                onZoomOut: () => _zoomStep(1 / 1.15, viewport),
                onFit: () => _fitToScreen(viewport),
              ),
            ),
            Positioned(
              right: pad,
              top: pad,
              child: _FinancialsOverlay(
                financials: _financials!,
                compact: widget.compact,
              ),
            ),
            Positioned(
              left: pad,
              bottom: pad + (widget.compact ? 52 : KooyohSpacing.sm + KooyohSpacing.buttonHeight),
              child: _OrientationLegend(compact: widget.compact),
            ),
            if (_placementMode)
              Positioned(
                top:
                    pad +
                    (widget.compact ? 96 : KooyohSpacing.tapTarget + KooyohSpacing.sm),
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KooyohSpacing.sm,
                      vertical: KooyohSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: KooyohColors.surface,
                      borderRadius: BorderRadius.circular(KooyohRadius.card),
                      border: Border.all(
                        color: KooyohColors.accent.withValues(alpha: 0.42),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      InteractiveCanvasContent.placementModeHint,
                      style: KooyohTextStyles.caption(
                        color: KooyohColors.textBody,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: pad,
              bottom: pad,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_placementMode)
                    Padding(
                      padding: const EdgeInsets.only(right: KooyohSpacing.sm),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: KooyohSpacing.buttonHeight,
                        ),
                        child: Material(
                          color: KooyohColors.surface,
                          borderRadius: BorderRadius.circular(KooyohRadius.sm),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _placementMode = false;
                              });
                            },
                            borderRadius:
                                BorderRadius.circular(KooyohRadius.sm),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: KooyohSpacing.md,
                              ),
                              child: Center(
                                child: Text(
                                  InteractiveCanvasContent.placementExit,
                                  style: KooyohTextStyles.bodyBold(
                                    color: KooyohColors.accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  FloatingActionButton(
                    tooltip: InteractiveCanvasContent.fabAddPanel,
                    onPressed: () {
                      setState(() {
                        _placementMode = !_placementMode;
                      });
                    },
                    elevation: 0,
                    backgroundColor: KooyohColors.accent,
                    foregroundColor: KooyohColors.surface,
                    child: Icon(
                      _placementMode ? Icons.close : Icons.add,
                      color: KooyohColors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPanelWidget(CanvasSolarPanel panel) {
    final fp = _panelFootprint(panel);
    final isSelected =
        panel.id == _selectedId &&
            !_placementMode;
    final box = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: fp.width,
          height: fp.height,
          decoration: BoxDecoration(
            color: KooyohColors.accent.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(KooyohRadius.sm / 3),
            border: Border.all(
              color:
                  isSelected ? KooyohColors.green : KooyohColors.surface,
              width: isSelected ? KooyohSpacing.xs / 8 + 2 : 1,
            ),
          ),
        ),
      ],
    );

    return Positioned(
      left: panel.center.dx - fp.width / 2,
      top: panel.center.dy - fp.height / 2,
      width: fp.width,
      height: fp.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedId = panel.id),
        onLongPressStart: (d) =>
            _openPanelMenu(d.globalPosition, panel),
        onPanStart: (_) {
          setState(() => _draggingPanel = true);
        },
        onPanUpdate: (d) {
          final rb =
              _innerStackKey.currentContext?.findRenderObject() as RenderBox?;
          if (rb == null) return;
          final i = _panels.indexWhere((e) => e.id == panel.id);
          if (i < 0) return;
          final cur = rb.globalToLocal(d.globalPosition);
          final prev = rb.globalToLocal(d.globalPosition - d.delta);
          final proposed = _panels[i].center + (cur - prev);
          final poly = _segment(_panels[i].roofSegmentId)?.polygon;
          if (poly == null) return;
          final adjusted = _constrainPanelCenter(proposed, poly, fp);
          _panels[i] = _panels[i].copyWith(center: adjusted);
          setState(() {});
        },
        onPanEnd: (_) {
          _draggingPanel = false;
          _recalcAndEmit();
        },
        onPanCancel: () => _draggingPanel = false,
        child: box,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.text});

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
            style: KooyohTextStyles.body(color: context.colors.onSurfaceMuted),
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.compact,
    required this.onReset,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
  });

  final bool compact;
  final VoidCallback onReset;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? KooyohSpacing.xs : KooyohSpacing.sm;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToolButton(
            icon: Icons.refresh,
            label: InteractiveCanvasContent.toolbarReset,
            onTap: onReset,
            compact: compact,
          ),
          SizedBox(height: pad),
          _ToolButton(
            icon: Icons.zoom_in,
            label: InteractiveCanvasContent.toolbarZoomIn,
            onTap: onZoomIn,
            compact: compact,
          ),
          SizedBox(height: pad),
          _ToolButton(
            icon: Icons.zoom_out,
            label: InteractiveCanvasContent.toolbarZoomOut,
            onTap: onZoomOut,
            compact: compact,
          ),
          SizedBox(height: pad),
          _ToolButton(
            icon: Icons.fit_screen,
            label: InteractiveCanvasContent.toolbarFit,
            onTap: onFit,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KooyohColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KooyohRadius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? KooyohSpacing.xs : KooyohSpacing.sm,
            vertical: KooyohSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 18 : 20, color: KooyohColors.accent),
              if (!compact) ...[
                const SizedBox(width: KooyohSpacing.xs),
                Text(
                  label,
                  style: KooyohTextStyles.caption(color: KooyohColors.textBody),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialsOverlay extends StatelessWidget {
  const _FinancialsOverlay({
    required this.financials,
    required this.compact,
  });

  final RecalculatedFinancials financials;
  final bool compact;

  Widget _row(
    String label,
    String displayValue, {
    required bool divider,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: divider ? KooyohSpacing.sm : 0),
      child: Container(
        padding: EdgeInsets.only(bottom: divider ? KooyohSpacing.sm : 0),
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
              displayValue,
              style: KooyohTextStyles.data(
                color: valueColor ?? KooyohColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = compact ? KooyohSpacing.sm : KooyohSpacing.md;
    final payback = financials.paybackYears.isFinite
        ? financials.paybackYears.toStringAsFixed(1)
        : InteractiveCanvasContent.paybackUnavailable;
    final prod = _formatThousands(financials.annualProductionKwh.round());
    final sav = _formatThousands(financials.savings25YearUsd.round());
    final cost = _formatThousands(financials.totalSystemCostUsd.round());

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 220 : 280),
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: KooyohColors.surface,
          borderRadius: BorderRadius.circular(KooyohRadius.card),
          border: Border.all(color: KooyohColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: KooyohColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(
              InteractiveCanvasContent.metricPanels,
              '${financials.panelCount}',
              divider: true,
            ),
            _row(
              InteractiveCanvasContent.metricSystemKw,
              financials.systemSizeKw.toStringAsFixed(1),
              divider: true,
            ),
            _row(
              InteractiveCanvasContent.metricAnnualProduction,
              prod,
              divider: true,
            ),
            _row(
              InteractiveCanvasContent.metricSavings25,
              '${'\$'}$sav',
              divider: true,
              valueColor: KooyohColors.green,
            ),
            _row(
              InteractiveCanvasContent.metricPayback,
              payback,
              divider: true,
            ),
            _row(
              InteractiveCanvasContent.metricTotalCost,
              '${'\$'}$cost',
              divider: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: KooyohSpacing.sm),
              child: Text(
                InteractiveCanvasContent.metricIncentivesHeading,
                style: KooyohTextStyles.captionBold(color: KooyohColors.textBody),
              ),
            ),
            for (final line in financials.incentives) ...[
              Padding(
                padding: const EdgeInsets.only(top: KooyohSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        line.label ??
                            InteractiveCanvasContent.incentiveFederalItc,
                        style: KooyohTextStyles.caption(
                          color: context.colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                    Text(
                      '${'\$'}${_formatThousands(line.amountUsd.round())}',
                      style: KooyohTextStyles.data(color: KooyohColors.green),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrientationLegend extends StatelessWidget {
  const _OrientationLegend({required this.compact});

  final bool compact;

  Widget _chip({
    required Color fill,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: KooyohSpacing.sm,
          height: KooyohSpacing.sm,
          decoration: BoxDecoration(
            color: fill.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: KooyohColors.border, width: 1),
          ),
        ),
        SizedBox(width: compact ? KooyohSpacing.xs / 2 : KooyohSpacing.xs),
        Text(
          label,
          style: KooyohTextStyles.caption(
            color: KooyohColors.textCaption,
          ).copyWith(fontSize: compact ? 11 : 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = compact ? KooyohSpacing.sm : KooyohSpacing.md;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border, width: 1),
      ),
      child: Wrap(
        spacing: compact ? KooyohSpacing.sm : KooyohSpacing.md,
        runSpacing: KooyohSpacing.xs,
        children: [
          _chip(fill: KooyohColors.green, label: InteractiveCanvasContent.legendTierExcellent),
          _chip(fill: KooyohColors.accent, label: InteractiveCanvasContent.legendTierGood),
          _chip(fill: KooyohColors.amber, label: InteractiveCanvasContent.legendTierFair),
          _chip(fill: KooyohColors.surfaceMuted, label: InteractiveCanvasContent.legendTierLow),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
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
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.spacing != spacing ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.background != background;
}

class _RoofSegmentsPainter extends CustomPainter {
  _RoofSegmentsPainter({required this.layers});

  final List<_PreparedRoofSegment> layers;

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      canvas.drawPath(layer.path, Paint()..color = layer.fillColor);
      canvas.drawPath(
        layer.path,
        Paint()
          ..color = layer.strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = KooyohSpacing.xs / 12 + 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoofSegmentsPainter oldDelegate) =>
      oldDelegate.layers.length != layers.length;
}
