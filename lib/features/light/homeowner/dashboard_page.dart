import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/providers/session_providers.dart';
import 'package:blacklight_app/core/widgets/project_status_badge.dart';
import 'package:blacklight_app/services/api.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
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
        padding: const EdgeInsets.all(BlackLightSpacing.gutter),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroDesignCard(onDesign: _openIntake),
                const SizedBox(height: BlackLightSpacing.lg),
                if (hasProjects) ...[
                  _MetricRow(),
                  const SizedBox(height: BlackLightSpacing.lg),
                  Text(
                    HomeownerDashboardContent.yourProjects,
                    style: BlackLightTextStyles.sectionHeading(),
                  ),
                  const SizedBox(height: BlackLightSpacing.sm),
                ],
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: BlackLightTextStyles.body())
                else if (!hasProjects)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        HomeownerDashboardContent.emptyStateMessage,
                        textAlign: TextAlign.center,
                        style: BlackLightTextStyles.body(),
                      ),
                    ),
                  )
                else
                  ..._projects.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: BlackLightColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BlackLightRadius.card),
                          side: const BorderSide(
                              color: BlackLightColors.border),
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BlackLightRadius.card),
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
                                        style: BlackLightTextStyles
                                            .cardHeading(),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        p.type.label,
                                        style: BlackLightTextStyles.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                ProjectStatusBadge(status: p.status),
                                const SizedBox(width: 12),
                                Text(
                                  MaterialLocalizations.of(context)
                                      .formatShortDate(p.date),
                                  style: BlackLightTextStyles.data(
                                    color: BlackLightColors.textCaption,
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
      borderRadius: BorderRadius.circular(BlackLightRadius.md),
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
          style: BlackLightTextStyles.cardHeading(),
        ),
        const SizedBox(height: 8),
        Text(
          HomeownerDashboardContent.heroCardBody,
          style: BlackLightTextStyles.body(),
        ),
        const SizedBox(height: BlackLightSpacing.md),
        SizedBox(
          height: BlackLightSpacing.buttonHeight,
          width: isWide ? null : double.infinity,
          child: ElevatedButton(
            onPressed: onDesign,
            child: Text(
              HomeownerDashboardContent.designMySystemCta,
              style: BlackLightTextStyles.bodyBold(color: Colors.white),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.cardPadding),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                art,
                const SizedBox(width: BlackLightSpacing.lg),
                Expanded(child: copy),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                art,
                const SizedBox(height: BlackLightSpacing.md),
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
              .expand((w) => [w, const SizedBox(width: BlackLightSpacing.md)])
              .take(items.length * 2 - 1)
              .toList(),
        );
      }
      return Column(
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: BlackLightSpacing.sm),
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
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: BlackLightTextStyles.dataLarge(),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
