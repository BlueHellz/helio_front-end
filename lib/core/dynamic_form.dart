import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:limye_app/core/content/content_registry.dart';

import '../theme/limye_theme.dart';

enum DynamicFieldType {
  text,
  phone,
  email,
  url,
  number,
  currency,
  date,
  dropdown,
  multiSelect,
  file,
  photo,
  toggle,
}

@immutable
class DynamicFieldDef {
  const DynamicFieldDef({
    required this.name,
    required this.label,
    required this.type,
    this.options,
    this.required = false,
  });

  final String name;
  final String label;
  final DynamicFieldType type;
  final List<String>? options;
  final bool required;
}

typedef DynamicValues = Map<String, Object?>;

/// Schema-driven form used across intake, project detail, and CRM surfaces.
class DynamicForm extends StatefulWidget {
  const DynamicForm({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
    this.readOnly = false,
  });

  final List<DynamicFieldDef> fields;
  final DynamicValues values;
  final ValueChanged<DynamicValues> onChanged;
  final bool readOnly;

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  late DynamicValues _local;

  @override
  void initState() {
    super.initState();
    _local = Map<String, Object?>.from(widget.values);
  }

  @override
  void didUpdateWidget(DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.values, widget.values)) {
      _local = Map<String, Object?>.from(widget.values);
    }
  }

  void _emit() => widget.onChanged(Map<String, Object?>.from(_local));

  void _set(String key, Object? value) {
    setState(() => _local[key] = value);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in widget.fields) ...[
          if (f.type != DynamicFieldType.toggle || widget.readOnly) ...[
            Text(
              f.label + (f.required ? CommonContent.requiredFieldSuffix : ''),
              style: LimyeTextStyles.caption(
                color: LimyeColors.textBody,
              ),
            ),
            const SizedBox(height: 6),
          ],
          _buildField(f),
          const SizedBox(height: LimyeSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildField(DynamicFieldDef f) {
    if (widget.readOnly) {
      return _readOnlyTile(f);
    }
    switch (f.type) {
      case DynamicFieldType.text:
      case DynamicFieldType.phone:
      case DynamicFieldType.email:
      case DynamicFieldType.url:
        return TextFormField(
          initialValue: (_local[f.name] ?? '').toString(),
          keyboardType: _keyboardFor(f.type),
          inputFormatters: f.type == DynamicFieldType.phone
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          onChanged: (v) => _set(f.name, v.isEmpty ? null : v),
          decoration: const InputDecoration(),
        );
      case DynamicFieldType.number:
      case DynamicFieldType.currency:
        return TextFormField(
          initialValue: (_local[f.name] ?? '').toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => _set(f.name, v.isEmpty ? null : v),
          decoration: InputDecoration(
            prefixText: f.type == DynamicFieldType.currency ? r'$ ' : null,
          ),
        );
      case DynamicFieldType.date:
        return _DatePickerRow(
          value: _local[f.name] as DateTime?,
          onPick: (d) => _set(f.name, d),
        );
      case DynamicFieldType.dropdown:
        final opts = f.options ?? const <String>[];
        return DropdownButtonFormField<String>(
          value: _local[f.name]?.toString().isEmpty ?? true
              ? null
              : _local[f.name]?.toString(),
          items: [
            for (final o in opts)
              DropdownMenuItem<String>(
                value: o,
                child: Text(o, style: LimyeTextStyles.body()),
              ),
          ],
          onChanged: (v) => _set(f.name, v),
          decoration: const InputDecoration(),
        );
      case DynamicFieldType.multiSelect:
        return _MultiSelectChips(
          options: f.options ?? const [],
          selected: _local[f.name] is List
              ? (_local[f.name] as List).map((e) => e.toString()).toList()
              : <String>[],
          onChanged: (list) => _set(f.name, list),
        );
      case DynamicFieldType.file:
      case DynamicFieldType.photo:
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () async {
              final r = await FilePicker.platform.pickFiles(
                type: f.type == DynamicFieldType.photo
                    ? FileType.image
                    : FileType.any,
              );
              if (r != null && r.files.single.name.isNotEmpty) {
                _set(f.name, r.files.single.name);
              }
            },
            child: Text(
              (_local[f.name]?.toString().isEmpty ?? true)
                  ? CommonContent.chooseFile
                  : _local[f.name].toString(),
            ),
          ),
        );
      case DynamicFieldType.toggle:
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(f.label, style: LimyeTextStyles.body()),
          value: _local[f.name] == true,
          onChanged: (v) => _set(f.name, v),
        );
    }
  }

  TextInputType _keyboardFor(DynamicFieldType t) {
    switch (t) {
      case DynamicFieldType.email:
        return TextInputType.emailAddress;
      case DynamicFieldType.url:
        return TextInputType.url;
      case DynamicFieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  Widget _readOnlyTile(DynamicFieldDef f) {
    final v = _local[f.name];
    String text;
    if (v == null) {
      text = CommonContent.emDash;
    } else if (v is DateTime) {
      text = MaterialLocalizations.of(context).formatMediumDate(v);
    } else if (v is List) {
      text = v.join(', ');
    } else {
      text = v.toString();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.input),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Text(
        text,
        style: LimyeTextStyles.data(color: LimyeColors.textPrimary),
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({required this.value, required this.onPick});

  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(1980),
          lastDate: DateTime(now.year + 5),
        );
        onPick(d);
      },
      child: Text(
        value == null
            ? CommonContent.selectDate
            : MaterialLocalizations.of(context).formatMediumDate(value!),
        style: LimyeTextStyles.body(),
      ),
    );
  }
}

class _MultiSelectChips extends StatelessWidget {
  const _MultiSelectChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          FilterChip(
            label: Text(o),
            selected: selected.contains(o),
            onSelected: (v) {
              final next = [...selected];
              if (v) {
                if (!next.contains(o)) next.add(o);
              } else {
                next.remove(o);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

bool mapEquals(Map<String, Object?> a, Map<String, Object?> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}
