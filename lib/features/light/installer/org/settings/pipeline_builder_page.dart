import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class PipelineBuilderPage extends ConsumerStatefulWidget {
  const PipelineBuilderPage({super.key});

  @override
  ConsumerState<PipelineBuilderPage> createState() =>
      _PipelineBuilderPageState();
}

class _PipelineBuilderPageState extends ConsumerState<PipelineBuilderPage> {
  String? _selectedId;
  List<Map<String, dynamic>> _stages = const [];

  Future<void> _loadStages(String id) async {
    final list = await ref.read(apiProvider).getStages(id);
    if (!mounted) return;
    setState(() => _stages = list);
  }

  @override
  Widget build(BuildContext context) {
    final pipes = ref.watch(pipelinesProvider);

    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(title: Text(OrgSettingsPipelineBuilderContent.appBarTitle)),
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
                    labelText: OrgSettingsPipelineBuilderContent.labelPipelineName),
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
                        AppFeedback.snack(context, '${ApiErrorsContent.createFailedPrefix}$e');
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
        label: Text(OrgSettingsPipelineBuilderContent.fabPipelineLabel),
      ),
      body: pipes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          return Row(
            children: [
              SizedBox(
                width: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    final id = p['id']?.toString() ?? '';
                    final selected = _selectedId == id;
                    return Material(
                      color: selected
                          ? BlackLightColors.surface
                          : BlackLightColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(BlackLightRadius.card),
                        side: BorderSide(
                          color: selected
                              ? BlackLightColors.accent
                              : BlackLightColors.border,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          (p['name'] ?? OrgSettingsPipelineBuilderContent.defaultPipelineName).toString(),
                          style: BlackLightTextStyles.bodyBold(),
                        ),
                        onTap: () {
                          setState(() => _selectedId = id);
                          _loadStages(id);
                        },
                      ),
                    );
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _stageEditor(context, ref)),
            ],
          );
        },
      ),
    );
  }

  Widget _stageEditor(BuildContext context, WidgetRef ref) {
    if (_selectedId == null) {
      return Center(
        child: Text(
          OrgSettingsPipelineBuilderContent.selectPipelineFirst,
          style: BlackLightTextStyles.body(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(OrgSettingsPipelineBuilderContent.stagesHeading, style: BlackLightTextStyles.cardHeading()),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  final name = TextEditingController();
                  final cond = TextEditingController();
                  await showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(OrgSettingsPipelineBuilderContent.addStageDialogTitle),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: name,
                            decoration:
                                InputDecoration(labelText: OrgSettingsPipelineBuilderContent.labelStageName),
                          ),
                          TextField(
                            controller: cond,
                            decoration: InputDecoration(
                              labelText: OrgSettingsPipelineBuilderContent
                                  .labelTriggerCondition,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(ButtonsContent.cancel),
                        ),
                        FilledButton(
                          onPressed: () async {
                            try {
                              await ref.read(apiProvider).addStage(
                                    _selectedId!,
                                    {
                                      'name': name.text.trim(),
                                      'order': _stages.length,
                                      if (cond.text.trim().isNotEmpty)
                                        'trigger': cond.text.trim(),
                                    },
                                  );
                              if (context.mounted) Navigator.pop(ctx);
                              _loadStages(_selectedId!);
                            } catch (e) {
                              if (context.mounted) {
                                AppFeedback.snack(context, '${ApiErrorsContent.addFailedPrefix}$e');
                              }
                            }
                          },
                          child: Text(ButtonsContent.save),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(OrgSettingsPipelineBuilderContent.addStageButton),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: _stages.length,
              onReorder: (oldI, newI) async {
                if (newI > oldI) newI -= 1;
                final next = [..._stages];
                final item = next.removeAt(oldI);
                next.insert(newI, item);
                setState(() => _stages = next);
                try {
                  await ref.read(apiProvider).reorderStages(
                        _selectedId!,
                        next
                            .map((e) => e['id']?.toString() ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList(),
                      );
                } catch (e) {
                  if (context.mounted) {
                    AppFeedback.snack(context, '${ApiErrorsContent.reorderFailedPrefix}$e');
                  }
                  _loadStages(_selectedId!);
                }
              },
              itemBuilder: (context, i) {
                final s = _stages[i];
                return ListTile(
                  key: ValueKey(s['id']?.toString() ?? '$i'),
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text((s['name'] ?? CommonContent.fallbackStage).toString()),
                  subtitle: Text(
                    (s['trigger'] ?? '').toString(),
                    style: BlackLightTextStyles.caption(),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () =>
                        _pickStageFields(context, ref, _selectedId!, s),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStageFields(
    BuildContext context,
    WidgetRef ref,
    String pipelineId,
    Map<String, dynamic> stage,
  ) async {
    final fields = await ref.read(apiProvider).getCustomFields();
    final selected = ValueNotifier<Set<String>>(
      Set<String>.from(
        List<String>.from(
          (stage['field_ids'] ?? stage['fields'] ?? const <dynamic>[]) as List,
        ),
      ),
    );
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BlackLightColors.surface,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setM) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    OrgSettingsPipelineBuilderContent.dealCardFieldsTitle,
                    style: BlackLightTextStyles.cardHeading(),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: selected,
                    builder: (_, set, __) {
                      return Column(
                        children: [
                          for (final f in fields)
                            CheckboxListTile(
                              value: set.contains(f['id']?.toString()),
                              title: Text((f['name'] ?? CommonContent.fallbackField).toString()),
                              onChanged: (v) {
                                final id = f['id']?.toString() ?? '';
                                final next = {...set};
                                if (v == true) {
                                  next.add(id);
                                } else {
                                  next.remove(id);
                                }
                                selected.value = next;
                                setM(() {});
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(apiProvider).updateStage(
                              pipelineId,
                              stage['id']?.toString() ?? '',
                              {'field_ids': selected.value.toList()},
                            );
                        if (context.mounted) Navigator.pop(ctx);
                        _loadStages(pipelineId);
                      } catch (e) {
                        if (context.mounted) {
                          AppFeedback.snack(context, '${ApiErrorsContent.saveFailedPrefix}$e');
                        }
                      }
                    },
                    child: Text(ButtonsContent.save),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
