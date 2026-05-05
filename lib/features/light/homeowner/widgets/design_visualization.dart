import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/illustrations/geometric_illustrations.dart';
import 'package:limye_app/theme/limye_theme.dart';

/// Right-rail (desktop) or full-screen preview (mobile): empty vs active design.
class DesignVisualization extends StatelessWidget {
  const DesignVisualization({
    super.key,
    required this.hasDesign,
    this.compact = false,
  });

  final bool hasDesign;

  /// Tighter padding for bottom sheets.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!hasDesign) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? LimyeSpacing.md : LimyeSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SunRingsIllustration(
                size: compact ? 220 : 320,
              ),
              SizedBox(height: compact ? LimyeSpacing.md : LimyeSpacing.lg),
              Text(
                AiChatContent.vizEmptyTitle,
                textAlign: TextAlign.center,
                style: LimyeTextStyles.body(
                  color: context.colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(LimyeSpacing.lg),
              child: LayoutBuilder(
                builder: (context, c) {
                  final side = math.min(
                    400.0,
                    math.min(c.maxWidth * 0.55, c.maxHeight * 0.5),
                  );
                  return _SkewedPanelGrid(
                    width: side * 1.35,
                    height: side * 0.95,
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: compact ? LimyeSpacing.sm : LimyeSpacing.md,
          right: compact ? LimyeSpacing.sm : LimyeSpacing.md,
          child: _MetricsCard(compact: compact),
        ),
        Positioned(
          bottom: compact ? LimyeSpacing.sm : LimyeSpacing.md,
          left: compact ? LimyeSpacing.sm : LimyeSpacing.md,
          child: const _LegendRow(),
        ),
      ],
    );
  }
}

class _SkewedPanelGrid extends StatelessWidget {
  const _SkewedPanelGrid({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(-0.12)
        ..setEntry(0, 1, -0.32),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.onSurface,
          border: Border.all(color: context.colors.outline, width: 1),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(0, 1, 0.32),
          child: Padding(
            padding: const EdgeInsets.all(LimyeSpacing.sm),
            child: LayoutBuilder(
              builder: (context, c) {
                const cols = 6;
                const rows = 3;
                final gap = LimyeSpacing.xs / 2;
                final cellH = (c.maxHeight - gap * (rows - 1)) / rows;
                final cellW = (c.maxWidth - gap * (cols - 1)) / cols;
                final cells = <Widget>[];
                for (var i = 0; i < 18; i++) {
                  cells.add(
                    Container(
                      width: cellW,
                      height: cellH,
                      decoration: BoxDecoration(
                        color:
                            context.colors.primary.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: context.colors.surface,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: cells,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? LimyeSpacing.sm : LimyeSpacing.md;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(LimyeRadius.card),
          border: Border.all(color: context.colors.outline, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _metricRow(
              context,
              AiChatContent.vizMetricSystemSize,
              AiChatContent.vizDemoSystemSize,
              border: true,
            ),
            _metricRow(
              context,
              AiChatContent.vizMetricPanels,
              AiChatContent.vizDemoPanels,
              border: true,
            ),
            _metricRow(
              context,
              AiChatContent.vizMetricSavings,
              AiChatContent.vizDemoSavings,
              border: false,
              valueColor: context.colors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(
    BuildContext context,
    String label,
    String value, {
    required bool border,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: border ? LimyeSpacing.sm : 0,
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: border ? LimyeSpacing.sm : 0),
        decoration: border
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.colors.outline.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: LimyeTextStyles.caption(
                  color: context.colors.onSurfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: LimyeSpacing.sm),
            Text(
              value,
              style: LimyeTextStyles.data(
                color: valueColor ?? context.colors.onSurface,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LimyeSpacing.sm,
        vertical: LimyeSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendSwatch(
            color: context.colors.secondary,
            label: AiChatContent.vizLegendIdeal,
          ),
          SizedBox(width: LimyeSpacing.md),
          _LegendSwatch(
            color: context.colors.primary,
            label: AiChatContent.vizLegendGood,
          ),
          SizedBox(width: LimyeSpacing.md),
          _LegendSwatch(
            color: context.colors.outline,
            label: AiChatContent.vizLegendUnused,
          ),
        ],
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: LimyeSpacing.sm,
          height: LimyeSpacing.sm,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: LimyeSpacing.xs / 2),
        Text(
          label,
          style: LimyeTextStyles.caption(
            color: context.colors.onSurfaceMuted,
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
