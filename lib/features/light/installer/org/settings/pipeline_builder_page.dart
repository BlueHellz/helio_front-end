import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class _StageDraft {
  _StageDraft({
    this.serverId,
    required String name,
    required String trigger,
    required this.colorKey,
  })  : nameCtrl = TextEditingController(text: name),
        triggerCtrl = TextEditingController(text: trigger);

  final String? serverId;
  final TextEditingController nameCtrl;
  final TextEditingController triggerCtrl;
  String colorKey;

  void dispose() {
    nameCtrl.dispose();
    triggerCtrl.dispose();
  }
}

class PipelineBuilderPage extends ConsumerStatefulWidget {
  const PipelineBuilderPage({super.key});

  @override
  ConsumerState<PipelineBuilderPage> createState() =>
      _PipelineBuilderPageState();
}

class _PipelineBuilderPageState extends ConsumerState<PipelineBuilderPage> {
  String? _selectedId;
  List<_StageDraft> _drafts = [];
  final Map<String, int> _stageCounts = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _clearDrafts() {
    for (final d in _drafts) {
      d.dispose();
    }
    _drafts = [];
  }

  Future<void> _refreshStageCount(String pipelineId) async {
    try {
      final list = await ref.read(apiProvider).getStages(pipelineId);
      if (mounted) setState(() => _stageCounts[pipelineId] = list.length);
    } catch (_) {
      if (mounted) setState(() => _stageCounts[pipelineId] = 0);
    }
  }

  Future<void> _loadStagesIntoDrafts(String id) async {
    _clearDrafts();
    final list = await ref.read(apiProvider).getStages(id);
    if (!mounted) return;
    setState(() {
      _drafts = [
        for (final s in list)
          _StageDraft(
            serverId: s['id']?.toString(),
            name: (s['name'] ?? '').toString(),
            trigger: (s['trigger'] ?? s['trigger_condition'] ?? '').toString(),
            colorKey: (s['color_key'] ?? s['colorKey'] ?? 'primary').toString(),
          ),
      ];
      _stageCounts[id] = list.length;
    });
  }

  Future<void> _savePipeline() async {
    if (_selectedId == null || _saving) return;
    final api = ref.read(apiProvider);
    final pid = _selectedId!;
    setState(() => _saving = true);
    try {
      final stagesPayload = <Map<String, dynamic>>[];
      for (var i = 0; i < _drafts.length; i++) {
        final d = _drafts[i];
        final name = d.nameCtrl.text.trim();
        if (name.isEmpty) continue;
        final m = <String, dynamic>{
          'name': name,
          'order': i,
          'color_key': d.colorKey,
          if (d.triggerCtrl.text.trim().isNotEmpty)
            'trigger': d.triggerCtrl.text.trim(),
          if (d.serverId != null) 'id': d.serverId,
        };
        stagesPayload.add(m);
      }
      await api.updatePipeline(pid, {'stages': stagesPayload});
      if (mounted) {
        AppFeedback.snack(context, OrgSettingsPipelineBuilderContent.pipelineSavedSnack);
      }
      await _loadStagesIntoDrafts(pid);
      ref.invalidate(pipelinesProvider);
    } catch (e) {
      await _savePipelineFallback(api, pid);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _savePipelineFallback(
    BlackLightApi api,
    String pid,
  ) async {
    try {
      final existing = await api.getStages(pid);
      final existingIds =
          existing.map((e) => e['id']?.toString()).whereType<String>().toSet();
      final keepIds = _drafts.map((d) => d.serverId).whereType<String>().toSet();
      for (final id in existingIds.difference(keepIds)) {
        await api.deleteStage(pid, id);
      }
      for (var i = 0; i < _drafts.length; i++) {
        final d = _drafts[i];
        final name = d.nameCtrl.text.trim();
        if (name.isEmpty) continue;
        final body = <String, dynamic>{
          'name': name,
          'order': i,
          'color_key': d.colorKey,
          if (d.triggerCtrl.text.trim().isNotEmpty)
            'trigger': d.triggerCtrl.text.trim(),
        };
        if (d.serverId != null) {
          await api.updateStage(pid, d.serverId!, body);
        } else {
          await api.addStage(pid, body);
        }
      }
      final refreshed = await api.getStages(pid);
      await api.reorderStages(
        pid,
        refreshed
            .map((e) => e['id']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList(),
      );
      if (mounted) {
        AppFeedback.snack(context, OrgSettingsPipelineBuilderContent.pipelineSavedSnack);
      }
      await _loadStagesIntoDrafts(pid);
      ref.invalidate(pipelinesProvider);
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(
          context,
          '${OrgSettingsPipelineBuilderContent.pipelineSaveFailedPrefix}$e',
        );
      }
    }
  }

  List<DropdownMenuItem<String>> _colorItems(BuildContext context) {
    return [
      DropdownMenuItem(
        value: 'primary',
        child: Text(OrgSettingsPipelineBuilderContent.colorPrimary),
      ),
      DropdownMenuItem(
        value: 'green',
        child: Text(OrgSettingsPipelineBuilderContent.colorGreen),
      ),
      DropdownMenuItem(
        value: 'amber',
        child: Text(OrgSettingsPipelineBuilderContent.colorAmber),
      ),
      DropdownMenuItem(
        value: 'error',
        child: Text(OrgSettingsPipelineBuilderContent.colorError),
      ),
      DropdownMenuItem(
        value: 'muted',
        child: Text(OrgSettingsPipelineBuilderContent.colorMuted),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pipes = ref.watch(pipelinesProvider);

    return Scaffold(
      backgroundColor: c.scaffold,
      appBar: AppBar(
        title: Text(OrgSettingsPipelineBuilderContent.appBarTitle),
        actions: [
          if (_selectedId != null)
            TextButton(
              onPressed: _saving ? null : _savePipeline,
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.primary,
                      ),
                    )
                  : Text(OrgSettingsPipelineBuilderContent.savePipeline),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = TextEditingController();
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(OrgSettingsPipelineBuilderContent.dialogNewPipelineTitle),
              content: TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: OrgSettingsPipelineBuilderContent.labelPipelineName,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(ButtonsContent.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await ref.read(apiProvider).createPipeline(
                            {'name': name.text.trim()},
                          );
                      if (context.mounted) Navigator.pop(ctx);
                      ref.invalidate(pipelinesProvider);
                    } catch (e) {
                      if (context.mounted) {
                        AppFeedback.snack(
                          context,
                          '${ApiErrorsContent.createFailedPrefix}$e',
                        );
                      }
                    }
                  },
                  child: Text(ButtonsContent.create),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(OrgSettingsPipelineBuilderContent.fabCreatePipeline),
      ),
      body: pipes.when(
        loading: () => Center(child: CircularProgressIndicator(color: c.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          for (final p in items) {
            final id = p['id']?.toString();
            if (id != null && !_stageCounts.containsKey(id)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshStageCount(id);
              });
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BlackLightSpacing.gutter,
                  0,
                  BlackLightSpacing.gutter,
                  BlackLightSpacing.sm,
                ),
                child: Text(
                  OrgSettingsPipelineBuilderContent.pageSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BlackLightSpacing.gutter,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = items[i];
                          final id = p['id']?.toString() ?? '';
                          final selected = _selectedId == id;
                          final n = _stageCounts[id];
                          return Material(
                            color: c.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(BlackLightRadius.card),
                              side: BorderSide(
                                color: selected ? c.primary : c.outline,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (p['name'] ??
                                            OrgSettingsPipelineBuilderContent
                                                .defaultPipelineName)
                                        .toString(),
                                    style: BlackLightTextStyles.bodyBold(
                                      color: c.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${n ?? '—'}${OrgSettingsPipelineBuilderContent.stageCountSuffix}',
                                    style: BlackLightTextStyles.caption(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() => _selectedId = id);
                                        _loadStagesIntoDrafts(id);
                                      },
                                      child: Text(
                                        OrgSettingsPipelineBuilderContent.editPipeline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    VerticalDivider(width: 1, color: c.outline),
                    Expanded(child: _stageEditor(context)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stageEditor(BuildContext context) {
    if (_selectedId == null) {
      return Center(
        child: Text(
          OrgSettingsPipelineBuilderContent.selectPipelineFirst,
          style: BlackLightTextStyles.body(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                OrgSettingsPipelineBuilderContent.stagesHeading,
                style: BlackLightTextStyles.cardHeading(color: c.onSurface),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _drafts.add(
                      _StageDraft(
                        serverId: null,
                        name: '',
                        trigger: '',
                        colorKey: 'primary',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(OrgSettingsPipelineBuilderContent.addStageButton),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _drafts.isEmpty
                ? Center(
                    child: Text(
                      OrgSettingsPipelineBuilderContent.addStageButton,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: _drafts.length,
                    onReorder: (oldI, newI) {
                      if (newI > oldI) newI -= 1;
                      setState(() {
                        final x = _drafts.removeAt(oldI);
                        _drafts.insert(newI, x);
                      });
                    },
                    itemBuilder: (context, i) {
                      final d = _drafts[i];
                      return Material(
                        key: ValueKey('${d.serverId ?? 'new'}_$i'),
                        color: c.surface,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BlackLightRadius.card),
                          side: BorderSide(color: c.outline),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReorderableDragStartListener(
                                index: i,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8, right: 8),
                                  child: Icon(Icons.drag_handle, color: c.outline),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: d.nameCtrl,
                                      decoration: InputDecoration(
                                        labelText: OrgSettingsPipelineBuilderContent
                                            .labelStageName,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: d.triggerCtrl,
                                      decoration: InputDecoration(
                                        labelText: OrgSettingsPipelineBuilderContent
                                            .labelTriggerCondition,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: d.colorKey,
                                      decoration: InputDecoration(
                                        labelText: OrgSettingsPipelineBuilderContent
                                            .labelStageColor,
                                      ),
                                      items: _colorItems(context),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => d.colorKey = v);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: OrgSettingsPipelineBuilderContent
                                    .deleteStageTooltip,
                                icon: Icon(Icons.delete_outline, color: c.error),
                                onPressed: () {
                                  setState(() {
                                    final rm = _drafts.removeAt(i);
                                    rm.dispose();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
