import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/widgets/status_badge.dart';

class HomeownerDashboard extends StatelessWidget {
  final List<Project> projects;
  final VoidCallback? onNewDesign;
  final void Function(Project)? onProjectTap;

  const HomeownerDashboard({
    super.key,
    required this.projects,
    this.onNewDesign,
    this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(onNewDesign: onNewDesign),
          const SizedBox(height: BlackLightSpacing.lg),

          if (projects.isEmpty) ...[
            _EmptyState(onNewDesign: onNewDesign),
          ] else ...[
            Text(HomeownerDashboardContent.yourProjects,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: BlackLightSpacing.md),
            _ProjectsGrid(projects: projects, onTap: onProjectTap),
          ],
          const SizedBox(height: BlackLightSpacing.xl),

          // Savings summary row
          if (projects.isNotEmpty) _SavingsSummary(projects: projects),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final VoidCallback? onNewDesign;

  const _DashboardHeader({this.onNewDesign});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(HomeownerDashboardContent.yourSolarDashboard,
                style: BlackLightTextStyles.sectionHeading()),
            const SizedBox(height: 4),
            Text(
              HomeownerDashboardContent.dashboardSubtitle,
              style: BlackLightTextStyles.body(),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onNewDesign,
            icon: const Icon(Icons.add, size: 18),
            label: Text(HomeownerDashboardContent.newDesign,
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

class _EmptyState extends StatelessWidget {
  final VoidCallback? onNewDesign;

  const _EmptyState({this.onNewDesign});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BlackLightSpacing.xl),
        child: Column(
          children: [
            const IsometricHouseIllustration(width: 320, height: 260),
            const SizedBox(height: BlackLightSpacing.md),
            Text(HomeownerDashboardContent.noDesignsTitle,
                style: BlackLightTextStyles.cardHeading()),
            const SizedBox(height: BlackLightSpacing.xs),
            Text(
              HomeownerDashboardContent.noDesignsBody,
              style: BlackLightTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BlackLightSpacing.md),
            SizedBox(
              height: BlackLightSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onNewDesign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlackLightColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(HomeownerDashboardContent.startDesign,
                    style: BlackLightTextStyles.bodyBold(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsGrid extends StatelessWidget {
  final List<Project> projects;
  final void Function(Project)? onTap;

  const _ProjectsGrid({required this.projects, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 900
          ? 3
          : constraints.maxWidth > 600
              ? 2
              : 1;
      final itemWidth =
          (constraints.maxWidth - (BlackLightSpacing.md * (columns - 1))) /
              columns;

      return Wrap(
        spacing: BlackLightSpacing.md,
        runSpacing: BlackLightSpacing.md,
        children: projects
            .map((p) => SizedBox(
                  width: itemWidth,
                  child: _ProjectCard(project: p, onTap: () => onTap?.call(p)),
                ))
            .toList(),
      );
    });
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const _ProjectCard({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Expanded(
                  child: Text(project.address,
                      style: BlackLightTextStyles.cardHeading(),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: project.status),
              ],
            ),
            const SizedBox(height: BlackLightSpacing.sm),
            const Divider(),
            const SizedBox(height: BlackLightSpacing.sm),
            Row(
              children: [
                if (project.systemSizeKw != null)
                  _DataRow(
                    label: HomeownerDashboardContent.labelSystemSize,
                    value: '${project.systemSizeKw!.toStringAsFixed(1)} kW',
                  ),
                if (project.panelCount != null) ...[
                  const SizedBox(width: BlackLightSpacing.md),
                  _DataRow(label: HomeownerDashboardContent.labelPanels, value: '${project.panelCount}'),
                ],
              ],
            ),
            if (project.annualProductionKwh != null) ...[
              const SizedBox(height: 8),
              _DataRow(
                label: HomeownerDashboardContent.labelAnnualProduction,
                value: '${_fmt(project.annualProductionKwh!)} kWh',
              ),
            ],
            if (project.yearOneSavings != null) ...[
              const SizedBox(height: 8),
              _DataRow(
                label: HomeownerDashboardContent.labelYearOneSavings,
                value: '\$${_fmt(project.yearOneSavings!)}',
                valueColor: BlackLightColors.green,
              ),
            ],
            const SizedBox(height: BlackLightSpacing.md),
            Row(
              children: [
                Text(
                  _formatDate(project.date),
                  style: BlackLightTextStyles.caption(),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: BlackLightColors.textCaption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  String _formatDate(DateTime d) {
    final months = [
      HomeownerDashboardContent.monthJan,
      HomeownerDashboardContent.monthFeb,
      HomeownerDashboardContent.monthMar,
      HomeownerDashboardContent.monthApr,
      HomeownerDashboardContent.monthMay,
      HomeownerDashboardContent.monthJun,
      HomeownerDashboardContent.monthJul,
      HomeownerDashboardContent.monthAug,
      HomeownerDashboardContent.monthSep,
      HomeownerDashboardContent.monthOct,
      HomeownerDashboardContent.monthNov,
      HomeownerDashboardContent.monthDec,
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DataRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.captionBold(
                    color: BlackLightColors.textCaption)
                .copyWith(fontSize: 10)),
        Text(
          value,
          style: BlackLightTextStyles.data(
              color: valueColor ?? BlackLightColors.textPrimary),
        ),
      ],
    );
  }
}

class _SavingsSummary extends StatelessWidget {
  final List<Project> projects;

  const _SavingsSummary({required this.projects});

  @override
  Widget build(BuildContext context) {
    final totalSavings =
        projects.fold<double>(0, (sum, p) => sum + (p.yearOneSavings ?? 0));
    final totalKw =
        projects.fold<double>(0, (sum, p) => sum + (p.systemSizeKw ?? 0));
    final totalPanels =
        projects.fold<int>(0, (sum, p) => sum + (p.panelCount ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(HomeownerDashboardContent.summaryHeading,
            style: BlackLightTextStyles.sectionHeading()),
        const SizedBox(height: BlackLightSpacing.md),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              Flexible(
                child: _SummaryCard(
                  label: HomeownerDashboardContent.summaryYearOneSavings,
                  value: '\$${totalSavings.toStringAsFixed(0)}',
                  icon: Icons.savings_outlined,
                  color: BlackLightColors.green,
                ),
              ),
              SizedBox(
                  width: isWide ? BlackLightSpacing.md : 0,
                  height: isWide ? 0 : BlackLightSpacing.md),
              Flexible(
                child: _SummaryCard(
                  label: HomeownerDashboardContent.summaryTotalCapacity,
                  value: '${totalKw.toStringAsFixed(1)} kW',
                  icon: Icons.bolt_outlined,
                  color: BlackLightColors.accent,
                ),
              ),
              SizedBox(
                  width: isWide ? BlackLightSpacing.md : 0,
                  height: isWide ? 0 : BlackLightSpacing.md),
              Flexible(
                child: _SummaryCard(
                  label: HomeownerDashboardContent.summaryTotalPanels,
                  value: '$totalPanels',
                  icon: Icons.solar_power_outlined,
                  color: BlackLightColors.accent,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

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
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label.toUpperCase(),
                  style: BlackLightTextStyles.captionBold()
                      .copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: BlackLightSpacing.xs),
          Text(value, style: BlackLightTextStyles.dataLarge(color: color)),
        ],
      ),
    );
  }
}
