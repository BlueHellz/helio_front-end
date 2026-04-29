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
                    AppFeedback.snack(context, '${ApiErrorsContent.deleteFailedPrefix}$e');
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
                    (m['name'] ?? m['label'] ?? CommonContent.fallbackField).toString(),
                    style: BlackLightTextStyles.bodyBold(
                        color: context.colors.onSurface),
                  ),
                  subtitle: Text(
                    '${m['type'] ?? 'text'} • sections: '
                    '${(m['target_sections'] ?? m['sections'] ?? const [])}',
                    style: BlackLightTextStyles.caption(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
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

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? existing,
  ) async {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] ?? existing?['label'] ?? '') as String? ?? '',
    );
    final typeCtrl = ValueNotifier<String>(
      (existing?['type'] ?? 'text').toString(),
    );
    final optionsCtrl = TextEditingController(
      text: (existing?['options'] is List)
          ? (existing!['options'] as List).join(', ')
          : '',
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
                    Text(OrgSettingsFieldLibraryContent.editorHeading,
                        style: BlackLightTextStyles.cardHeading(
                            color: onSurf)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                          labelText: OrgSettingsFieldLibraryContent.labelName),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: typeCtrl.value,
                      items: [
                        DropdownMenuItem(
                            value: 'text',
                            child: Text(OrgSettingsFieldLibraryContent.typeText)),
                        DropdownMenuItem(
                            value: 'number',
                            child: Text(OrgSettingsFieldLibraryContent.typeNumber)),
                        DropdownMenuItem(
                            value: 'dropdown',
                            child: Text(OrgSettingsFieldLibraryContent.typeDropdown),
                        ),
                        DropdownMenuItem(
                            value: 'toggle',
                            child: Text(OrgSettingsFieldLibraryContent.typeToggle)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          typeCtrl.value = v;
                          setM(() {});
                        }
                      },
                      decoration: InputDecoration(
                          labelText: OrgSettingsFieldLibraryContent.labelType),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: optionsCtrl,
                      decoration: InputDecoration(
                        labelText:
                            OrgSettingsFieldLibraryContent.labelDropdownOptions,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      OrgSettingsFieldLibraryContent.targetSectionsCaption,
                      style: BlackLightTextStyles.caption(color: variant),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in [
                          OrgSettingsFieldLibraryContent.chipIntake,
                          OrgSettingsFieldLibraryContent.chipDealCard,
                          OrgSettingsFieldLibraryContent.chipProjectDetail,
                        ])
                          FilterChip(
                            label: Text(s),
                            selected: targets.value.contains(s),
                            onSelected: (v) {
                              final next = [...targets.value];
                              if (v) {
                                if (!next.contains(s)) next.add(s);
                              } else {
                                next.remove(s);
                              }
                              targets.value = next;
                              setM(() {});
                            },
                          ),
                      ],
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: required,
                      builder: (_, req, __) => SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(OrgSettingsFieldLibraryContent.requiredSwitchTitle),
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
                          final body = <String, dynamic>{
                            'name': nameCtrl.text.trim(),
                            'type': typeCtrl.value,
                            'required': required.value,
                            'target_sections': targets.value,
                            if (typeCtrl.value == 'dropdown')
                              'options': optionsCtrl.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList(),
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
                          } catch (e) {
                            if (context.mounted) {
                              AppFeedback.snack(context, '${ApiErrorsContent.saveFailedPrefix}$e');
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
  }
}
