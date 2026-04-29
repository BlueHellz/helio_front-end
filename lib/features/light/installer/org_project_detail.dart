import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/widgets/status_badge.dart';

class OrgProjectDetail extends StatelessWidget {
  final Project project;
  final VoidCallback? onBack;
  final VoidCallback? onOpenChat;

  const OrgProjectDetail({
    super.key,
    required this.project,
    this.onBack,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailHeader(
              project: project, onBack: onBack, onOpenChat: onOpenChat),
          const SizedBox(height: BlackLightSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _RoofCanvas(),
                    const SizedBox(height: BlackLightSpacing.md),
                    _SystemSpecsCard(project: project),
                  ],
                ),
              ),
              const SizedBox(width: BlackLightSpacing.md),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _ClientCard(project: project),
                    const SizedBox(height: BlackLightSpacing.md),
                    _TimelineCard(project: project),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Project project;
  final VoidCallback? onBack;
  final VoidCallback? onOpenChat;

  const _DetailHeader({
    required this.project,
    this.onBack,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        if (onBack != null)
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: variant),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.address,
                  style: BlackLightTextStyles.sectionHeading(
                      color: c.onSurface)),
              Row(
                children: [
                  Text(project.clientName,
                      style: BlackLightTextStyles.body(color: variant)),
                  const SizedBox(width: 12),
                  StatusBadge(status: project.status),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: BlackLightSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: Text(OrgProjectDetailContent.openInChat,
                style: BlackLightTextStyles.bodyBold(color: c.onPrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: c.onPrimary,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoofCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: c.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        child: ActiveRoofDesign(height: 280, width: double.infinity),
      ),
    );
  }
}

class _SystemSpecsCard extends StatelessWidget {
  final Project project;

  const _SystemSpecsCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    final specs = [
      (
        OrgProjectDetailContent.specLabelSystemSize,
        project.systemSizeKw != null
            ? '${project.systemSizeKw!.toStringAsFixed(1)}${OrgCrmBoardContent.kwSuffix}'
            : CommonContent.emDash
      ),
      (OrgProjectDetailContent.specLabelPanels,
          project.panelCount?.toString() ?? CommonContent.emDash),
      (
        OrgProjectDetailContent.specAnnualOutput,
        project.annualProductionKwh != null
            ? '${(project.annualProductionKwh! / 1000).toStringAsFixed(1)} MWh'
            : CommonContent.emDash
      ),
      (
        OrgProjectDetailContent.specLabelYearOneSavings,
        project.yearOneSavings != null
            ? '\$${project.yearOneSavings!.toStringAsFixed(0)}'
            : CommonContent.emDash
      ),
      (OrgProjectDetailContent.specLabelSystemType, project.type.label),
    ];

    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(OrgProjectDetailContent.systemSpecificationsHeading,
              style: BlackLightTextStyles.cardHeading(color: c.onSurface)),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          ...specs.expand((s) => [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.$1,
                        style: BlackLightTextStyles.body(color: variant)),
                    Text(s.$2,
                        style:
                            BlackLightTextStyles.data(color: c.onSurface)),
                  ],
                ),
                if (s != specs.last)
                  const Divider(height: BlackLightSpacing.md),
              ]),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Project project;

  const _ClientCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(OrgProjectDetailContent.clientHeading,
              style: BlackLightTextStyles.cardHeading(color: c.onSurface)),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          _ClientRow(icon: Icons.person_outline, value: project.clientName),
          if (project.clientEmail != null) ...[
            const SizedBox(height: 8),
            _ClientRow(icon: Icons.mail_outline, value: project.clientEmail!),
          ],
          if (project.clientPhone != null) ...[
            const SizedBox(height: 8),
            _ClientRow(icon: Icons.phone_outlined, value: project.clientPhone!),
          ],
          const SizedBox(height: 8),
          _ClientRow(icon: Icons.location_on_outlined, value: project.address),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ClientRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: variant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style:
                  BlackLightTextStyles.body(color: c.onSurface)
                      .copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Project project;

  const _TimelineCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    final allStatuses = [
      ProjectStatus.designing,
      ProjectStatus.quoted,
      ProjectStatus.contracted,
      ProjectStatus.permitted,
      ProjectStatus.installed,
      ProjectStatus.completed,
    ];
    final currentIdx = allStatuses.indexOf(project.status);

    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(OrgProjectDetailContent.progressHeading,
              style: BlackLightTextStyles.cardHeading(color: c.onSurface)),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          ...allStatuses.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final isDone = i <= currentIdx;
            final isActive = i == currentIdx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isDone ? c.primary : c.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone ? c.primary : c.outline,
                          ),
                        ),
                        child: isDone
                            ? Icon(Icons.check,
                                size: 12, color: c.onPrimary)
                            : null,
                      ),
                      if (i < allStatuses.length - 1)
                        Container(
                          width: 1,
                          height: 12,
                          color: isDone ? c.primary : c.outline,
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s.label,
                    style: BlackLightTextStyles.body(
                      color: isActive
                          ? c.onSurface
                          : isDone
                              ? variant
                              : variant.withOpacity(0.7),
                    ).copyWith(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
