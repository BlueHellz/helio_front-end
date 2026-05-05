import 'package:limye_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/illustrations/geometric_illustrations.dart';
import 'package:limye_app/core/models/project.dart';
import 'package:limye_app/core/providers/session_providers.dart';
import 'package:limye_app/core/widgets/project_status_badge.dart';
import 'package:limye_app/services/api.dart';
import 'package:limye_app/theme/limye_theme.dart';
import 'intake_page.dart';
import 'project_detail_page.dart' as ho_detail;

class HomeownerDashboardPage extends ConsumerStatefulWidget {
  const HomeownerDashboardPage({super.key});

  @override
  ConsumerState<HomeownerDashboardPage> createState() =>
      _HomeownerDashboardPageState();
}

class _HomeownerDashboardPageState extends ConsumerState<HomeownerDashboardPage> {
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

  Future<void> _openIntake() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HomeownerIntakePage(),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final hasProjects = _projects.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(LimyeSpacing.gutter),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroDesignCard(onDesign: _openIntake),
                const SizedBox(height: LimyeSpacing.lg),
                if (hasProjects) ...[
                  _MetricRow(),
                  const SizedBox(height: LimyeSpacing.lg),
                  Text(
                    HomeownerDashboardContent.yourProjects,
                    style: LimyeTextStyles.sectionHeading(),
                  ),
                  const SizedBox(height: LimyeSpacing.sm),
                ],
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: LimyeTextStyles.body())
                else if (!hasProjects)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        HomeownerDashboardContent.emptyStateMessage,
                        textAlign: TextAlign.center,
                        style: LimyeTextStyles.body(),
                      ),
                    ),
                  )
                else
                  ..._projects.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: LimyeColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(LimyeRadius.card),
                          side: const BorderSide(
                              color: LimyeColors.border),
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(LimyeRadius.card),
                          onTap: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => ho_detail
                                    .HomeownerProjectDetailPage(projectId: p.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.address,
                                        style: LimyeTextStyles
                                            .cardHeading(),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        p.type.label,
                                        style: LimyeTextStyles.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                ProjectStatusBadge(status: p.status),
                                const SizedBox(width: 12),
                                Text(
                                  MaterialLocalizations.of(context)
                                      .formatShortDate(p.date),
                                  style: LimyeTextStyles.data(
                                    color: LimyeColors.textCaption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

class _HeroDesignCard extends StatelessWidget {
  const _HeroDesignCard({required this.onDesign});

  final VoidCallback onDesign;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 640;

    final art = ClipRRect(
      borderRadius: BorderRadius.circular(LimyeRadius.md),
      child: SizedBox(
        width: isWide ? 220 : double.infinity,
        height: 140,
        child: const ActiveRoofDesign(width: 220, height: 140),
      ),
    );

    final copy = Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      children: [
        Text(
          HomeownerDashboardContent.heroCardTitle,
          style: LimyeTextStyles.cardHeading(),
        ),
        const SizedBox(height: 8),
        Text(
          HomeownerDashboardContent.heroCardBody,
          style: LimyeTextStyles.body(),
        ),
        const SizedBox(height: LimyeSpacing.md),
        SizedBox(
          height: LimyeSpacing.buttonHeight,
          width: isWide ? null : double.infinity,
          child: ElevatedButton(
            onPressed: onDesign,
            child: Text(
              HomeownerDashboardContent.designMySystemCta,
              style: LimyeTextStyles.bodyBold(color: Colors.white),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(LimyeSpacing.cardPadding),
      decoration: BoxDecoration(
        color: LimyeColors.surface,
        borderRadius: BorderRadius.circular(LimyeRadius.card),
        border: Border.all(color: LimyeColors.border),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                art,
                const SizedBox(width: LimyeSpacing.lg),
                Expanded(child: copy),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                art,
                const SizedBox(height: LimyeSpacing.md),
                copy,
              ],
            ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        HomeownerDashboardContent.metricTotalSavings,
        HomeownerDashboardContent.metricPlaceholder,
      ),
      (
        HomeownerDashboardContent.metricSystemsInstalled,
        HomeownerDashboardContent.metricPlaceholder,
      ),
      (
        HomeownerDashboardContent.metricEnergyProduced,
        HomeownerDashboardContent.metricPlaceholder,
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 640;
      if (wide) {
        return Row(
          children: items
              .map((e) => Expanded(child: _MetricTile(label: e.$1, value: e.$2)))
              .expand((w) => [w, const SizedBox(width: LimyeSpacing.md)])
              .take(items.length * 2 - 1)
              .toList(),
        );
      }
      return Column(
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: LimyeSpacing.sm),
                  child: _MetricTile(label: e.$1, value: e.$2),
                ))
            .toList(),
      );
    });
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

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
          Text(
            value,
            style: LimyeTextStyles.dataLarge(),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: LimyeTextStyles.captionBold().copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
