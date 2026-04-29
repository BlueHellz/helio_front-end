import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/dynamic_form.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class OrgNewProjectPage extends ConsumerStatefulWidget {
  const OrgNewProjectPage({super.key});

  @override
  ConsumerState<OrgNewProjectPage> createState() => _OrgNewProjectPageState();
}

class _OrgNewProjectPageState extends ConsumerState<OrgNewProjectPage> {
  int _type = 0; // 0 res 1 com 2 ind
  DynamicValues _values = {};
  List<DynamicFieldDef> _fields = const [];
  bool _loading = true;
  bool _submitting = false;

  String get _typeKey =>
      _type == 0 ? 'residential' : (_type == 1 ? 'commercial' : 'industrial');

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiProvider);
      final fields = await api.getCustomFields();
      final layout = await api.getIntakeLayout(_typeKey);
      final order = List<String>.from(
        (layout['field_ids'] ?? layout['assigned'] ?? const <dynamic>[]) as List,
      ).map((e) => e.toString()).toList();

      final byId = {for (final f in fields) f['id']?.toString() ?? '': f};
      final defs = <DynamicFieldDef>[];
      void addForId(String id) {
        final m = byId[id];
        if (m == null) return;
        defs.add(_defFromLibrary(m));
      }

      if (order.isEmpty) {
        for (final f in fields) {
          addForId(f['id']?.toString() ?? '');
        }
      } else {
        for (final id in order) {
          addForId(id);
        }
      }

      if (!mounted) return;
      setState(() {
        _fields = defs;
        _values = {
          for (final d in defs) d.name: _values[d.name],
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fields = const [
          DynamicFieldDef(
            name: 'notes',
            label: OrgNewProjectContent.fieldNotesLabel,
            type: DynamicFieldType.text,
          ),
        ];
        _loading = false;
      });
    }
  }

  DynamicFieldDef _defFromLibrary(Map<String, dynamic> m) {
    final key = (m['key'] ?? m['id'] ?? m['name'] ?? 'field').toString();
    final label = (m['label'] ?? m['name'] ?? key).toString();
    final typeStr = (m['type'] ?? 'text').toString();
    DynamicFieldType t = DynamicFieldType.text;
    switch (typeStr) {
      case 'number':
        t = DynamicFieldType.number;
        break;
      case 'currency':
        t = DynamicFieldType.currency;
        break;
      case 'dropdown':
        t = DynamicFieldType.dropdown;
        break;
      case 'toggle':
        t = DynamicFieldType.toggle;
        break;
      default:
        t = DynamicFieldType.text;
    }
    final opts = (m['options'] is List)
        ? List<String>.from((m['options'] as List).map((e) => e.toString()))
        : null;
    return DynamicFieldDef(
      name: key,
      label: label,
      type: t,
      options: opts,
      required: m['required'] == true,
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final address = (_values['address'] ?? _values['Address'])?.toString() ?? '';
      if (address.trim().isEmpty) {
        AppFeedback.snack(context, FieldValidationContent.addressRequired);
        return;
      }
      await ref.read(apiProvider).createProject(
            projectCreateBody(
              address: address.trim(),
              projectType: _typeKey,
              customData: Map<String, dynamic>.from(
                _values.map((k, v) => MapEntry(k, v)),
              ),
            ),
          );
      if (mounted) {
        AppFeedback.snack(context, ApiErrorsContent.projectCreated);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) AppFeedback.snack(context, '${ApiErrorsContent.failedPrefix}$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(title: Text(OrgNewProjectContent.appBarTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.gutter),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(OrgNewProjectContent.projectTypeCaption, style: BlackLightTextStyles.caption()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _typePill(OrgNewProjectContent.typeResidential, 0),
                    const SizedBox(width: 8),
                    _typePill(OrgNewProjectContent.typeCommercial, 1),
                    const SizedBox(width: 8),
                    _typePill(OrgNewProjectContent.typeIndustrial, 2),
                  ],
                ),
                const SizedBox(height: BlackLightSpacing.md),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  DynamicForm(
                    fields: [
                      const DynamicFieldDef(
                        name: 'address',
                        label: OrgNewProjectContent.fieldAddressLabel,
                        type: DynamicFieldType.text,
                        required: true,
                      ),
                      ..._fields,
                    ],
                    values: _values,
                    onChanged: (v) => setState(() => _values = v),
                  ),
                  const SizedBox(height: BlackLightSpacing.md),
                  SizedBox(
                    height: BlackLightSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(OrgNewProjectContent.createProjectButton),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typePill(String label, int idx) {
    final on = _type == idx;
    return ChoiceChip(
      label: Text(label),
      selected: on,
      onSelected: (_) {
        setState(() => _type = idx);
        _loadFields();
      },
    );
  }
}
