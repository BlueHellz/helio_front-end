import 'dart:async';
import 'dart:math' as math;

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _kCanvas = 4000;
const double _kNodeW = 200;
const double _kNodeH = 128;
const double _kPort = 8;
const double _kGrid = 24;
const double _kBezierPad = 50;

/// Visual Flow Mesh editor (node graph). Shell header/sidebar omitted by design.
class PipelineBuilderCanvas extends ConsumerStatefulWidget {
  const PipelineBuilderCanvas({
    super.key,
    required this.pipelineId,
  });

  final String pipelineId;

  @override
  ConsumerState<PipelineBuilderCanvas> createState() =>
      _PipelineBuilderCanvasState();
}

class FlowMeshEdge {
  const FlowMeshEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
  });

  final String id;
  final String sourceId;
  final String targetId;

  static FlowMeshEdge? tryParse(Map<String, dynamic> m) {
    final sid = (m['source_stage_id'] ?? m['sourceStageId'])?.toString();
    final tid = (m['target_stage_id'] ?? m['targetStageId'])?.toString();
    if (sid == null || tid == null || sid.isEmpty || tid.isEmpty) {
      return null;
    }
    return FlowMeshEdge(
      id: (m['id'] ?? '${sid}_$tid').toString(),
      sourceId: sid,
      targetId: tid,
    );
  }
}

class _PipelineBuilderCanvasState extends ConsumerState<PipelineBuilderCanvas> {
  late final TransformationController _tc;
  final GlobalKey _canvasKey = GlobalKey();
  final Map<String, Offset> _positions = {};
  final Map<String, Timer> _posTimers = {};
  Timer? _propTimer;

  List<FlowMeshEdge> _edges = [];
  String? _hydratedSig;

  String? _selectedNodeId;
  String? _selectedEdgeId;

  String? _draggingNodeId;
  Offset? _dragNodePointer;

  String? _wireFromId;
  Offset? _wirePreviewEndCanvas;

  @override
  void initState() {
    super.initState();
    _tc = TransformationController();
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final t in _posTimers.values) {
      t.cancel();
    }
    _propTimer?.cancel();
    _tc.dispose();
    super.dispose();
  }

  double _readAxis(Map<String, dynamic> s, List<String> keys, double fallback) {
    for (final k in keys) {
      final v = s[k];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
    }
    return fallback;
  }

  void _hydrate(List<Map<String, dynamic>> stages, List<Map<String, dynamic>> edgeMaps) {
    final sig =
        '${stages.map((e) => e['id']).join(',')}|${edgeMaps.map((e) => '${e['source_stage_id']}-${e['target_stage_id']}').join(';')}';
    if (_hydratedSig == sig) return;
    _hydratedSig = sig;

    setState(() {
      _edges = edgeMaps
          .map(FlowMeshEdge.tryParse)
          .whereType<FlowMeshEdge>()
          .toList();

      final live = <String>{};
      for (var i = 0; i < stages.length; i++) {
        final s = stages[i];
        final id = s['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        live.add(id);
        if (!_positions.containsKey(id)) {
          _positions[id] = Offset(
            _readAxis(s, const ['x_position', 'xPosition'], 100 + (i % 5) * 240),
            _readAxis(s, const ['y_position', 'yPosition'], 100 + (i ~/ 5) * 170),
          );
        }
      }
      _positions.removeWhere((k, _) => !live.contains(k));
    });
  }

  Offset _portOut(String stageId) {
    final p = _positions[stageId] ?? Offset.zero;
    return Offset(p.dx + _kNodeW, p.dy + _kNodeH / 2);
  }

  Offset _portIn(String stageId) {
    final p = _positions[stageId] ?? Offset.zero;
    return Offset(p.dx, p.dy + _kNodeH / 2);
  }

  Offset _bezierMidpoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx,
      u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy,
    );
  }

  Offset _edgeMid(FlowMeshEdge e) {
    final a = _portOut(e.sourceId);
    final b = _portIn(e.targetId);
    final c1 = Offset(a.dx + _kBezierPad, a.dy);
    final c2 = Offset(b.dx - _kBezierPad, b.dy);
    return _bezierMidpoint(a, c1, c2, b, 0.5);
  }

  Future<void> _debouncedSavePosition(String stageId) async {
    _posTimers[stageId]?.cancel();
    _posTimers[stageId] = Timer(const Duration(milliseconds: 500), () async {
      final pos = _positions[stageId];
      if (pos == null) return;
      try {
        await ref.read(apiProvider).updateStage(
              widget.pipelineId,
              stageId,
              {
                'x_position': pos.dx,
                'y_position': pos.dy,
              },
            );
      } catch (e) {
        if (mounted) {
          AppFeedback.snack(context, '${ApiErrorsContent.saveFailedPrefix}$e');
        }
      }
    });
  }

  Future<void> _addStageWithType(String stageType, String defaultName) async {
    final center = const Offset(_kCanvas / 2 - _kNodeW / 2, _kCanvas / 2 - _kNodeH / 2);
    try {
      final row = await ref.read(apiProvider).addStage(
            widget.pipelineId,
            {
              'name': defaultName,
              'stage_type': stageType,
              'color_key': 'primary',
              'x_position': center.dx,
              'y_position': center.dy,
              'order': 999,
            },
          );
      final id = row['id']?.toString();
      if (id != null && mounted) {
        setState(() {
          _positions[id] = center;
          _hydratedSig = null;
        });
      }
      ref.invalidate(pipelineStagesProvider(widget.pipelineId));
      ref.invalidate(pipelineEdgesProvider(widget.pipelineId));
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(context, '${ApiErrorsContent.addFailedPrefix}$e');
      }
    }
  }

  Future<void> _addEdge(String sourceId, String targetId) async {
    if (sourceId == targetId) return;
    if (_edges.any((e) => e.sourceId == sourceId && e.targetId == targetId)) {
      return;
    }
    try {
      await ref.read(apiProvider).addPipelineEdge(widget.pipelineId, sourceId, targetId);
      ref.invalidate(pipelineEdgesProvider(widget.pipelineId));
      setState(() {
        _hydratedSig = null;
      });
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(context, '${ApiErrorsContent.addFailedPrefix}$e');
      }
    }
  }

  Future<void> _confirmRemoveEdge(String edgeId) async {
    final ok = await AppFeedback.showConfirmDialog(
      context,
      title: OrgSettingsPipelineBuilderContent.wireDeleteConfirmTitle,
      message: OrgSettingsPipelineBuilderContent.wireDeleteConfirmBody,
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(apiProvider).removePipelineEdge(widget.pipelineId, edgeId);
      ref.invalidate(pipelineEdgesProvider(widget.pipelineId));
      setState(() {
        _selectedEdgeId = null;
        _hydratedSig = null;
      });
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(context, '${ApiErrorsContent.deleteFailedPrefix}$e');
      }
    }
  }

  void _zoomBy(double factor) {
    final m = Matrix4.copy(_tc.value);
    final current = m.getMaxScaleOnAxis();
    final next = (current * factor).clamp(0.2, 2.5);
    final f = next / current;
    m.scale(f, f, 1);
    _tc.value = m;
  }

  void _fitToScreen(Size viewport) {
    if (_positions.isEmpty) {
      _tc.value = Matrix4.identity();
      return;
    }
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final o in _positions.values) {
      minX = math.min(minX, o.dx);
      minY = math.min(minY, o.dy);
      maxX = math.max(maxX, o.dx + _kNodeW);
      maxY = math.max(maxY, o.dy + _kNodeH);
    }
    final w = math.max(320, maxX - minX);
    final h = math.max(240, maxY - minY);
    final sx = (viewport.width * 0.85) / w;
    final sy = (viewport.height * 0.85) / h;
    final scale = math.min(sx, sy).clamp(0.2, 2.5);
    final tx = (viewport.width - w * scale) / 2 - minX * scale;
    final ty = (viewport.height - h * scale) / 2 - minY * scale;
    _tc.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale, scale, 1);
  }

  int _zoomPercent() => (_tc.value.getMaxScaleOnAxis() * 100).round();

  String _stageTypeLabel(String? t) {
    switch (t) {
      case OrgSettingsPipelineBuilderContent.stageTypeTrigger:
        return OrgSettingsPipelineBuilderContent.nodeMetadataTrigger;
      case OrgSettingsPipelineBuilderContent.stageTypeAction:
        return OrgSettingsPipelineBuilderContent.nodeMetadataAction;
      default:
        return OrgSettingsPipelineBuilderContent.nodeMetadataStage;
    }
  }

  IconData _stageTypeIcon(String? t) {
    switch (t) {
      case OrgSettingsPipelineBuilderContent.stageTypeTrigger:
        return Icons.play_circle_outline;
      case OrgSettingsPipelineBuilderContent.stageTypeAction:
        return Icons.check_circle_outline;
      default:
        return Icons.view_kanban_outlined;
    }
  }

  Color _colorKeyColor(String? key, BuildContext context) {
    final c = context.colors;
    switch (key) {
      case 'green':
        return c.secondary;
      case 'amber':
        return c.warning;
      case 'error':
        return c.error;
      case 'muted':
        return c.outline;
      default:
        return c.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final stagesAsync = ref.watch(pipelineStagesProvider(widget.pipelineId));
    final edgesAsync = ref.watch(pipelineEdgesProvider(widget.pipelineId));

    final stages = stagesAsync.when(
      data: (s) => s,
      error: (_, __) => <Map<String, dynamic>>[],
      loading: () => <Map<String, dynamic>>[],
    );
    final edgeRows = edgesAsync.when(
      data: (e) => e,
      error: (_, __) => <Map<String, dynamic>>[],
      loading: () => <Map<String, dynamic>>[],
    );

    if (_draggingNodeId == null && _wireFromId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hydrate(stages, edgeRows);
      });
    }

    return LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 560;
                final stageById = {
                  for (final s in stages)
                    if (s['id'] != null) s['id'].toString(): s,
                };

                return ClipRect(
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  constrained: false,
                                  transformationController: _tc,
                                  boundaryMargin: const EdgeInsets.all(_kCanvas),
                                  minScale: 0.2,
                                  maxScale: 2.5,
                                  child: Listener(
                                    behavior: HitTestBehavior.translucent,
                                    onPointerMove: (e) {
                                      if (_wireFromId == null) return;
                                      final box =
                                          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                                      if (box == null) return;
                                      final local = box.globalToLocal(e.position);
                                      setState(() {
                                        _wirePreviewEndCanvas = local;
                                      });
                                    },
                                    onPointerUp: (e) {
                                      if (_wireFromId == null) return;
                                      final box =
                                          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                                      if (box == null) return;
                                      final pos = box.globalToLocal(e.position);
                                      String? hit;
                                      for (final s in stages) {
                                        final id = s['id']?.toString();
                                        if (id == null || id == _wireFromId) continue;
                                        final p = _positions[id];
                                        if (p == null) continue;
                                        final ic = Offset(p.dx, p.dy + _kNodeH / 2);
                                        if ((pos - ic).distance < 22) {
                                          hit = id;
                                          break;
                                        }
                                      }
                                      if (hit != null) {
                                        _addEdge(_wireFromId!, hit);
                                      }
                                      setState(() {
                                        _wireFromId = null;
                                        _wirePreviewEndCanvas = null;
                                      });
                                    },
                                    onPointerCancel: (_) {
                                      if (_wireFromId == null) return;
                                      setState(() {
                                        _wireFromId = null;
                                        _wirePreviewEndCanvas = null;
                                      });
                                    },
                                    child: SizedBox(
                                      key: _canvasKey,
                                      width: _kCanvas,
                                      height: _kCanvas,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CustomPaint(
                                            size: const Size(_kCanvas, _kCanvas),
                                            painter: _DotGridPainter(
                                              background:
                                                  Theme.of(context).brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xFF0B1E33)
                                                      : const Color(0xFFF8F9FA),
                                              dotColor: Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white.withValues(alpha: 0.28)
                                                  : c.outline.withValues(alpha: 0.52),
                                              spacing: _kGrid,
                                            ),
                                          ),
                                          CustomPaint(
                                            size: const Size(_kCanvas, _kCanvas),
                                            painter: _WiresPainter(
                                              edges: _edges,
                                              portOut: _portOut,
                                              portIn: _portIn,
                                              wireColor: c.primary,
                                              selectedId: _selectedEdgeId,
                                            ),
                                          ),
                                          if (_wireFromId != null && _wirePreviewEndCanvas != null)
                                            CustomPaint(
                                              size: const Size(_kCanvas, _kCanvas),
                                              painter: _PreviewWirePainter(
                                                start: _portOut(_wireFromId!),
                                                end: _wirePreviewEndCanvas!,
                                                color: c.primary,
                                              ),
                                            ),
                                          for (final e in _edges)
                                            Positioned(
                                              left: _edgeMid(e).dx - 22,
                                              top: _edgeMid(e).dy - 22,
                                              width: 44,
                                              height: 44,
                                              child: _selectedEdgeId == e.id
                                                  ? IconButton(
                                                      tooltip: OrgSettingsPipelineBuilderContent
                                                          .wireDeleteA11y,
                                                      icon: Icon(Icons.close, color: c.error, size: 20),
                                                      onPressed: () => _confirmRemoveEdge(e.id),
                                                    )
                                                  : GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () => setState(() {
                                                        _selectedEdgeId = e.id;
                                                        _selectedNodeId = null;
                                                        ref.read(selectedNodeProvider.notifier).state =
                                                            null;
                                                      }),
                                                      child: const SizedBox.expand(),
                                                    ),
                                            ),
                                          for (final s in stages)
                                            _buildNode(
                                              s,
                                              stageById,
                                              c,
                                              tt,
                                              narrow,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: BlackLightSpacing.sm,
                                  top: BlackLightSpacing.sm,
                                  child: _FloatingToolbar(
                                    zoomPercent: _zoomPercent(),
                                    onAddStage: () => _addStageWithType(
                                      OrgSettingsPipelineBuilderContent.stageTypeStage,
                                      OrgSettingsPipelineBuilderContent.newStageDefaultName,
                                    ),
                                    onAddTrigger: () => _addStageWithType(
                                      OrgSettingsPipelineBuilderContent.stageTypeTrigger,
                                      OrgSettingsPipelineBuilderContent.newTriggerDefaultName,
                                    ),
                                    onAddAction: () => _addStageWithType(
                                      OrgSettingsPipelineBuilderContent.stageTypeAction,
                                      OrgSettingsPipelineBuilderContent.newActionDefaultName,
                                    ),
                                    onZoomOut: () => _zoomBy(1 / 1.12),
                                    onZoomIn: () => _zoomBy(1.12),
                                    onFit: () => _fitToScreen(
                                      Size(constraints.maxWidth, constraints.maxHeight),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!narrow && _selectedNodeId != null)
                            _PropertiesSidebar(
                              width: 320,
                              stage: stageById[_selectedNodeId],
                              pipelineId: widget.pipelineId,
                              onClose: () => setState(() {
                                _selectedNodeId = null;
                                ref.read(selectedNodeProvider.notifier).state = null;
                              }),
                              onSaved: () {
                                ref.invalidate(pipelineStagesProvider(widget.pipelineId));
                              },
                              onDebouncedField: (field) {
                                _propTimer?.cancel();
                                _propTimer = Timer(const Duration(milliseconds: 500), field);
                              },
                            ),
                        ],
                      ),
                      if (narrow)
                        Positioned(
                          left: BlackLightSpacing.gutter,
                          right: BlackLightSpacing.gutter,
                          bottom: 8,
                          child: Text(
                            OrgSettingsPipelineBuilderContent.flowMeshCanvasHint,
                            style: tt.bodySmall?.copyWith(color: c.onSurfaceMuted),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
  }

  Widget _buildNode(
    Map<String, dynamic> s,
    Map<String, Map<String, dynamic>> stageById,
    BlackLightPalette c,
    TextTheme tt,
    bool narrow,
  ) {
    final id = s['id']?.toString() ?? '';
    if (id.isEmpty) return const SizedBox.shrink();
    final pos = _positions[id] ?? Offset.zero;
    final name = (s['name'] ?? OrgSettingsPipelineBuilderContent.defaultPipelineName).toString();
    final st = (s['stage_type'] ?? s['stageType'] ?? OrgSettingsPipelineBuilderContent.stageTypeStage)
        .toString();
    final meta = _stageTypeLabel(st);
    final trigger = (s['trigger'] ?? s['trigger_condition'] ?? '').toString();
    final bodyLine = trigger.isNotEmpty ? trigger : meta;
    final colorKey = (s['color_key'] ?? s['colorKey'] ?? 'primary').toString();
    final selected = _selectedNodeId == id;
    final accentLeft = _colorKeyColor(colorKey, context);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: _kNodeW,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedNodeId = id;
            _selectedEdgeId = null;
            ref.read(selectedNodeProvider.notifier).state = id;
          });
          if (narrow) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                builder: (ctx) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: _PropertiesPanelBody(
                    stage: s,
                    pipelineId: widget.pipelineId,
                    onClose: () => Navigator.pop(ctx),
                    onSaved: () {
                      ref.invalidate(pipelineStagesProvider(widget.pipelineId));
                    },
                    onDebouncedField: (fn) {
                      _propTimer?.cancel();
                      _propTimer = Timer(const Duration(milliseconds: 500), fn);
                    },
                  ),
                ),
              );
            });
          }
        },
        onLongPressMoveUpdate: (details) {
          if (_draggingNodeId != id) return;
          final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;
          final posCanvas = box.globalToLocal(details.globalPosition);
          if (_dragNodePointer == null) {
            _dragNodePointer = posCanvas;
            return;
          }
          final delta = posCanvas - _dragNodePointer!;
          _dragNodePointer = posCanvas;
          setState(() {
            _positions[id] = (_positions[id] ?? Offset.zero) + delta;
          });
        },
        onLongPressStart: (_) {
          setState(() {
            _draggingNodeId = id;
            _dragNodePointer = null;
          });
        },
        onLongPressEnd: (_) {
          setState(() {
            _draggingNodeId = null;
            _dragNodePointer = null;
          });
          _debouncedSavePosition(id);
        },
        child: Material(
          color: c.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected ? c.primary : c.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: accentLeft, width: 4),
              ),
            ),
            child: SizedBox(
              height: _kNodeH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(_stageTypeIcon(st), size: 18, color: c.onSurfaceMuted),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bodyLine,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 12,
                            color: c.onSurfaceMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (st != OrgSettingsPipelineBuilderContent.stageTypeTrigger)
                    Positioned(
                      left: -_kPort / 2,
                      top: _kNodeH / 2 - _kPort / 2,
                      child: _PortDot(
                        connected: _edges.any((e) => e.targetId == id),
                        accent: c.primary,
                        outline: c.outline,
                      ),
                    ),
                  if (st != OrgSettingsPipelineBuilderContent.stageTypeAction)
                    Positioned(
                      right: -_kPort / 2,
                      top: _kNodeH / 2 - _kPort / 2,
                      child: GestureDetector(
                        onLongPressStart: (_) {
                          setState(() {
                            _wireFromId = id;
                            _wirePreviewEndCanvas = _portOut(id);
                          });
                        },
                        child: _PortDot(
                          connected: _edges.any((e) => e.sourceId == id),
                          accent: c.primary,
                          outline: c.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortDot extends StatelessWidget {
  const _PortDot({
    required this.connected,
    required this.accent,
    required this.outline,
  });

  final bool connected;
  final Color accent;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kPort,
      height: _kPort,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? accent : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: outline),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
    required this.background,
    required this.dotColor,
    required this.spacing,
  });

  final Color background;
  final Color dotColor;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final p = Paint()..color = dotColor;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) =>
      old.background != background || old.dotColor != dotColor || old.spacing != spacing;
}

class _WiresPainter extends CustomPainter {
  _WiresPainter({
    required this.edges,
    required this.portOut,
    required this.portIn,
    required this.wireColor,
    required this.selectedId,
  });

  final List<FlowMeshEdge> edges;
  final Offset Function(String) portOut;
  final Offset Function(String) portIn;
  final Color wireColor;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = wireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;
    for (final e in edges) {
      final path = Path()
        ..moveTo(portOut(e.sourceId).dx, portOut(e.sourceId).dy)
        ..cubicTo(
          portOut(e.sourceId).dx + _kBezierPad,
          portOut(e.sourceId).dy,
          portIn(e.targetId).dx - _kBezierPad,
          portIn(e.targetId).dy,
          portIn(e.targetId).dx,
          portIn(e.targetId).dy,
        );
      if (e.id == selectedId) {
        stroke.strokeWidth = 3;
        canvas.drawPath(path, stroke);
        stroke.strokeWidth = 2;
      } else {
        canvas.drawPath(path, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WiresPainter old) =>
      old.edges != edges || old.selectedId != selectedId || old.wireColor != wireColor;
}

class _PreviewWirePainter extends CustomPainter {
  _PreviewWirePainter({
    required this.start,
    required this.end,
    required this.color,
  });

  final Offset start;
  final Offset end;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _dashBezier(canvas, p, start, end);
  }

  void _dashBezier(Canvas canvas, Paint paint, Offset a, Offset b) {
    final c1 = Offset(a.dx + _kBezierPad, a.dy);
    final c2 = Offset(b.dx - _kBezierPad, b.dy);
    const segments = 40;
    Offset? prev;
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final pt = _bp(a, c1, c2, b, t);
      if (prev != null) {
        if (i % 3 != 0) {
          canvas.drawLine(prev, pt, paint);
        }
      }
      prev = pt;
    }
  }

  Offset _bp(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx,
      u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _PreviewWirePainter old) =>
      old.start != start || old.end != end || old.color != color;
}

class _FloatingToolbar extends StatelessWidget {
  const _FloatingToolbar({
    required this.zoomPercent,
    required this.onAddStage,
    required this.onAddTrigger,
    required this.onAddAction,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onFit,
  });

  final int zoomPercent;
  final VoidCallback onAddStage;
  final VoidCallback onAddTrigger;
  final VoidCallback onAddAction;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final card = BoxDecoration(
      color: c.surface,
      border: Border.all(color: c.outline),
      borderRadius: BorderRadius.circular(BlackLightRadius.sm),
    );
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: card,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: onAddStage,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: c.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    OrgSettingsPipelineBuilderContent.toolbarAddStage,
                    style: tt.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: onAddTrigger,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.onSurface,
                    side: BorderSide(color: c.outline),
                    elevation: 0,
                  ),
                  child: Text(
                    OrgSettingsPipelineBuilderContent.toolbarAddTrigger,
                    style: tt.labelLarge?.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: onAddAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.onSurface,
                    side: BorderSide(color: c.outline),
                    elevation: 0,
                  ),
                  child: Text(
                    OrgSettingsPipelineBuilderContent.toolbarAddAction,
                    style: tt.labelLarge?.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: card,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: OrgSettingsPipelineBuilderContent.toolbarZoomOut,
                  onPressed: onZoomOut,
                  icon: Icon(Icons.remove, color: c.onSurface, size: 18),
                ),
                Container(width: 1, height: 22, color: c.outline),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '$zoomPercent${OrgSettingsPipelineBuilderContent.toolbarZoomPercentSuffix}',
                    style: tt.bodySmall,
                  ),
                ),
                Container(width: 1, height: 22, color: c.outline),
                IconButton(
                  tooltip: OrgSettingsPipelineBuilderContent.toolbarZoomIn,
                  onPressed: onZoomIn,
                  icon: Icon(Icons.add, color: c.onSurface, size: 18),
                ),
                Container(width: 1, height: 22, color: c.outline),
                IconButton(
                  tooltip: OrgSettingsPipelineBuilderContent.toolbarFitToScreen,
                  onPressed: onFit,
                  icon: Icon(Icons.fit_screen, color: c.onSurface, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertiesSidebar extends StatelessWidget {
  const _PropertiesSidebar({
    required this.width,
    required this.stage,
    required this.pipelineId,
    required this.onClose,
    required this.onSaved,
    required this.onDebouncedField,
  });

  final double width;
  final Map<String, dynamic>? stage;
  final String pipelineId;
  final VoidCallback onClose;
  final VoidCallback onSaved;
  final void Function(Future<void> Function()) onDebouncedField;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(left: BorderSide(color: c.outline)),
      ),
      child: stage == null
          ? const SizedBox.shrink()
          : _PropertiesPanelBody(
              stage: stage,
              pipelineId: pipelineId,
              onClose: onClose,
              onSaved: onSaved,
              onDebouncedField: onDebouncedField,
            ),
    );
  }
}

class _PropertiesPanelBody extends ConsumerStatefulWidget {
  const _PropertiesPanelBody({
    required this.stage,
    required this.pipelineId,
    required this.onClose,
    required this.onSaved,
    required this.onDebouncedField,
  });

  final Map<String, dynamic>? stage;
  final String pipelineId;
  final VoidCallback onClose;
  final VoidCallback onSaved;
  final void Function(Future<void> Function()) onDebouncedField;

  @override
  ConsumerState<_PropertiesPanelBody> createState() => _PropertiesPanelBodyState();
}

class _PropertiesPanelBodyState extends ConsumerState<_PropertiesPanelBody> {
  late TextEditingController _nameCtrl;
  String _eventValue = 'webhook';
  String _colorKey = 'primary';

  @override
  void initState() {
    super.initState();
    final s = widget.stage ?? {};
    _nameCtrl = TextEditingController(text: (s['name'] ?? '').toString());
    _eventValue = _eventFromStage(s);
    _colorKey = (s['color_key'] ?? s['colorKey'] ?? 'primary').toString();
  }

  @override
  void didUpdateWidget(covariant _PropertiesPanelBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage?['id'] != widget.stage?['id']) {
      final s = widget.stage ?? {};
      _nameCtrl.text = (s['name'] ?? '').toString();
      _eventValue = _eventFromStage(s);
      _colorKey = (s['color_key'] ?? s['colorKey'] ?? 'primary').toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _eventFromStage(Map<String, dynamic> s) {
    final raw = (s['event_type'] ?? s['eventType'] ?? '').toString();
    if (raw == 'api' || raw.contains('API')) return 'api';
    if (raw == 'manual' || raw.contains('Manual')) return 'manual';
    return 'webhook';
  }

  Map<String, String> _eventToApi(String v) {
    switch (v) {
      case 'api':
        return {'event_type': 'api', 'trigger_condition': OrgSettingsPipelineBuilderContent.eventTypeApi};
      case 'manual':
        return {'event_type': 'manual', 'trigger_condition': OrgSettingsPipelineBuilderContent.eventTypeManual};
      default:
        return {'event_type': 'webhook', 'trigger_condition': OrgSettingsPipelineBuilderContent.eventTypeWebhook};
    }
  }

  Future<void> _persist() async {
    final id = widget.stage?['id']?.toString();
    if (id == null || id.isEmpty) return;
    final body = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'color_key': _colorKey,
      ..._eventToApi(_eventValue),
    };
    try {
      await ref.read(apiProvider).updateStage(widget.pipelineId, id, body);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(context, '${ApiErrorsContent.saveFailedPrefix}$e');
      }
    }
  }

  Future<void> _delete() async {
    final id = widget.stage?['id']?.toString();
    if (id == null) return;
    final ok = await AppFeedback.showConfirmDialog(
      context,
      title: OrgSettingsPipelineBuilderContent.deleteStageTooltip,
      message: OrgSettingsPipelineBuilderContent.deleteNodeConfirmBody,
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(apiProvider).deleteStage(widget.pipelineId, id);
      widget.onClose();
      widget.onSaved();
      ref.invalidate(pipelineEdgesProvider(widget.pipelineId));
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(context, '${ApiErrorsContent.deleteFailedPrefix}$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stage == null) return const SizedBox.shrink();
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    OrgSettingsPipelineBuilderContent.panelTitle,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              IconButton(
                tooltip: OrgSettingsPipelineBuilderContent.panelCloseA11y,
                onPressed: widget.onClose,
                icon: Icon(Icons.close, color: c.onSurfaceMuted),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: c.outline),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                OrgSettingsPipelineBuilderContent.panelNodeNameLabel,
                style: tt.labelMedium?.copyWith(color: c.onSurfaceMuted),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                onChanged: (_) => widget.onDebouncedField(_persist),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BlackLightRadius.input),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                OrgSettingsPipelineBuilderContent.panelEventTypeLabel,
                style: tt.labelMedium?.copyWith(color: c.onSurfaceMuted),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _eventValue,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BlackLightRadius.input),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'webhook',
                    child: Text(OrgSettingsPipelineBuilderContent.eventTypeWebhook),
                  ),
                  DropdownMenuItem(
                    value: 'api',
                    child: Text(OrgSettingsPipelineBuilderContent.eventTypeApi),
                  ),
                  DropdownMenuItem(
                    value: 'manual',
                    child: Text(OrgSettingsPipelineBuilderContent.eventTypeManual),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _eventValue = v);
                  widget.onDebouncedField(_persist);
                },
              ),
              const SizedBox(height: 20),
              Text(
                OrgSettingsPipelineBuilderContent.panelColorLabel,
                style: tt.labelMedium?.copyWith(color: c.onSurfaceMuted),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  _colorCircle(context, 'primary', c.primary),
                  _colorCircle(context, 'green', c.secondary),
                  _colorCircle(context, 'amber', c.warning),
                  _colorCircle(context, 'error', c.error),
                  _colorCircle(context, 'muted', c.outline),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _delete,
            style: OutlinedButton.styleFrom(
              foregroundColor: c.error,
              side: BorderSide(color: c.error),
            ),
            icon: Icon(Icons.delete_outline, color: c.error),
            label: Text(OrgSettingsPipelineBuilderContent.panelDeleteNode),
          ), 
        ),
      ],
    );
  }

  Widget _colorCircle(BuildContext context, String key, Color fill) {
    final on = _colorKey == key;
    final ring = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () {
        setState(() => _colorKey = key);
        widget.onDebouncedField(_persist);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(
            color: on ? ring : context.colors.outline.withValues(alpha: 0.4),
            width: on ? 2 : 1,
          ),
        ),
      ),
    );
  }
}
