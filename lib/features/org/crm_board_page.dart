import 'dart:convert';

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_mode_wrapper.dart';
import '../../core/providers/org_providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/ui/app_feedback.dart';
import '../../theme/blacklight_theme.dart';

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
      if (mounted) AppFeedback.snack(context, '${ApiErrorsContent.reorderFailedPrefix}$e');
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
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            (full['title'] ?? full['name'] ?? OrgCrmDealContent.dealFallbackTitle).toString(),
            style: BlackLightTextStyles.cardHeading(),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: SelectableText(
                _encodeDealPayload(payload),
                style: BlackLightTextStyles.data(),
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
        AppFeedback.snack(context, '${ApiErrorsContent.openDealFailedPrefix}$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return pipes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                BlackLightSpacing.gutter,
                BlackLightSpacing.gutter,
                BlackLightSpacing.gutter,
                0,
              ),
              child: Row(
                children: [
                  Text(OrgCrmBoardContent.pageTitle, style: BlackLightTextStyles.sectionHeading()),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _pipelineId,
                    items: [
                      for (final p in items)
                        DropdownMenuItem<String>(
                          value: p['id']?.toString(),
                          child: Text((p['name'] ?? OrgSettingsPipelineBuilderContent.defaultPipelineName).toString()),
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
                ],
              ),
            ),
            Expanded(
              child: _pipelineId == null
                  ? Center(
                      child: Text(
                        OrgCrmBoardContent.createPipelineHint,
                        style: BlackLightTextStyles.body(),
                      ),
                    )
                  : _loadingBoard
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(
                            BlackLightSpacing.gutter,
                          ),
                          children: [
                            for (var i = 0; i < _stages.length; i++)
                              _ColumnCard(
                                designMode: design,
                                stage: _stages[i],
                                deals: _dealsByStage[
                                        _stages[i]['id']?.toString() ?? ''] ??
                                    const [],
                                onMoveLeft: design && i > 0
                                    ? () => _swapStages(i, i - 1)
                                    : null,
                                onMoveRight: design && i < _stages.length - 1
                                    ? () => _swapStages(i, i + 1)
                                    : null,
                                onOpenDeal: (d) => _openDeal(context, d),
                              ),
                          ],
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _ColumnCard extends StatelessWidget {
  const _ColumnCard({
    required this.designMode,
    required this.stage,
    required this.deals,
    required this.onOpenDeal,
    this.onMoveLeft,
    this.onMoveRight,
  });

  final bool designMode;
  final Map<String, dynamic> stage;
  final List<Map<String, dynamic>> deals;
  final void Function(Map<String, dynamic>) onOpenDeal;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 280,
        height: 640,
        child: DesignModeWrapper(
          sectionId: 'crm_stage_${stage['id']}',
          child: Material(
            color: BlackLightColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BlackLightRadius.card),
              side: const BorderSide(color: BlackLightColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (stage['name'] ?? CommonContent.fallbackStage).toString(),
                          style: BlackLightTextStyles.bodyBold(),
                        ),
                      ),
                      if (designMode) ...[
                        IconButton(
                          onPressed: onMoveLeft,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          onPressed: onMoveRight,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: deals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final d = deals[i];
                      return Material(
                        color: BlackLightColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              const BorderSide(color: BlackLightColors.border),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onOpenDeal(d),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              (d['title'] ?? d['name'] ?? OrgCrmDealContent.dealFallbackTitle).toString(),
                              style: BlackLightTextStyles.body(),
                            ),
                          ),
                        ),
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

String _encodeDealPayload(Object? payload) {
  try {
    if (payload is Map || payload is List) {
      return JsonEncoder.withIndent('  ').convert(payload);
    }
  } catch (_) {}
  return payload?.toString() ?? '';
}
