import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class FieldLibraryPage extends ConsumerStatefulWidget {
  const FieldLibraryPage({super.key});

  @override
  ConsumerState<FieldLibraryPage> createState() => _FieldLibraryPageState();
}

class _FieldLibraryPageState extends ConsumerState<FieldLibraryPage> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(customFieldsProvider);

    return Scaffold(
      backgroundColor: context.colors.scaffold,
      appBar: AppBar(title: Text(OrgSettingsFieldLibraryContent.appBarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(OrgSettingsFieldLibraryContent.fabAddField),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = items[i];
            final id = m['id']?.toString() ?? '';
            return Dismissible(
              key: ValueKey(id.isEmpty ? i : id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async => await AppFeedback.showConfirmDialog(
                    context,
                    title: OrgSettingsFieldLibraryContent.confirmDeleteTitle,
                    message: OrgSettingsFieldLibraryContent.confirmDeleteBody,
                  ) ??
                  false,
              onDismissed: (_) async {
                try {
                  await ref.read(apiProvider).deleteField(id);
                  ref.invalidate(customFieldsProvider);
                } catch (e) {
                  if (context.mounted) {
                    AppFeedback.snack(
                      context,
                      '${OrgSettingsFieldLibraryContent.saveFieldFailedPrefix}$e',
                    );
                  }
                }
              },
              child: Material(
                color: context.colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BlackLightRadius.card),
                  side: BorderSide(color: context.colors.outline),
                ),
                child: ListTile(
                  title: Text(
                    (m['name'] ?? m['label'] ?? CommonContent.fallbackField)
                        .toString(),
                    style: BlackLightTextStyles.bodyBold(
                      color: context.colors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${m['type'] ?? CustomFieldTypes.text} · '
                    '${(m['target_sections'] ?? m['sections'] ?? const [])}',
                    style: BlackLightTextStyles.caption(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _openEditor(context, ref, m),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static const List<(String type, String label)> _typeChoices = [
    (CustomFieldTypes.text, OrgSettingsFieldLibraryContent.typeText),
    (CustomFieldTypes.number, OrgSettingsFieldLibraryContent.typeNumber),
    (CustomFieldTypes.date, OrgSettingsFieldLibraryContent.typeDate),
    (CustomFieldTypes.dropdown, OrgSettingsFieldLibraryContent.typeDropdown),
    (
      CustomFieldTypes.multiSelect,
      OrgSettingsFieldLibraryContent.typeMultiSelect,
    ),
    (CustomFieldTypes.file, OrgSettingsFieldLibraryContent.typeFile),
    (CustomFieldTypes.photo, OrgSettingsFieldLibraryContent.typePhoto),
    (CustomFieldTypes.toggle, OrgSettingsFieldLibraryContent.typeToggle),
    (CustomFieldTypes.url, OrgSettingsFieldLibraryContent.typeUrl),
    (CustomFieldTypes.phone, OrgSettingsFieldLibraryContent.typePhone),
    (CustomFieldTypes.email, OrgSettingsFieldLibraryContent.typeEmail),
    (
      CustomFieldTypes.currency,
      OrgSettingsFieldLibraryContent.typeCurrency,
    ),
  ];

  static const List<(String value, String label)> _targetDefs = [
    (
      OrgSettingsFieldLibraryContent.chipIntake,
      OrgSettingsFieldLibraryContent.chipIntakeLabel,
    ),
    (
      OrgSettingsFieldLibraryContent.chipProjectDetail,
      OrgSettingsFieldLibraryContent.chipProjectDetailLabel,
    ),
    (
      OrgSettingsFieldLibraryContent.chipDealCard,
      OrgSettingsFieldLibraryContent.chipDealCardLabel,
    ),
  ];

  bool _needsOptions(String type) =>
      type == CustomFieldTypes.dropdown ||
      type == CustomFieldTypes.multiSelect;

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? existing,
  ) async {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] ?? existing?['label'] ?? '') as String? ?? '',
    );
    final typeCtrl = ValueNotifier<String>(
      (existing?['type'] ?? CustomFieldTypes.text).toString(),
    );
    final optionAddCtrl = TextEditingController();
    final options = ValueNotifier<List<String>>(
      _parseOptions(existing?['options']),
    );
    final required = ValueNotifier<bool>(
      existing?['required'] == true,
    );
    final targets = ValueNotifier<List<String>>(
      ((existing?['target_sections'] ?? existing?['sections']) is List)
          ? List<String>.from(
              (existing!['target_sections'] ?? existing['sections']) as List,
            )
          : <String>[
              OrgSettingsFieldLibraryContent.chipIntake,
              OrgSettingsFieldLibraryContent.chipDealCard,
            ],
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final onSurf = ctx.colors.onSurface;
        final variant = Theme.of(ctx).colorScheme.onSurfaceVariant;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setM) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      OrgSettingsFieldLibraryContent.editorHeading,
                      style:
                          BlackLightTextStyles.cardHeading(color: onSurf),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: OrgSettingsFieldLibraryContent.labelName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: typeCtrl.value,
                      items: [
                        for (final t in _typeChoices)
                          DropdownMenuItem<String>(
                            value: t.$1,
                            child: Text(t.$2),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          typeCtrl.value = v;
                          setM(() {});
                        }
                      },
                      decoration: InputDecoration(
                        labelText: OrgSettingsFieldLibraryContent.labelType,
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: typeCtrl,
                      builder: (_, type, __) {
                        if (!_needsOptions(type)) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              OrgSettingsFieldLibraryContent.labelDropdownOptions,
                              style: BlackLightTextStyles.caption(
                                color: variant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: optionAddCtrl,
                                    decoration: InputDecoration(
                                      hintText: OrgSettingsFieldLibraryContent
                                          .optionAddHint,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final t = optionAddCtrl.text.trim();
                                    if (t.isEmpty) return;
                                    final next = [...options.value, t];
                                    options.value = next;
                                    optionAddCtrl.clear();
                                    setM(() {});
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                            ValueListenableBuilder<List<String>>(
                              valueListenable: options,
                              builder: (_, opts, __) {
                                return ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  itemCount: opts.length,
                                  onReorder: (a, b) {
                                    if (b > a) b -= 1;
                                    final n = [...opts];
                                    final x = n.removeAt(a);
                                    n.insert(b, x);
                                    options.value = n;
                                    setM(() {});
                                  },
                                  itemBuilder: (c, i) {
                                    final o = opts[i];
                                    return Material(
                                      key: ValueKey('opt_$i$o'),
                                      color: Theme.of(c)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.35),
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: ctx.colors.outline,
                                        ),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading:
                                            ReorderableDragStartListener(
                                          index: i,
                                          child: Icon(
                                            Icons.drag_handle,
                                            color: ctx.colors.outline,
                                          ),
                                        ),
                                        title: Text(o),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: ctx.colors.error,
                                          ),
                                          onPressed: () {
                                            final n = [...opts]
                                              ..removeAt(i);
                                            options.value = n;
                                            setM(() {});
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      OrgSettingsFieldLibraryContent.targetSectionsCaption,
                      style: BlackLightTextStyles.caption(color: variant),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final t in _targetDefs)
                          ValueListenableBuilder<List<String>>(
                            valueListenable: targets,
                            builder: (_, sel, __) {
                              final on = sel.contains(t.$1);
                              return FilterChip(
                                label: Text(t.$2),
                                selected: on,
                                onSelected: (v) {
                                  final next = [...sel];
                                  if (v) {
                                    if (!next.contains(t.$1)) next.add(t.$1);
                                  } else {
                                    next.remove(t.$1);
                                  }
                                  targets.value = next;
                                  setM(() {});
                                },
                              );
                            },
                          ),
                      ],
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: required,
                      builder: (_, req, __) => SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          OrgSettingsFieldLibraryContent.requiredSwitchTitle,
                        ),
                        value: req,
                        onChanged: (v) {
                          required.value = v;
                          setM(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: BlackLightSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final type = typeCtrl.value;
                          final body = <String, dynamic>{
                            'name': nameCtrl.text.trim(),
                            'type': type,
                            'required': required.value,
                            'target_sections': targets.value,
                            if (_needsOptions(type))
                              'options': options.value,
                          };
                          try {
                            if (existing == null) {
                              await ref.read(apiProvider).createField(body);
                            } else {
                              final id = existing['id']?.toString() ?? '';
                              await ref.read(apiProvider).updateField(id, body);
                            }
                            if (context.mounted) Navigator.pop(context);
                            ref.invalidate(customFieldsProvider);
                            if (context.mounted) {
                              AppFeedback.snack(
                                context,
                                OrgSettingsFieldLibraryContent.savedField,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppFeedback.snack(
                                context,
                                '${OrgSettingsFieldLibraryContent.saveFieldFailedPrefix}$e',
                              );
                            }
                          }
                        },
                        child: Text(ButtonsContent.save),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameCtrl.dispose();
    optionAddCtrl.dispose();
    typeCtrl.dispose();
    options.dispose();
    required.dispose();
    targets.dispose();
  }

  List<String> _parseOptions(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }
}
