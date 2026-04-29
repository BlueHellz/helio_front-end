import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/features/light/installer/settings/pipeline_builder_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

/// Pipeline list + Flow Mesh editor for the selected pipeline.
class PipelineBuilderPage extends ConsumerStatefulWidget {
  const PipelineBuilderPage({super.key});

  @override
  ConsumerState<PipelineBuilderPage> createState() =>
      _PipelineBuilderPageState();
}

class _PipelineBuilderPageState extends ConsumerState<PipelineBuilderPage> {
  String? _selectedId;
  final Map<String, int> _stageCounts = {};

  Future<void> _refreshStageCount(String pipelineId) async {
    try {
      final list = await ref.read(apiProvider).getStages(pipelineId);
      if (mounted) setState(() => _stageCounts[pipelineId] = list.length);
    } catch (_) {
      if (mounted) setState(() => _stageCounts[pipelineId] = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pipes = ref.watch(pipelinesProvider);

    return Scaffold(
      backgroundColor: c.scaffold,
      appBar: AppBar(
        title: Text(OrgSettingsPipelineBuilderContent.appBarTitle),
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
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(BlackLightSpacing.gutter),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      OrgSettingsPipelineBuilderContent.selectPipelineFirst,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: BlackLightSpacing.md),
                    Text(
                      OrgSettingsPipelineBuilderContent.pageSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

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
                      width: 280,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BlackLightSpacing.gutter,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                            child: InkWell(
                              onTap: () => setState(() => _selectedId = id),
                              borderRadius:
                                  BorderRadius.circular(BlackLightRadius.card),
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
                                      child: Text(
                                        selected
                                            ? OrgSettingsPipelineBuilderContent.flowMeshTitle
                                            : OrgSettingsPipelineBuilderContent.editPipeline,
                                        style: BlackLightTextStyles.bodyBold(
                                          color: c.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    VerticalDivider(width: 1, color: c.outline),
                    Expanded(
                      child: _selectedId == null
                          ? Center(
                              child: Text(
                                OrgSettingsPipelineBuilderContent.selectPipelineFirst,
                                style: BlackLightTextStyles.body(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : PipelineBuilderCanvas(pipelineId: _selectedId!),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
