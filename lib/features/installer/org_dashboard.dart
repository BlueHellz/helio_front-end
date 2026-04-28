import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import '../../theme/blacklight_theme.dart';
import '../../core/models/project.dart';
import '../../core/widgets/status_badge.dart';

class OrgDashboard extends StatelessWidget {
  final String companyName;
  final List<Project> projects;
  final VoidCallback? onNewProject;
  final VoidCallback? onOpenCrm;
  final void Function(Project)? onProjectTap;

  const OrgDashboard({
    super.key,
    required this.companyName,
    required this.projects,
    this.onNewProject,
    this.onOpenCrm,
    this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrgDashHeader(
            companyName: companyName,
            onNewProject: onNewProject,
            onOpenCrm: onOpenCrm,
          ),
          const SizedBox(height: BlackLightSpacing.lg),
          _KpiRow(projects: projects),
          const SizedBox(height: BlackLightSpacing.lg),
          _ProjectsTable(projects: projects, onTap: onProjectTap),
          const SizedBox(height: BlackLightSpacing.lg),
          _ActivityFeed(),
        ],
      ),
    );
  }
}

class _OrgDashHeader extends StatelessWidget {
  final String companyName;
  final VoidCallback? onNewProject;
  final VoidCallback? onOpenCrm;

  const _OrgDashHeader({
    required this.companyName,
    this.onNewProject,
    this.onOpenCrm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(OrgDashboardContent.operationsTitle,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: 4),
            Text(companyName.isEmpty ? OrgDashboardContent.orgNameFallback : companyName,
                style: BlackLightTextStyles.body()),
          ],
        ),
        const Spacer(),
        if (onOpenCrm != null) ...[
          SizedBox(
            height: BlackLightSpacing.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: onOpenCrm,
              icon: const Icon(Icons.view_kanban_outlined, size: 16),
              label: Text(OrgDashboardContent.crmPipeline,
                  style: BlackLightTextStyles.body(
                      color: BlackLightColors.textPrimary)),
              style: OutlinedButton.styleFrom(
                foregroundColor: BlackLightColors.textPrimary,
                side: const BorderSide(color: BlackLightColors.border),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: BlackLightSpacing.sm),
        ],
        SizedBox(
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onNewProject,
            icon: const Icon(Icons.add, size: 18),
            label: Text(OrgDashboardContent.newProject,
                style: BlackLightTextStyles.bodyBold(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: BlackLightColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  final List<Project> projects;

  const _KpiRow({required this.projects});

  @override
  Widget build(BuildContext context) {
    final total = projects.length;
    final active = projects
        .where((p) =>
            p.status == ProjectStatus.inProgress ||
            p.status == ProjectStatus.designing)
        .length;
    final completed =
        projects.where((p) => p.status == ProjectStatus.completed).length;
    final totalKw =
        projects.fold<double>(0, (s, p) => s + (p.systemSizeKw ?? 0));

    final kpis = [
      (
        OrgDashboardContent.kpiTotalProjects,
        '$total',
        Icons.folder_outlined,
        BlackLightColors.accent
      ),
      (OrgDashboardContent.kpiActive, '$active', Icons.pending_outlined, BlackLightColors.green),
      (
        OrgDashboardContent.kpiCompleted,
        '$completed',
        Icons.check_circle_outline,
        BlackLightColors.textBody
      ),
      (
        OrgDashboardContent.kpiMwDesigned,
        (totalKw / 1000).toStringAsFixed(2),
        Icons.bolt_outlined,
        BlackLightColors.accent
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      if (isWide) {
        return Row(
          children: kpis
              .map((k) => Expanded(child: _KpiCard(kpi: k)))
              .expand((w) => [w, const SizedBox(width: BlackLightSpacing.md)])
              .take(kpis.length * 2 - 1)
              .toList(),
        );
      }
      return Wrap(
        spacing: BlackLightSpacing.sm,
        runSpacing: BlackLightSpacing.sm,
        children: kpis
            .map((k) => SizedBox(
                width: (constraints.maxWidth - BlackLightSpacing.sm) / 2,
                child: _KpiCard(kpi: k)))
            .toList(),
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final (String, String, IconData, Color) kpi;

  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(kpi.$3, size: 16, color: kpi.$4),
              const Spacer(),
            ],
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          Text(kpi.$2,
              style: BlackLightTextStyles.dataLarge(
                  color: BlackLightColors.textPrimary)),
          const SizedBox(height: 2),
          Text(kpi.$1.toUpperCase(),
              style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _ProjectsTable extends StatelessWidget {
  final List<Project> projects;
  final void Function(Project)? onTap;

  const _ProjectsTable({required this.projects, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BlackLightSpacing.md,
                BlackLightSpacing.md, BlackLightSpacing.md, 0),
            child: Text(OrgDashboardContent.activeProjects,
                style: BlackLightTextStyles.cardHeading()),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BlackLightSpacing.md, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                    flex: 4, child: _ColHeader(label: OrgDashboardContent.colAddressClient)),
                const Expanded(flex: 2, child: _ColHeader(label: OrgDashboardContent.colType)),
                const Expanded(
                    flex: 2, child: _ColHeader(label: OrgDashboardContent.colSystemSize)),
                const Expanded(flex: 3, child: _ColHeader(label: OrgDashboardContent.colStatus)),
                const Expanded(flex: 2, child: _ColHeader(label: OrgDashboardContent.colDate)),
              ],
            ),
          ),
          const Divider(height: 0),
          if (projects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(BlackLightSpacing.lg),
              child: Center(child: Text(EmptyStatesContent.noProjectsOrgGrid)),
            )
          else
            ...projects
                .map((p) => _TableRow(project: p, onTap: () => onTap?.call(p))),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;

  const _ColHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10));
  }
}

class _TableRow extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const _TableRow({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: BlackLightSpacing.md, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.address,
                          style: BlackLightTextStyles.body(
                                  color: BlackLightColors.textPrimary)
                              .copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      Text(project.clientName,
                          style: BlackLightTextStyles.caption()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(project.type.label,
                      style:
                          BlackLightTextStyles.body().copyWith(fontSize: 14)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    project.systemSizeKw != null
                        ? '${project.systemSizeKw!.toStringAsFixed(1)}${OrgCrmBoardContent.kwSuffix}'
                        : CommonContent.emDash,
                    style: BlackLightTextStyles.data(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: StatusBadge(status: project.status),
                ),
                Expanded(
                  flex: 2,
                  child: Text(_fmtDate(project.date),
                      style: BlackLightTextStyles.caption()),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    final months = [
      DroneOpsContent.monthJan,
      DroneOpsContent.monthFeb,
      DroneOpsContent.monthMar,
      DroneOpsContent.monthApr,
      DroneOpsContent.monthMay,
      DroneOpsContent.monthJun,
      DroneOpsContent.monthJul,
      DroneOpsContent.monthAug,
      DroneOpsContent.monthSep,
      DroneOpsContent.monthOct,
      DroneOpsContent.monthNov,
      DroneOpsContent.monthDec,
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _ActivityFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BlackLightSpacing.md,
                BlackLightSpacing.md, BlackLightSpacing.md, 0),
            child: Text(OrgDashboardContent.recentActivity,
                style: BlackLightTextStyles.cardHeading()),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(BlackLightSpacing.md),
            child: Column(
              children: [
                _ActivityItem(
                  icon: Icons.note_add_outlined,
                  title: OrgDashboardContent.activityNewProjectTitle,
                  subtitle: OrgDashboardContent.activityNewProjectSubtitle,
                  time: OrgDashboardContent.activityJustNow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            borderRadius: BorderRadius.circular(BlackLightRadius.sm),
            border: Border.all(color: BlackLightColors.border),
          ),
          child: Icon(icon, size: 18, color: BlackLightColors.textBody),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: BlackLightTextStyles.body(
                          color: BlackLightColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 14)),
              Text(subtitle, style: BlackLightTextStyles.caption()),
            ],
          ),
        ),
        Text(time, style: BlackLightTextStyles.caption()),
      ],
    );
  }
}
