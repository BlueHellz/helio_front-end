import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dynamic_form.dart';
import '../../core/models/project.dart';
import '../../core/providers/session_providers.dart';
import '../../core/ui/app_feedback.dart';
import '../../core/widgets/project_status_badge.dart';
import '../../services/api.dart';
import '../../theme/blacklight_theme.dart';

class OrgProjectDetailPage extends ConsumerStatefulWidget {
  const OrgProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<OrgProjectDetailPage> createState() =>
      _OrgProjectDetailPageState();
}

class _OrgProjectDetailPageState extends ConsumerState<OrgProjectDetailPage> {
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

  List<DynamicFieldDef> _defs(Map<String, dynamic>? custom) {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _raw == null) {
      return Scaffold(
        appBar: AppBar(title: Text(OrgProjectDetailContent.appBarFallback)),
        body: Center(child: Text(_error ?? OrgProjectDetailContent.notFound)),
      );
    }

    final p = projectFromApiMap(_raw!);
    final custom = (_raw!['custom_data'] ?? _raw!['customData']) as Map?;
    final customMap = custom?.cast<String, dynamic>();

    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(
        title: Text(p.address),
        actions: [
          TextButton(
            onPressed: () {
              AppFeedback.snack(context, OrgProjectDetailContent.reportDownloadSnack);
            },
            child: Text(OrgProjectDetailContent.downloadReport),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.gutter),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProjectStatusBadge(status: p.status),
                    const SizedBox(width: 12),
                    Text(p.type.label, style: BlackLightTextStyles.caption()),
                  ],
                ),
                const SizedBox(height: BlackLightSpacing.md),
                Text(OrgProjectDetailContent.systemSpecs, style: BlackLightTextStyles.cardHeading()),
                const SizedBox(height: 8),
                Text(
                  p.systemSizeKw != null
                      ? '${p.systemSizeKw}${OrgCrmBoardContent.kwSuffix}${OrgProjectDetailContent.specSeparator}${p.panelCount ?? CommonContent.emDash}${OrgProjectDetailContent.panelsSuffix}'
                      : OrgProjectDetailContent.specsNotGenerated,
                  style: BlackLightTextStyles.data(),
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                Text(OrgProjectDetailContent.projectData, style: BlackLightTextStyles.cardHeading()),
                const SizedBox(height: 12),
                DynamicForm(
                  fields: _defs(customMap),
                  values: Map<String, Object?>.from(customMap ?? {}),
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
