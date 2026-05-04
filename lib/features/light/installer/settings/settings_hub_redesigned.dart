import 'dart:convert';

import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/design_mode_wrapper.dart';
import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/genui/catalog_provider.dart';
import 'package:blacklight_app/genui/genui_surface.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../org/settings/field_library_page.dart';
import '../org/settings/role_management_page.dart';
import 'pipeline_builder_page.dart';

/// Redesigned org settings: GenUI platform builder, custom components, fields,
/// pipelines (Flow Mesh), roles, integrations, billing.
class SettingsHubRedesigned extends ConsumerStatefulWidget {
  const SettingsHubRedesigned({super.key});

  @override
  ConsumerState<SettingsHubRedesigned> createState() =>
      _SettingsHubRedesignedState();
}

class _SettingsHubRedesignedState extends ConsumerState<SettingsHubRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _platformPrompt = TextEditingController();
  final List<String> _buildHistory = [];

  static const _targetSectionOptions = <String>[
    'dashboard',
    'crm',
    'settings',
    'intake',
    'flow_mesh',
    'mobile',
    'modal',
    'platform_builder',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _platformPrompt.dispose();
    super.dispose();
  }

  Future<void> _runConfigure() async {
    final prompt = _platformPrompt.text.trim();
    if (prompt.isEmpty) {
      AppFeedback.snack(context, 'Enter a prompt to build.');
      return;
    }
    try {
      final res = await ref.read(apiProvider).postAiConfigure({
        'prompt': prompt,
        'catalog_context': limyeCatalogPromptAugment(ref),
      });
      ingestConfigureResponseIntoGenUi(ref, res);
      if (mounted) {
        final summary = res == null
            ? 'null'
            : res is Map
                ? jsonEncode(res)
                : res.toString();
        setState(() {
          _buildHistory.insert(
            0,
            '${DateTime.now().toIso8601String()}: '
            '${summary.length > 400 ? summary.substring(0, 400) : summary}',
          );
        });
      }
      ref.invalidate(orgCustomComponentsProvider);
    } on ApiException catch (e) {
      if (mounted) AppFeedback.snack(context, '${e.statusCode}: ${e.body}');
    } catch (e) {
      if (mounted) AppFeedback.snack(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final designOn = ref.watch(designModeProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: c.scaffold,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              BlackLightSpacing.gutter,
              BlackLightSpacing.gutter,
              BlackLightSpacing.gutter,
              BlackLightSpacing.sm,
            ),
            child: DesignModeWrapper(
              sectionId: 'settings_header',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      OrgOrgSettingsHubContent.pageTitle,
                      style: BlackLightTextStyles.sectionHeading(
                        color: c.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    OrgOrgSettingsHubContent.designModeTitle,
                    style: BlackLightTextStyles.caption(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: designOn,
                    onChanged: (v) async {
                      await ref
                          .read(designModeProvider.notifier)
                          .setEnabled(v);
                      await ref.read(designModeProvider.notifier).refresh();
                    },
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: c.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Platform Builder'),
                Tab(text: 'Custom Components'),
                Tab(text: 'Fields & Pipelines'),
                Tab(text: 'Roles & Permissions'),
                Tab(text: 'Integrations'),
                Tab(text: 'Billing & Plan'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DesignModeWrapper(
                  sectionId: 'settings_platform_builder',
                  child: _platformBuilderTab(context, ref),
                ),
                DesignModeWrapper(
                  sectionId: 'settings_custom_components',
                  child: _customComponentsTab(context, ref),
                ),
                DesignModeWrapper(
                  sectionId: 'settings_fields_pipelines',
                  child: Column(
                    children: [
                      Expanded(child: FieldLibraryPage()),
                      const Divider(height: 1),
                      Expanded(child: PipelineBuilderPage()),
                    ],
                  ),
                ),
                DesignModeWrapper(
                  sectionId: 'settings_roles',
                  child: const RoleManagementPage(),
                ),
                DesignModeWrapper(
                  sectionId: 'settings_integrations',
                  child: _integrationsTab(context, ref),
                ),
                DesignModeWrapper(
                  sectionId: 'settings_billing',
                  child: _billingTab(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _platformBuilderTab(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Describe what you want to build…',
                style: BlackLightTextStyles.bodyBold(color: c.onSurface),
              ),
              const SizedBox(height: BlackLightSpacing.sm),
              TextField(
                controller: _platformPrompt,
                minLines: 5,
                maxLines: 12,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: BlackLightSpacing.md),
              FilledButton(
                onPressed: _runConfigure,
                child: const Text('Build'),
              ),
              const SizedBox(height: BlackLightSpacing.lg),
              Text(
                'Build history',
                style: BlackLightTextStyles.bodyBold(color: c.onSurface),
              ),
              const SizedBox(height: BlackLightSpacing.sm),
              ..._buildHistory.map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableText(
                    h,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customComponentsTab(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orgCustomComponentsProvider);
    return Scaffold(
      backgroundColor: context.colors.scaffold,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCustomComponentForm(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add component'),
      ),
      body: async.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No custom components yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(BlackLightSpacing.gutter),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final row = items[i];
              final name = (row['name'] ?? row['title'] ?? '—').toString();
              final type = (row['type'] ?? '—').toString();
              final rawSec = row['target_sections'] ?? row['sections'];
              final sections = rawSec is List
                  ? rawSec.map((e) => e.toString()).join(', ')
                  : (rawSec ?? '').toString();
              final created = row['created_at'] ?? row['createdAt'];
              final dateStr = created is String
                  ? created
                  : DateFormat.yMMMd().format(DateTime.now());
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: BlackLightTextStyles.bodyBold(
                          color: context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: $type',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Sections: $sections',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Created: $dateStr',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () =>
                                _openCustomComponentForm(context, ref, row),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: context.colors.error,
                            ),
                            onPressed: () => _deleteCustom(ref, row),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteCustom(WidgetRef ref, Map<String, dynamic> row) async {
    final id = row['id']?.toString();
    if (id == null || id.isEmpty) return;
    final ok = await AppFeedback.showConfirmDialog(
      context,
      title: 'Delete component',
      message: 'Remove this custom component?',
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(apiProvider).deleteOrgCustomComponent(id);
      ref.invalidate(orgCustomComponentsProvider);
    } on ApiException catch (e) {
      if (mounted) AppFeedback.snack(context, '${e.statusCode}');
    }
  }

  Future<void> _openCustomComponentForm(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? existing,
  ) async {
    final nameCtrl =
        TextEditingController(text: existing?['name']?.toString() ?? '');
    final propsRaw = existing?['props'];
    final propsCtrl = TextEditingController(
      text: propsRaw is Map
          ? jsonEncode(propsRaw)
          : (existing?['props_json'] ?? '{"key":"value"}').toString(),
    );
    var type = (existing?['type'] ?? 'Card').toString();
    final selectedSections = <String>{};
    final rawSec = existing?['target_sections'] ?? existing?['sections'];
    if (rawSec is List) {
      selectedSections.addAll(rawSec.map((e) => e.toString()));
    }
    if (selectedSections.isEmpty) {
      selectedSections.add('settings');
    }

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(existing == null ? 'Add custom component' : 'Edit'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      items: const [
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                        DropdownMenuItem(value: 'Panel', child: Text('Panel')),
                        DropdownMenuItem(
                          value: 'Widget',
                          child: Text('Widget'),
                        ),
                        DropdownMenuItem(value: 'Form', child: Text('Form')),
                      ],
                      onChanged: (v) => setLocal(() => type = v ?? type),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: propsCtrl,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Props (JSON)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Target sections',
                      style: Theme.of(ctx).textTheme.labelLarge,
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in _targetSectionOptions)
                          FilterChip(
                            label: Text(s),
                            selected: selectedSections.contains(s),
                            onSelected: (v) => setLocal(() {
                              if (v) {
                                selectedSections.add(s);
                              } else {
                                selectedSections.remove(s);
                              }
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ButtonsContent.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ButtonsContent.save),
              ),
            ],
          );
        },
      ),
    );

    if (added != true || !context.mounted) return;
    try {
      var props = <String, dynamic>{};
      try {
        props = Map<String, dynamic>.from(
          jsonDecode(propsCtrl.text.trim()) as Map,
        );
      } catch (_) {}

      await ref.read(apiProvider).postAiAddCustomComponent({
        if (existing?['id'] != null) 'id': existing!['id'],
        'name': nameCtrl.text.trim(),
        'type': type,
        'props': props,
        'target_sections': selectedSections.toList(),
      });
      ref.invalidate(orgCustomComponentsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        AppFeedback.snack(context, '${e.statusCode}: ${e.body}');
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.snack(context, e.toString());
      }
    }
  }

  Widget _integrationsTab(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      children: [
        Text(
          OrgSettingsApiKeysContent.pageTitle,
          style: BlackLightTextStyles.sectionHeading(color: c.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          OrgSettingsApiKeysContent.placeholder,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: BlackLightSpacing.md),
        _placeholderTile(
          context,
          'Webhooks',
          'Configure outbound webhooks (coming soon).',
        ),
        _placeholderTile(
          context,
          'Integration marketplace',
          'Browse connectors (coming soon).',
        ),
        _placeholderTile(
          context,
          'Twilio',
          'SMS and voice numbers (coming soon).',
        ),
      ],
    );
  }

  Widget _placeholderTile(
    BuildContext context,
    String title,
    String body,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: BlackLightSpacing.sm),
      child: ListTile(
        title: Text(
          title,
          style:
              BlackLightTextStyles.bodyBold(color: context.colors.onSurface),
        ),
        subtitle: Text(body),
      ),
    );
  }

  Widget _billingTab(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      children: [
        Text(
          OrgSettingsBillingContent.pageTitle,
          style: BlackLightTextStyles.sectionHeading(color: c.onSurface),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(BlackLightSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrgSettingsBillingContent.placeholder,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: BlackLightSpacing.md),
                FilledButton(
                  onPressed: () => AppFeedback.comingSoon(
                    context,
                    feature: 'Billing upgrades',
                  ),
                  child: const Text('Manage plan'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
