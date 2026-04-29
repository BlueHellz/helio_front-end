import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';

class MobileCrm extends StatefulWidget {
  final List<Lead> leads;
  final VoidCallback? onAddLead;
  final void Function(Lead)? onLeadTap;

  const MobileCrm({
    super.key,
    required this.leads,
    this.onAddLead,
    this.onLeadTap,
  });

  @override
  State<MobileCrm> createState() => _MobileCrmState();
}

class _MobileCrmState extends State<MobileCrm> {
  LeadStage? _activeStage;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    final filtered = widget.leads.where((l) {
      final matchesSearch = _search.isEmpty ||
          l.name.toLowerCase().contains(_search.toLowerCase());
      final matchesStage = _activeStage == null || l.stage == _activeStage;
      return matchesSearch && matchesStage;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(OrgCrmBoardContent.pageTitle,
              style: BlackLightTextStyles.mobileH2(color: c.onSurface)),
          backgroundColor: c.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          pinned: true,
          floating: true,
          actions: [
            IconButton(
              icon: Icon(Icons.person_add_outlined, color: c.primary),
              onPressed: widget.onAddLead,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(106),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(BlackLightSpacing.sm, 0,
                      BlackLightSpacing.sm, BlackLightSpacing.xs),
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: BlackLightTextStyles.mobileBody(color: c.onSurface),
                      decoration: InputDecoration(
                        hintText: OrgCrmBoardContent.searchLeadsHint,
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
                          borderSide: BorderSide(
                              color: c.primary, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: BlackLightSpacing.sm, vertical: 8),
                    children: [
                      _StageChip(
                        label: OrgMobileInstallerContent.filterAll,
                        isActive: _activeStage == null,
                        color: variant,
                        onTap: () => setState(() => _activeStage = null),
                      ),
                      ...LeadStage.values.map((s) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _StageChip(
                              label: s.label,
                              isActive: _activeStage == s,
                              color: s.stageColorIn(context),
                              onTap: () => setState(() =>
                                  _activeStage = _activeStage == s ? null : s),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, size: 40, color: c.outline),
                  const SizedBox(height: BlackLightSpacing.sm),
                  Text(EmptyStatesContent.noLeadsTitle,
                      style: BlackLightTextStyles.mobileH3(color: c.onSurface)),
                  Text(EmptyStatesContent.noLeadsSubtitle,
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
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: BlackLightSpacing.sm),
                  child: _MobileLeadCard(
                    lead: filtered[i],
                    onTap: () => widget.onLeadTap?.call(filtered[i]),
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

class _StageChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _StageChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? color : c.outline,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: BlackLightTextStyles.captionBold(
              color: isActive ? color : variant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onTap;

  const _MobileLeadCard({required this.lead, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    final stageC = lead.stage.stageColorIn(context);
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
                  child: Text(lead.name,
                      style: BlackLightTextStyles.mobileH3(color: c.onSurface),
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: stageC, width: 1),
                  ),
                  child: Text(lead.stage.label,
                      style: BlackLightTextStyles.captionBold(color: stageC)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: variant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(lead.address,
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
                if (lead.systemSizeKw != null)
                  _MiniInfo(
                      icon: Icons.bolt_outlined,
                      label: '${lead.systemSizeKw} kW'),
                const SizedBox(width: 12),
                _MiniInfo(icon: Icons.person_outlined, label: lead.source),
                const Spacer(),
                Text(_fmtDate(lead.addedAt),
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

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: variant),
        const SizedBox(width: 4),
        Text(label,
            style: BlackLightTextStyles.mobileBody(color: variant)
                .copyWith(fontSize: 12)),
      ],
    );
  }
}
