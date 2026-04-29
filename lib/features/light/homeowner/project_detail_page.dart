import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/dynamic_form.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/widgets/project_status_badge.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class HomeownerProjectDetailPage extends ConsumerStatefulWidget {
  const HomeownerProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<HomeownerProjectDetailPage> createState() =>
      _HomeownerProjectDetailPageState();
}

class _HomeownerProjectDetailPageState
    extends ConsumerState<HomeownerProjectDetailPage> {
  Map<String, dynamic>? _raw;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiProvider);
      final m = await api.getProject(widget.projectId);
      if (!mounted) return;
      setState(() {
        _raw = m;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<DynamicFieldDef> _fieldsFromCustom(Map<String, dynamic>? custom) {
    if (custom == null) return const [];
    return custom.entries
        .map(
          (e) => DynamicFieldDef(
            name: e.key,
            label: e.key.replaceAll('_', ' '),
            type: DynamicFieldType.text,
          ),
        )
        .toList();
  }

  DynamicValues _valuesFromCustom(Map<String, dynamic>? custom) {
    if (custom == null) return {};
    return Map<String, Object?>.from(custom);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _raw == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text(HomeownerProjectDetailContent.appBarFallbackTitle)),
        body: Center(
          child: Text(_error ?? HomeownerProjectDetailContent.notFound,
              style: BlackLightTextStyles.body()),
        ),
      );
    }

    final p = projectFromApiMap(_raw!);
    final custom = (_raw!['custom_data'] ?? _raw!['customData']) as Map?;
    final customMap = custom?.cast<String, dynamic>();

    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(title: Text(p.address)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.gutter),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProjectStatusBadge(status: p.status),
                    const SizedBox(width: 12),
                    Text(
                      p.type.label,
                      style: BlackLightTextStyles.caption(),
                    ),
                  ],
                ),
                const SizedBox(height: BlackLightSpacing.md),
                Text(HomeownerProjectDetailContent.systemOverviewTitle,
                    style: BlackLightTextStyles.cardHeading()),
                const SizedBox(height: 8),
                Text(
                  HomeownerProjectDetailContent.systemOverviewBody,
                  style: BlackLightTextStyles.body(),
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                Text(HomeownerProjectDetailContent.yourDetailsTitle,
                    style: BlackLightTextStyles.cardHeading()),
                const SizedBox(height: 12),
                DynamicForm(
                  fields: _fieldsFromCustom(customMap),
                  values: _valuesFromCustom(customMap),
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
