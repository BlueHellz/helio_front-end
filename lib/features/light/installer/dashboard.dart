import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/widgets/status_badge.dart';
import 'package:blacklight_app/features/light/installer/org/project_detail_page.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Free-tier installer home: welcome, quick actions, KPI row, recent projects.
class FreeInstallerDashboardPage extends ConsumerStatefulWidget {
  const FreeInstallerDashboardPage({
    super.key,
    required this.companyName,
    required this.onNewProject,
    required this.onImportLeads,
  });

  final String companyName;
  final VoidCallback onNewProject;
  final VoidCallback onImportLeads;

  @override
  ConsumerState<FreeInstallerDashboardPage> createState() =>
      _FreeInstallerDashboardPageState();
}

class _FreeInstallerDashboardPageState
    extends ConsumerState<FreeInstallerDashboardPage> {
  List<Project> _projects = const [];
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
      final raw = await api.listProjects();
      if (!mounted) return;
      setState(() {
        _projects = raw.map(projectFromApiMap).toList();
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

  @override
  Widget build(BuildContext context) {
    final border = BlackLightAdaptive.border(context);
    final surface = BlackLightAdaptive.surface(context);
    final tPrimary = BlackLightAdaptive.textPrimary(context);
    final tBody = BlackLightAdaptive.textBody(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(BlackLightSpacing.gutter),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrgDashboardContent.operationsTitle,
                  style: BlackLightTextStyles.sectionHeading(color: tPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.companyName.isEmpty
                      ? OrgDashboardContent.orgNameFallback
                      : widget.companyName,
                  style: BlackLightTextStyles.body(color: tBody),
                ),
                const SizedBox(height: 6),
                Text(
                  OrgDashboardContent.welcomeLine,
                  style: BlackLightTextStyles.body(color: tBody),
                ),
                const SizedBox(height: BlackLightSpacing.md),
                Wrap(
                  spacing: BlackLightSpacing.sm,
                  runSpacing: BlackLightSpacing.sm,
                  children: [
                    SizedBox(
                      height: BlackLightSpacing.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: widget.onNewProject,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          OrgDashboardContent.quickActionNewProject,
                          style:
                              BlackLightTextStyles.bodyBold(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: BlackLightSpacing.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: widget.onImportLeads,
                        icon: const Icon(Icons.upload_file_outlined, size: 16),
                        label: Text(
                          OrgDashboardContent.quickActionImportLeads,
                          style: BlackLightTextStyles.body(color: tPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tPrimary,
                          side: BorderSide(color: border),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                FreeInstallerMetricsRow(
                  border: border,
                  surface: surface,
                  tPrimary: tPrimary,
                  tBody: tBody,
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                Text(
                  OrgDashboardContent.recentProjectsHeading,
                  style: BlackLightTextStyles.cardHeading(color: tPrimary),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Text(_error!, style: BlackLightTextStyles.body(color: tBody))
                else if (_projects.isEmpty)
                  FreeInstallerEmptyState(
                    border: border,
                    surface: surface,
                    tPrimary: tPrimary,
                    tBody: tBody,
                  )
                else
                  ..._projects.take(8).map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FreeInstallerProjectRowCard(
                            project: p,
                            border: border,
                            surface: surface,
                            tPrimary: tPrimary,
                            tBody: tBody,
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      OrgProjectDetailPage(projectId: p.id),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FreeInstallerMetricsRow extends StatelessWidget {
  const FreeInstallerMetricsRow({
    super.key,
    required this.border,
    required this.surface,
    required this.tPrimary,
    required this.tBody,
  });

  final Color border;
  final Color surface;
  final Color tPrimary;
  final Color tBody;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        OrgDashboardContent.freeMetricActiveProjects,
        OrgDashboardContent.freeMetricPlaceholderZero,
        Icons.folder_outlined,
        BlackLightColors.accent,
      ),
      (
        OrgDashboardContent.freeMetricPipelineValue,
        OrgDashboardContent.freeMetricPlaceholderMoney,
        Icons.trending_up,
        BlackLightColors.green,
      ),
      (
        OrgDashboardContent.freeMetricClosedMonth,
        OrgDashboardContent.freeMetricPlaceholderZero,
        Icons.check_circle_outline,
        BlackLightColors.accent,
      ),
      (
        OrgDashboardContent.freeMetricAvgCloseTime,
        OrgDashboardContent.freeMetricPlaceholderDash,
        Icons.schedule,
        BlackLightColors.textBody,
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 720;
      if (wide) {
        return Row(
          children: metrics
              .map((m) => Expanded(
                    child: _MetricCard(
                      label: m.$1,
                      value: m.$2,
                      icon: m.$3,
                      iconColor: m.$4,
                      border: border,
                      surface: surface,
                      tPrimary: tPrimary,
                      tBody: tBody,
                    ),
                  ))
              .expand((w) => [w, const SizedBox(width: BlackLightSpacing.md)])
              .take(metrics.length * 2 - 1)
              .toList(),
        );
      }
      return Wrap(
        spacing: BlackLightSpacing.sm,
        runSpacing: BlackLightSpacing.sm,
        children: metrics
            .map(
              (m) => SizedBox(
                width: (c.maxWidth - BlackLightSpacing.sm) / 2,
                child: _MetricCard(
                  label: m.$1,
                  value: m.$2,
                  icon: m.$3,
                  iconColor: m.$4,
                  border: border,
                  surface: surface,
                  tPrimary: tPrimary,
                  tBody: tBody,
                ),
              ),
            )
            .toList(),
      );
    });
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.border,
    required this.surface,
    required this.tPrimary,
    required this.tBody,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color border;
  final Color surface;
  final Color tPrimary;
  final Color tBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: BlackLightSpacing.sm),
          Text(
            value,
            style: BlackLightTextStyles.dataLarge(color: tPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: BlackLightTextStyles.captionBold(color: tBody)
                .copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class FreeInstallerEmptyState extends StatelessWidget {
  const FreeInstallerEmptyState({
    super.key,
    required this.border,
    required this.surface,
    required this.tPrimary,
    required this.tBody,
  });

  final Color border;
  final Color surface;
  final Color tPrimary;
  final Color tBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Text(
            OrgDashboardContent.emptyInstallerTitle,
            style: BlackLightTextStyles.cardHeading(color: tPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            OrgDashboardContent.emptyInstallerBody,
            textAlign: TextAlign.center,
            style: BlackLightTextStyles.body(color: tBody),
          ),
        ],
      ),
    );
  }
}

class FreeInstallerProjectRowCard extends StatelessWidget {
  const FreeInstallerProjectRowCard({
    super.key,
    required this.project,
    required this.border,
    required this.surface,
    required this.tPrimary,
    required this.tBody,
    required this.onTap,
  });

  final Project project;
  final Color border;
  final Color surface;
  final Color tPrimary;
  final Color tBody;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.address,
                      style: BlackLightTextStyles.body(color: tPrimary)
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.clientName,
                      style: BlackLightTextStyles.caption(color: tBody),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: project.status),
              const SizedBox(width: 12),
              Text(
                project.systemSizeKw != null
                    ? '${project.systemSizeKw!.toStringAsFixed(1)}${OrgCrmBoardContent.kwSuffix}'
                    : CommonContent.emDash,
                style: BlackLightTextStyles.data(color: tPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
