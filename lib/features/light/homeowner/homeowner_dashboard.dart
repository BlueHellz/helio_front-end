import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'package:limye_app/core/models/project.dart';
import 'package:limye_app/core/illustrations/geometric_illustrations.dart';
import 'package:limye_app/core/widgets/status_badge.dart';

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
      padding: const EdgeInsets.all(LimyeSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(onNewDesign: onNewDesign),
          const SizedBox(height: LimyeSpacing.lg),

          if (projects.isEmpty) ...[
            _EmptyState(onNewDesign: onNewDesign),
          ] else ...[
            Text(HomeownerDashboardContent.yourProjects,
                style: LimyeTextStyles.sectionHeading()),
            const SizedBox(height: LimyeSpacing.md),
            _ProjectsGrid(projects: projects, onTap: onProjectTap),
          ],
          const SizedBox(height: LimyeSpacing.xl),

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
                style: LimyeTextStyles.sectionHeading()),
            const SizedBox(height: 4),
            Text(
              HomeownerDashboardContent.dashboardSubtitle,
              style: LimyeTextStyles.body(),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          height: LimyeSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onNewDesign,
            icon: const Icon(Icons.add, size: 18),
            label: Text(HomeownerDashboardContent.newDesign,
                style: LimyeTextStyles.bodyBold(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: LimyeColors.accent,
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
        padding: const EdgeInsets.symmetric(vertical: LimyeSpacing.xl),
        child: Column(
          children: [
            const IsometricHouseIllustration(width: 320, height: 260),
            const SizedBox(height: LimyeSpacing.md),
            Text(HomeownerDashboardContent.noDesignsTitle,
                style: LimyeTextStyles.cardHeading()),
            const SizedBox(height: LimyeSpacing.xs),
            Text(
              HomeownerDashboardContent.noDesignsBody,
              style: LimyeTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LimyeSpacing.md),
            SizedBox(
              height: LimyeSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onNewDesign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LimyeColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(HomeownerDashboardContent.startDesign,
                    style: LimyeTextStyles.bodyBold(color: Colors.white)),
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
          (constraints.maxWidth - (LimyeSpacing.md * (columns - 1))) /
              columns;

      return Wrap(
        spacing: LimyeSpacing.md,
        runSpacing: LimyeSpacing.md,
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
        padding: const EdgeInsets.all(LimyeSpacing.md),
        decoration: BoxDecoration(
          color: LimyeColors.surface,
          borderRadius: BorderRadius.circular(LimyeRadius.card),
          border: Border.all(color: LimyeColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(project.address,
                      style: LimyeTextStyles.cardHeading(),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: project.status),
              ],
            ),
            const SizedBox(height: LimyeSpacing.sm),
            const Divider(),
            const SizedBox(height: LimyeSpacing.sm),
            Row(
              children: [
                if (project.systemSizeKw != null)
                  _DataRow(
                    label: HomeownerDashboardContent.labelSystemSize,
                    value: '${project.systemSizeKw!.toStringAsFixed(1)} kW',
                  ),
                if (project.panelCount != null) ...[
                  const SizedBox(width: LimyeSpacing.md),
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
                valueColor: LimyeColors.green,
              ),
            ],
            const SizedBox(height: LimyeSpacing.md),
            Row(
              children: [
                Text(
                  _formatDate(project.date),
                  style: LimyeTextStyles.caption(),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: LimyeColors.textCaption),
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
            style: LimyeTextStyles.captionBold(
                    color: LimyeColors.textCaption)
                .copyWith(fontSize: 10)),
        Text(
          value,
          style: LimyeTextStyles.data(
              color: valueColor ?? LimyeColors.textPrimary),
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
            style: LimyeTextStyles.sectionHeading()),
        const SizedBox(height: LimyeSpacing.md),
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
                  color: LimyeColors.green,
                ),
              ),
              SizedBox(
                  width: isWide ? LimyeSpacing.md : 0,
                  height: isWide ? 0 : LimyeSpacing.md),
              Flexible(
                child: _SummaryCard(
                  label: HomeownerDashboardContent.summaryTotalCapacity,
                  value: '${totalKw.toStringAsFixed(1)} kW',
                  icon: Icons.bolt_outlined,
                  color: LimyeColors.accent,
                ),
              ),
              SizedBox(
                  width: isWide ? LimyeSpacing.md : 0,
                  height: isWide ? 0 : LimyeSpacing.md),
              Flexible(
                child: _SummaryCard(
                  label: HomeownerDashboardContent.summaryTotalPanels,
                  value: '$totalPanels',
                  icon: Icons.solar_power_outlined,
                  color: LimyeColors.accent,
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
      padding: const EdgeInsets.all(LimyeSpacing.md),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label.toUpperCase(),
                  style: LimyeTextStyles.captionBold()
                      .copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: LimyeSpacing.xs),
          Text(value, style: LimyeTextStyles.dataLarge(color: color)),
        ],
      ),
    );
  }
}
