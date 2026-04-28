import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/project.dart';
import '../../core/providers/session_providers.dart';
import '../../core/widgets/project_status_badge.dart';
import '../../services/api.dart';
import '../../theme/blacklight_theme.dart';
import 'intake_page.dart';
import 'project_detail_page.dart' as ho_detail;

class HomeownerDashboardPage extends ConsumerStatefulWidget {
  const HomeownerDashboardPage({super.key});

  @override
  ConsumerState<HomeownerDashboardPage> createState() =>
      _HomeownerDashboardPageState();
}

class _HomeownerDashboardPageState
    extends ConsumerState<HomeownerDashboardPage> {
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
                Text(HomeownerDashboardContent.myProjectsPageTitle,
                    style: BlackLightTextStyles.sectionHeading()),
                const SizedBox(height: BlackLightSpacing.md),
                SizedBox(
                  height: BlackLightSpacing.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomeownerIntakePage(),
                        ),
                      );
                      _load();
                    },
                    child: Text(HomeownerDashboardContent.newDesign),
                  ),
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: BlackLightTextStyles.body())
                else if (_projects.isEmpty)
                  Text(
                    HomeownerDashboardContent.noProjectsInline,
                    style: BlackLightTextStyles.body(),
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
                            padding: const EdgeInsets.all(20),
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
                                      const SizedBox(height: 4),
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
