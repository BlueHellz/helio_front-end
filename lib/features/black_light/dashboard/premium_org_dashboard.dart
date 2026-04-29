import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/features/light/installer/dashboard.dart';
import 'package:blacklight_app/features/light/installer/org/project_detail_page.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Black Light premium org home: free-tier layout plus revenue chart and feed.
class PremiumOrgDashboardPage extends ConsumerStatefulWidget {
  const PremiumOrgDashboardPage({
    super.key,
    required this.companyName,
    required this.onNewProject,
    required this.onImportLeads,
  });

  final String companyName;
  final VoidCallback onNewProject;
  final VoidCallback onImportLeads;

  @override
  ConsumerState<PremiumOrgDashboardPage> createState() =>
      _PremiumOrgDashboardPageState();
}

class _PremiumOrgDashboardPageState
    extends ConsumerState<PremiumOrgDashboardPage> {
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
                          style: BlackLightTextStyles.bodyBold(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
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
                  PremiumOrgDashboardContent.revenueChartTitle,
                  style: BlackLightTextStyles.cardHeading(color: tPrimary),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(BlackLightRadius.card),
                    border: Border.all(color: border),
                  ),
                  padding: const EdgeInsets.all(BlackLightSpacing.md),
                  child: CustomPaint(
                    painter: _StaticRevenueBarsPainter(
                      borderColor: border,
                      accent: BlackLightColors.accent,
                    ),
                  ),
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
                const SizedBox(height: BlackLightSpacing.lg),
                Text(
                  PremiumOrgDashboardContent.activityTitle,
                  style: BlackLightTextStyles.cardHeading(color: tPrimary),
                ),
                const SizedBox(height: BlackLightSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(BlackLightRadius.card),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      _PremiumFeedRow(
                        icon: Icons.receipt_long_outlined,
                        title: PremiumOrgDashboardContent.feed1Title,
                        subtitle: PremiumOrgDashboardContent.feed1Subtitle,
                        time: PremiumOrgDashboardContent.feed1Time,
                        border: border,
                        tPrimary: tPrimary,
                        tBody: tBody,
                      ),
                      Divider(height: 0, color: border),
                      _PremiumFeedRow(
                        icon: Icons.draw_outlined,
                        title: PremiumOrgDashboardContent.feed2Title,
                        subtitle: PremiumOrgDashboardContent.feed2Subtitle,
                        time: PremiumOrgDashboardContent.feed2Time,
                        border: border,
                        tPrimary: tPrimary,
                        tBody: tBody,
                      ),
                      Divider(height: 0, color: border),
                      _PremiumFeedRow(
                        icon: Icons.group_add_outlined,
                        title: PremiumOrgDashboardContent.feed3Title,
                        subtitle: PremiumOrgDashboardContent.feed3Subtitle,
                        time: PremiumOrgDashboardContent.feed3Time,
                        border: border,
                        tPrimary: tPrimary,
                        tBody: tBody,
                      ),
                      Divider(height: 0, color: border),
                      _PremiumFeedRow(
                        icon: Icons.approval_outlined,
                        title: PremiumOrgDashboardContent.feed4Title,
                        subtitle: PremiumOrgDashboardContent.feed4Subtitle,
                        time: PremiumOrgDashboardContent.feed4Time,
                        border: border,
                        tPrimary: tPrimary,
                        tBody: tBody,
                      ),
                    ],
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

class _PremiumFeedRow extends StatelessWidget {
  const _PremiumFeedRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.border,
    required this.tPrimary,
    required this.tBody,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color border;
  final Color tPrimary;
  final Color tBody;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BlackLightSpacing.md,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BlackLightAdaptive.background(context),
              borderRadius: BorderRadius.circular(BlackLightRadius.sm),
              border: Border.all(color: border),
            ),
            child: Icon(icon, size: 18, color: tBody),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BlackLightTextStyles.body(color: tPrimary).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: BlackLightTextStyles.caption(color: tBody),
                ),
              ],
            ),
          ),
          Text(time, style: BlackLightTextStyles.caption(color: tBody)),
        ],
      ),
    );
  }
}

class _StaticRevenueBarsPainter extends CustomPainter {
  _StaticRevenueBarsPainter({
    required this.borderColor,
    required this.accent,
  });

  final Color borderColor;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final n = 8;
    final gap = 6.0;
    final barW = (size.width - gap * (n - 1)) / n;
    final heights = <double>[0.35, 0.45, 0.42, 0.62, 0.55, 0.78, 0.7, 0.85];
    for (int i = 0; i < n; i++) {
      final h = size.height * 0.85 * heights[i];
      final left = i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height * 0.9 - h, barW, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = accent.withValues(alpha: 0.85));
      canvas.drawRRect(
        rect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    final axis = Paint()
      ..color = borderColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.9),
      Offset(size.width, size.height * 0.9),
      axis,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
