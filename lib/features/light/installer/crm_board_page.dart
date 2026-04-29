import 'dart:convert';

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/design_mode_wrapper.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CRM Kanban — theme-aware (Light for free org, dark when wrapped in premium Theme).
class CrmBoardPage extends ConsumerStatefulWidget {
  const CrmBoardPage({super.key});

  @override
  ConsumerState<CrmBoardPage> createState() => _CrmBoardPageState();
}

class _CrmBoardPageState extends ConsumerState<CrmBoardPage> {
  String? _pipelineId;
  List<Map<String, dynamic>> _stages = const [];
  Map<String, List<Map<String, dynamic>>> _dealsByStage = {};
  bool _loadingBoard = false;

  Future<void> _load(String pipelineId) async {
    setState(() => _loadingBoard = true);
    final api = ref.read(apiProvider);
    final stages = await api.getStages(pipelineId);
    final allDeals = await api.getDeals(pipelineId);
    final byStage = <String, List<Map<String, dynamic>>>{};
    for (final s in stages) {
      final sid = s['id']?.toString() ?? '';
      if (sid.isEmpty) continue;
      byStage[sid] = allDeals
          .where(
            (d) =>
                (d['stage_id'] ?? d['stageId'] ?? '').toString() == sid,
          )
          .toList();
    }
    if (!mounted) return;
    setState(() {
      _stages = stages;
      _dealsByStage = byStage;
      _loadingBoard = false;
    });
  }

  Future<void> _swapStages(int a, int b) async {
    if (_pipelineId == null) return;
    final next = [..._stages];
    final tmp = next[a];
    next[a] = next[b];
    next[b] = tmp;
    setState(() => _stages = next);
    try {
      await ref.read(apiProvider).reorderStages(
            _pipelineId!,
            next
                .map((e) => e['id']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList(),
          );
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(
          context,
          '${ApiErrorsContent.reorderFailedPrefix}$e',
        );
      }
      await _load(_pipelineId!);
    }
  }

  Future<void> _openDeal(BuildContext context, Map<String, dynamic> d) async {
    final id = d['id']?.toString() ?? '';
    try {
      final full = await ref.read(apiProvider).getDeal(id);
      if (!context.mounted) return;
      final payload =
          full['custom_fields'] ?? full['customFields'] ?? full;
      final tt = Theme.of(context).textTheme;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            (full['title'] ?? full['name'] ?? OrgCrmDealContent.dealFallbackTitle)
                .toString(),
            style: tt.headlineSmall,
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: SelectableText(
                _encodeDealPayload(payload),
                style: tt.bodyMedium?.copyWith(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ButtonsContent.close),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        AppFeedback.snack(
          context,
          '${ApiErrorsContent.openDealFailedPrefix}$e',
        );
      }
    }
  }

  int _totalDealCount() {
    var n = 0;
    for (final e in _dealsByStage.values) {
      n += e.length;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final pipes = ref.watch(pipelinesProvider);
    final design = ref.watch(designModeProvider).valueOrNull ?? false;

    ref.listen<AsyncValue<List<Map<String, dynamic>>>>(pipelinesProvider,
        (prev, next) {
      next.whenData((items) {
        if (items.isEmpty || _pipelineId != null) return;
        final id = items.first['id']?.toString();
        if (id == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _pipelineId = id);
          _load(id);
        });
      });
    });

    return ColoredBox(
      color: c.scaffold,
      child: pipes.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: c.primary),
        ),
        error: (e, _) => Center(
          child: Text(e.toString(), style: tt.bodyMedium),
        ),
        data: (items) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BlackLightSpacing.gutter,
                  BlackLightSpacing.gutter,
                  BlackLightSpacing.gutter,
                  BlackLightSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            OrgCrmBoardContent.webPipelineHeader,
                            style: tt.headlineSmall,
                          ),
                        ),
                        if (items.isNotEmpty)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: DropdownButtonFormField<String>(
                              value: _pipelineId,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    BlackLightRadius.input,
                                  ),
                                ),
                              ),
                              dropdownColor: c.surface,
                              style: tt.bodyMedium,
                              items: [
                                for (final p in items)
                                  DropdownMenuItem<String>(
                                    value: p['id']?.toString(),
                                    child: Text(
                                      (p['name'] ??
                                              OrgSettingsPipelineBuilderContent
                                                  .defaultPipelineName)
                                          .toString(),
                                    ),
                                  ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _pipelineId = v;
                                  _stages = const [];
                                  _dealsByStage = {};
                                });
                                if (v != null) _load(v);
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      OrgCrmBoardContent.webPipelineSubtitle,
                      style: tt.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceMuted,
                        borderRadius:
                            BorderRadius.circular(BlackLightRadius.sm),
                        border: Border.all(color: c.outline),
                      ),
                      child: Text(
                        design
                            ? OrgCrmBoardContent.designModeHint
                            : OrgCrmBoardContent.liveModeHint,
                        style: tt.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: BlackLightSpacing.sm,
                      runSpacing: BlackLightSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              AppFeedback.showAddLeadDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(OrgCrmBoardContent.addLeadFab),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pipelineId == null
                              ? null
                              : () => _load(_pipelineId!),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(OrgCrmBoardContent.refreshBoard),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _pipelineId == null
                    ? Center(
                        child: Text(
                          OrgCrmBoardContent.createPipelineHint,
                          style: tt.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _loadingBoard
                        ? Center(
                            child: CircularProgressIndicator(
                              color: c.primary,
                            ),
                          )
                        : _totalDealCount() == 0 && _stages.isNotEmpty
                            ? _EmptyBoardState(colors: c, textTheme: tt)
                            : LayoutBuilder(
                                builder: (ctx, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.fromLTRB(
                                      BlackLightSpacing.gutter,
                                      0,
                                      BlackLightSpacing.gutter,
                                      BlackLightSpacing.gutter,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var i = 0;
                                            i < _stages.length;
                                            i++)
                                          _StageColumn(
                                            colors: c,
                                            textTheme: tt,
                                            designMode: design,
                                            stage: _stages[i],
                                            deals: _dealsByStage[
                                                    _stages[i]['id']
                                                            ?.toString() ??
                                                        ''] ??
                                                const [],
                                            columnHeight:
                                                constraints.maxHeight - 8,
                                            onMoveLeft: design && i > 0
                                                ? () => _swapStages(i, i - 1)
                                                : null,
                                            onMoveRight: design &&
                                                    i < _stages.length - 1
                                                ? () =>
                                                    _swapStages(i, i + 1)
                                                : null,
                                            onOpenDeal: (d) =>
                                                _openDeal(context, d),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyBoardState extends StatelessWidget {
  const _EmptyBoardState({
    required this.colors,
    required this.textTheme,
  });

  final BlackLightPalette colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EmptyHouseIllustration(),
            const SizedBox(height: BlackLightSpacing.md),
            Text(
              OrgCrmBoardContent.emptyDealsTitle,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              OrgCrmBoardContent.emptyDealsSubtitle,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StageColumn extends StatelessWidget {
  const _StageColumn({
    required this.colors,
    required this.textTheme,
    required this.designMode,
    required this.stage,
    required this.deals,
    required this.columnHeight,
    required this.onOpenDeal,
    this.onMoveLeft,
    this.onMoveRight,
  });

  final BlackLightPalette colors;
  final TextTheme textTheme;
  final bool designMode;
  final Map<String, dynamic> stage;
  final List<Map<String, dynamic>> deals;
  final double columnHeight;
  final void Function(Map<String, dynamic>) onOpenDeal;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  @override
  Widget build(BuildContext context) {
    final sid = stage['id']?.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.only(right: BlackLightSpacing.md),
      child: DesignModeWrapper(
        sectionId: 'crm_stage_$sid',
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BlackLightRadius.card),
            side: BorderSide(color: colors.outline),
          ),
          child: SizedBox(
            width: 296,
            height: columnHeight.clamp(320, 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (stage['name'] ?? CommonContent.fallbackStage)
                              .toString(),
                          style: textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Text(
                          '${deals.length}',
                          style: textTheme.labelSmall,
                        ),
                      ),
                      if (designMode) ...[
                        IconButton(
                          onPressed: onMoveLeft,
                          icon: Icon(Icons.chevron_left, color: colors.primary),
                        ),
                        IconButton(
                          onPressed: onMoveRight,
                          icon: Icon(Icons.chevron_right, color: colors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.outline),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: deals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      return _DealCard(
                        colors: colors,
                        textTheme: textTheme,
                        deal: deals[i],
                        designMode: designMode,
                        onTap: designMode ? null : () => onOpenDeal(deals[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.colors,
    required this.textTheme,
    required this.deal,
    required this.designMode,
    this.onTap,
  });

  final BlackLightPalette colors;
  final TextTheme textTheme;
  final Map<String, dynamic> deal;
  final bool designMode;
  final VoidCallback? onTap;

  String get _name =>
      (deal['title'] ?? deal['name'] ?? OrgCrmDealContent.dealFallbackTitle)
          .toString();

  String get _address =>
      (deal['address'] ?? deal['street'] ?? CommonContent.emDash).toString();

  String _dealSizeLine() {
    final kw = deal['estimated_kw'] ??
        deal['estimatedKw'] ??
        deal['system_size_kw'] ??
        deal['systemSizeKw'];
    if (kw != null) {
      return '$kw${OrgCrmBoardContent.kwSuffix}';
    }
    final v = deal['value'] ?? deal['amount'];
    if (v != null) return v.toString();
    return CommonContent.emDash;
  }

  String _statusLabel() {
    final s = deal['status'] ?? deal['stage_name'] ?? deal['stage'];
    return s?.toString() ?? CommonContent.fallbackDeal;
  }

  Color _statusColor() {
    final s = _statusLabel().toLowerCase();
    if (s.contains('won') || s.contains('closed')) {
      return colors.secondary;
    }
    if (s.contains('lost')) return colors.error;
    if (s.contains('quot')) return colors.warning;
    return colors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: colors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.md),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(BlackLightRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (designMode) ...[
                    Icon(Icons.drag_indicator,
                        size: 18, color: colors.outline),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      _name,
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: colors.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _address,
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    OrgCrmBoardContent.dealSizeLabel.toUpperCase(),
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dealSizeLine(),
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${OrgCrmBoardContent.statusLabel}: ${_statusLabel()}',
                style: textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );

    if (designMode) {
      return Opacity(opacity: 0.95, child: body);
    }
    return body;
  }
}

String _encodeDealPayload(Object? payload) {
  try {
    if (payload is Map || payload is List) {
      return JsonEncoder.withIndent('  ').convert(payload);
    }
  } catch (_) {}
  return payload?.toString() ?? '';
}
