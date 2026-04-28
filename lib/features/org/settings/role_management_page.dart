import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_providers.dart';
import '../../../core/ui/app_feedback.dart';
import '../../../theme/blacklight_theme.dart';

class RoleManagementPage extends ConsumerStatefulWidget {
  const RoleManagementPage({super.key});

  @override
  ConsumerState<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends ConsumerState<RoleManagementPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(apiProvider).getRoles();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(apiProvider).getRoles();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(title: Text(OrgSettingsRoleManagementContent.appBarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRoleEditor(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(OrgSettingsRoleManagementContent.fabAddRole),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(BlackLightSpacing.gutter),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = items[i];
                final users =
                    (m['users'] ?? m['members'] ?? const <dynamic>[]) as List;
                return Material(
                  color: BlackLightColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BlackLightRadius.card),
                    side: const BorderSide(color: BlackLightColors.border),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      (m['name'] ?? CommonContent.fallbackRole).toString(),
                      style: BlackLightTextStyles.bodyBold(),
                    ),
                    subtitle: Text(
                      '${users.length}${OrgSettingsRoleManagementContent.usersCountSuffix}',
                      style: BlackLightTextStyles.caption(),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final u in users)
                              Text(
                                (u is Map)
                                    ? (u['name'] ?? u['email'] ?? CommonContent.fallbackUser)
                                        .toString()
                                    : u.toString(),
                                style: BlackLightTextStyles.body(),
                              ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () =>
                                  _assignUser(context, ref, m['id']?.toString() ?? ''),
                              child: Text(OrgSettingsRoleManagementContent.assignUser),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _openRoleEditor(
                                  context,
                                  ref,
                                  m,
                                ),
                                child: Text(OrgSettingsRoleManagementContent.editPermissions),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _assignUser(
    BuildContext context,
    WidgetRef ref,
    String roleId,
  ) async {
    final q = TextEditingController();
    List<Map<String, dynamic>> results = const [];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BlackLightColors.surface,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setM) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: q,
                    decoration: InputDecoration(
                        labelText: OrgSettingsRoleManagementContent.searchLabel),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        results = await ref
                            .read(apiProvider)
                            .searchUsers(q.text.trim());
                        setM(() {});
                      } catch (e) {
                        if (context.mounted) {
                          AppFeedback.snack(context, '${ApiErrorsContent.searchFailedPrefix}$e');
                        }
                      }
                    },
                    child: Text(ButtonsContent.search),
                  ),
                  const SizedBox(height: 8),
                  for (final u in results)
                    ListTile(
                      title: Text(
                        (u['name'] ?? u['email'] ?? CommonContent.fallbackUser).toString(),
                      ),
                      onTap: () async {
                        try {
                          await ref.read(apiProvider).assignRoleToUser(
                                roleId,
                                u['id']?.toString() ?? '',
                              );
                          if (context.mounted) Navigator.pop(ctx);
                          _reload();
                        } catch (e) {
                          if (context.mounted) {
                            AppFeedback.snack(context, '${ApiErrorsContent.assignFailedPrefix}$e');
                          }
                        }
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openRoleEditor(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? existing,
  ) async {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] ?? '').toString(),
    );
    final perms = ValueNotifier<Set<String>>(
      ((existing?['permissions'] ?? existing?['perms']) is List)
          ? Set<String>.from(
              List<String>.from(
                (existing!['permissions'] ?? existing['perms']) as List,
              ),
            )
          : {
              OrgSettingsRoleManagementContent.permissionProjectsRead,
              OrgSettingsRoleManagementContent.permissionProjectsWrite,
              OrgSettingsRoleManagementContent.permissionCrmManage,
            },
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            existing == null
                ? OrgSettingsRoleManagementContent.dialogNewRole
                : OrgSettingsRoleManagementContent.dialogEditRole,
            style: BlackLightTextStyles.cardHeading(),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                        labelText: OrgSettingsRoleManagementContent.labelName),
                  ),
                  const SizedBox(height: 12),
                  Text(OrgSettingsRoleManagementContent.permissionsCaption,
                      style: BlackLightTextStyles.caption()),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: perms,
                    builder: (context, value, __) {
                      return Column(
                        children: [
                          for (final p in OrgSettingsRoleManagementContent
                              .permissionOptions)
                            CheckboxListTile(
                              value: value.contains(p),
                              title: Text(p),
                              onChanged: (v) {
                                final next = {...value};
                                if (v == true) {
                                  next.add(p);
                                } else {
                                  next.remove(p);
                                }
                                perms.value = next;
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ButtonsContent.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final body = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'permissions': perms.value.toList(),
                };
                try {
                  if (existing == null) {
                    await ref.read(apiProvider).createRole(body);
                  } else {
                    await ref.read(apiProvider).updateRole(
                          existing['id']?.toString() ?? '',
                          body,
                        );
                  }
                  if (context.mounted) Navigator.pop(ctx);
                  _reload();
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
    );
  }
}
