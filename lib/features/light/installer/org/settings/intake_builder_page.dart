import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class IntakeBuilderPage extends ConsumerStatefulWidget {
  const IntakeBuilderPage({super.key});

  @override
  ConsumerState<IntakeBuilderPage> createState() => _IntakeBuilderPageState();
}

class _IntakeBuilderPageState extends ConsumerState<IntakeBuilderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final Map<String, List<String>> _available = {};
  final Map<String, List<String>> _assigned = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) _hydrate(_keyForIndex(_tabs.index));
    });
    _hydrate('residential');
  }

  String _keyForIndex(int i) =>
      i == 0 ? 'residential' : (i == 1 ? 'commercial' : 'industrial');

  Future<void> _hydrate(String type) async {
    final api = ref.read(apiProvider);
    final fields = await api.getCustomFields();
    final layout = await api.getIntakeLayout(type);
    final libIds =
        fields.map((e) => e['id']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    final assigned = List<String>.from(
      (layout['field_ids'] ?? layout['assigned'] ?? const <dynamic>[]) as List,
    ).map((e) => e.toString()).toList();
    final avail = libIds.where((id) => !assigned.contains(id)).toList();
    if (!mounted) return;
    setState(() {
      _assigned[type] = assigned;
      _available[type] = avail;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _saveLayout(String type) async {
    try {
      await ref.read(apiProvider).saveOrgLayoutSection(type, {
        'field_ids': _assigned[type] ?? [],
      });
      if (mounted) {
        AppFeedback.snack(context, OrgSettingsIntakeBuilderContent.layoutSaved);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.snack(
          context,
          '${OrgSettingsIntakeBuilderContent.layoutSaveFailedPrefix}$e',
        );
      }
    }
  }

  void _move(String type, String id, {required bool toAssigned}) {
    setState(() {
      final av = List<String>.from(_available[type] ?? const <String>[]);
      final as = List<String>.from(_assigned[type] ?? const <String>[]);
      av.remove(id);
      as.remove(id);
      if (toAssigned) {
        as.add(id);
      } else {
        av.add(id);
      }
      _available[type] = av;
      _assigned[type] = as;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(customFieldsProvider);

    return Scaffold(
      backgroundColor: context.colors.scaffold,
      appBar: AppBar(
        title: Text(OrgSettingsIntakeBuilderContent.appBarTitle),
        actions: [
          TextButton(
            onPressed: () => _saveLayout(_keyForIndex(_tabs.index)),
            child: Text(OrgSettingsIntakeBuilderContent.saveLayoutAction),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: OrgSettingsIntakeBuilderContent.tabResidential),
            Tab(text: OrgSettingsIntakeBuilderContent.tabCommercial),
            Tab(text: OrgSettingsIntakeBuilderContent.tabIndustrial),
          ],
        ),
      ),
      body: fieldsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (fieldRows) {
          final byId = {
            for (final f in fieldRows) f['id']?.toString() ?? '': f,
          };
          return TabBarView(
            controller: _tabs,
            children: [
              _twoColumns(context, 'residential', byId),
              _twoColumns(context, 'commercial', byId),
              _twoColumns(context, 'industrial', byId),
            ],
          );
        },
      ),
    );
  }

  Widget _twoColumns(
      BuildContext context, String type, Map<String, Map<String, dynamic>> byId) {
    final colors = context.colors;
    final av = _available[type] ?? const <String>[];
    final as = _assigned[type] ?? const <String>[];

    Widget column(
      String title,
      List<String> ids, {
      required bool isAssignedColumn,
    }) {
      return Expanded(
        child: DragTarget<String>(
          onWillAccept: (_) => true,
          onAccept: (id) => _move(type, id, toAssigned: isAssignedColumn),
          builder: (context, candidate, __) {
            final highlight = candidate.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(BlackLightRadius.card),
                border: Border.all(
                  color: highlight ? colors.primary : colors.outline,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(title,
                        style: BlackLightTextStyles.bodyBold(
                            color: colors.onSurface)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ids.length,
                      itemBuilder: (context, i) {
                        final id = ids[i];
                        final row = byId[id];
                        final label = (row?['name'] ?? id).toString();
                        return Draggable<String>(
                          data: id,
                          feedback: Material(
                            color: colors.surface,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 260,
                              child: ListTile(title: Text(label)),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: ListTile(title: Text(label)),
                          ),
                          child: ListTile(
                            title: Text(label),
                            trailing: IconButton(
                              icon: Icon(
                                isAssignedColumn
                                    ? Icons.arrow_back_outlined
                                    : Icons.arrow_forward_outlined,
                              ),
                              onPressed: () => _move(
                                type,
                                id,
                                toAssigned: !isAssignedColumn,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          column(OrgSettingsIntakeBuilderContent.columnAvailable, av, isAssignedColumn: false),
          const SizedBox(width: 12),
          column(OrgSettingsIntakeBuilderContent.columnAssignedOrder, as, isAssignedColumn: true),
        ],
      ),
    );
  }
}
