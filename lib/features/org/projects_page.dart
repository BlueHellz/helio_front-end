import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/project_status_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/providers/session_providers.dart';
import '../../theme/blacklight_theme.dart';
import 'new_project_page.dart';
import 'project_detail_page.dart' as org_detail;

class OrgProjectsPage extends ConsumerStatefulWidget {
  const OrgProjectsPage({
    super.key,
    required this.orgName,
    required this.walletBalance,
  });

  final String orgName;
  final double walletBalance;

  @override
  ConsumerState<OrgProjectsPage> createState() => _OrgProjectsPageState();
}

class _OrgProjectsPageState extends ConsumerState<OrgProjectsPage> {
  int _tab = 0;
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _filterType {
    switch (_tab) {
      case 1:
        return 'residential';
      case 2:
        return 'commercial';
      case 3:
        return 'industrial';
      default:
        return null;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiProvider);
      final raw = await api.listProjects(projectType: _filterType);
      if (!mounted) return;
      setState(() {
        _items = raw;
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
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.orgName.isEmpty
                                  ? OrgProjectsListContent.organizationFallback
                                  : widget.orgName,
                              style: BlackLightTextStyles.sectionHeading(),
                            ),
                            Text(
                              OrgProjectsListContent.projectsCaption,
                              style: BlackLightTextStyles.caption(),
                            ),
                          ],
                        ),
                      ),
                      WalletChip(balance: widget.walletBalance),
                    ],
                  ),
                  const SizedBox(height: BlackLightSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(OrgProjectsListContent.filterAll, 0),
                      _pill(OrgProjectsListContent.filterResidential, 1),
                      _pill(OrgProjectsListContent.filterCommercial, 2),
                      _pill(OrgProjectsListContent.filterIndustrial, 3),
                    ],
                  ),
                  const SizedBox(height: BlackLightSpacing.md),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Text(_error!, style: BlackLightTextStyles.body())
                  else if (_items.isEmpty)
                    Text(EmptyStatesContent.noProjectsWeb,
                        style: BlackLightTextStyles.body())
                  else
                    ..._items.map(_card),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 24 +
              MediaQuery.of(context).padding.bottom +
              (kIsWeb ? BlackLightSpacing.footerHeight : 64),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context)
                  .push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const OrgNewProjectPage(),
                ),
              )
                  .then((_) => _load());
            },
            icon: const Icon(Icons.add),
            label: const Text(OrgProjectsListContent.fabNewProject),
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, int idx) {
    final on = _tab == idx;
    return FilterChip(
      label: Text(label),
      selected: on,
      onSelected: (_) {
        setState(() => _tab = idx);
        _load();
      },
    );
  }

  Widget _card(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? '';
    final address = (m['address'] ?? '').toString();
    final dateRaw = m['date'] ?? m['created_at'];
    DateTime date = DateTime.now();
    if (dateRaw is String) {
      date = DateTime.tryParse(dateRaw) ?? date;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: BlackLightColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          side: const BorderSide(color: BlackLightColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address, style: BlackLightTextStyles.cardHeading()),
                    const SizedBox(height: 6),
                    Text(
                      (m['project_type'] ?? m['type'] ?? '').toString(),
                      style: BlackLightTextStyles.caption(),
                    ),
                  ],
                ),
              ),
              ProjectStatusBadge(statusRaw: m['status'] as String?),
              const SizedBox(width: 12),
              Text(
                MaterialLocalizations.of(context).formatShortDate(date),
                style: BlackLightTextStyles.data(
                  color: BlackLightColors.textCaption,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          org_detail.OrgProjectDetailPage(projectId: id),
                    ),
                  );
                },
                child: Text(OrgProjectsListContent.viewButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
