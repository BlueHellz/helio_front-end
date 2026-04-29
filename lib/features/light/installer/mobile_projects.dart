import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/widgets/status_badge.dart';

class MobileProjects extends StatefulWidget {
  final List<Project> projects;
  final void Function(Project)? onProjectTap;
  final VoidCallback? onNewProject;

  const MobileProjects({
    super.key,
    required this.projects,
    this.onProjectTap,
    this.onNewProject,
  });

  @override
  State<MobileProjects> createState() => _MobileProjectsState();
}

class _MobileProjectsState extends State<MobileProjects> {
  String _search = '';
  ProjectStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    final filtered = widget.projects
        .where((p) =>
            (_search.isEmpty ||
                p.address.toLowerCase().contains(_search.toLowerCase()) ||
                p.clientName.toLowerCase().contains(_search.toLowerCase())) &&
            (_filterStatus == null || p.status == _filterStatus))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(OrgMobileInstallerContent.projectsTitle,
              style: BlackLightTextStyles.mobileH2(color: c.onSurface)),
          backgroundColor: c.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          floating: true,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: c.primary),
              onPressed: widget.onNewProject,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(BlackLightSpacing.sm, 0,
                  BlackLightSpacing.sm, BlackLightSpacing.sm),
              child: SizedBox(
                height: 44,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: BlackLightTextStyles.mobileBody(color: c.onSurface),
                  decoration: InputDecoration(
                    hintText: OrgMobileInstallerContent.searchProjectsHint,
                    hintStyle: BlackLightTextStyles.mobileBody(color: variant),
                    prefixIcon: Icon(Icons.search, size: 18, color: variant),
                    filled: true,
                    fillColor: c.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(color: c.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(color: c.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide:
                          BorderSide(color: c.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyHouseIllustration(),
                  const SizedBox(height: BlackLightSpacing.md),
                  Text(EmptyStatesContent.noProjectsMobileTitle,
                      style: BlackLightTextStyles.mobileH3(
                          color: c.onSurface)),
                  const SizedBox(height: 4),
                  Text(EmptyStatesContent.noProjectsMobileSubtitle,
                      style: BlackLightTextStyles.mobileBody(color: variant)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(BlackLightSpacing.sm),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: BlackLightSpacing.sm),
                  child: _MobileProjectCard(
                    project: filtered[i],
                    onTap: () => widget.onProjectTap?.call(filtered[i]),
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _MobileProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const _MobileProjectCard({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(BlackLightSpacing.sm),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          border: Border.all(color: c.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(project.clientName,
                      style: BlackLightTextStyles.mobileH3(
                          color: c.onSurface),
                      overflow: TextOverflow.ellipsis),
                ),
                StatusBadge(status: project.status),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: variant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(project.address,
                      style: BlackLightTextStyles.mobileBody(color: variant),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: BlackLightSpacing.sm),
            const Divider(height: 0),
            const SizedBox(height: BlackLightSpacing.sm),
            Row(
              children: [
                if (project.systemSizeKw != null)
                  _MiniChip(
                      icon: Icons.bolt_outlined,
                      label: '${project.systemSizeKw!.toStringAsFixed(1)} kW'),
                if (project.panelCount != null) ...[
                  const SizedBox(width: 8),
                  _MiniChip(
                      icon: Icons.solar_power_outlined,
                      label: '${project.panelCount} panels'),
                ],
                const Spacer(),
                Text(_fmtDate(project.date),
                    style: BlackLightTextStyles.mobileBody(color: variant)
                        .copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: variant),
          const SizedBox(width: 4),
          Text(label,
              style: BlackLightTextStyles.mobileBody(color: variant)
                  .copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
