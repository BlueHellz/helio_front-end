import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/widgets/status_badge.dart';

class HomeownerDesignSummary extends StatelessWidget {
  final Project? project;
  final VoidCallback? onRequestQuote;
  final VoidCallback? onDownload;

  const HomeownerDesignSummary({
    super.key,
    this.project,
    this.onRequestQuote,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryHeader(
              project: project,
              onRequestQuote: onRequestQuote,
              onDownload: onDownload,
            ),
            const SizedBox(height: BlackLightSpacing.lg),
            _DesignCanvas(),
            const SizedBox(height: BlackLightSpacing.lg),
            _SystemSpecsCard(project: project),
            const SizedBox(height: BlackLightSpacing.md),
            _FinancialCard(project: project),
            const SizedBox(height: BlackLightSpacing.md),
            _EquipmentCard(),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final Project? project;
  final VoidCallback? onRequestQuote;
  final VoidCallback? onDownload;

  const _SummaryHeader({this.project, this.onRequestQuote, this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(HomeownerDesignSummaryContent.title,
                  style: BlackLightTextStyles.sectionHeading()),
              if (project != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: BlackLightColors.textCaption),
                    const SizedBox(width: 4),
                    Text(project!.address,
                        style: BlackLightTextStyles.body(
                            color: BlackLightColors.textBody)),
                    const SizedBox(width: 12),
                    StatusBadge(status: project!.status),
                  ],
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            if (onDownload != null)
              _ActionBtn(
                label: HomeownerDesignSummaryContent.downloadPdf,
                icon: Icons.download_outlined,
                onTap: onDownload,
              ),
            const SizedBox(width: 12),
            SizedBox(
              height: BlackLightSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onRequestQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlackLightColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Text(HomeownerDesignSummaryContent.requestQuotes,
                    style: BlackLightTextStyles.bodyBold(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionBtn({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BlackLightSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: BlackLightColors.textPrimary,
          side: const BorderSide(color: BlackLightColors.border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }
}

class _DesignCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 340,
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Stack(
        children: [
          Center(child: ActiveRoofDesign(height: 320, width: double.infinity)),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: BlackLightColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.architecture,
                      size: 12, color: BlackLightColors.textCaption),
                  const SizedBox(width: 4),
                  Text(HomeownerDesignSummaryContent.rooftopView,
                      style: BlackLightTextStyles.caption()
                          .copyWith(fontSize: 11)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Wrap(
              spacing: 8,
              children: [
                _LegendChip(color: BlackLightColors.green, label: HomeownerDesignSummaryContent.legendActive),
                _LegendChip(
                    color: BlackLightColors.accent, label: HomeownerDesignSummaryContent.legendPartial),
                _LegendChip(color: BlackLightColors.border, label: HomeownerDesignSummaryContent.legendUnused),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: BlackLightTextStyles.caption().copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _SystemSpecsCard extends StatelessWidget {
  final Project? project;

  const _SystemSpecsCard({this.project});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: HomeownerDesignSummaryContent.systemSpecificationsTitle,
      child: LayoutBuilder(builder: (context, constraints) {
        final colCount = constraints.maxWidth > 600 ? 4 : 2;
        final specs = [
          (
            HomeownerDesignSummaryContent.specSystemSize,
            project?.systemSizeKw != null
                ? '${project!.systemSizeKw!.toStringAsFixed(1)} kW'
                : CommonContent.emDash
          ),
          (HomeownerDesignSummaryContent.specPanelCount, project?.panelCount?.toString() ?? CommonContent.emDash),
          (
            HomeownerDesignSummaryContent.specAnnualProduction,
            project?.annualProductionKwh != null
                ? '${(project!.annualProductionKwh! / 1000).toStringAsFixed(1)} MWh'
                : CommonContent.emDash
          ),
          (HomeownerDesignSummaryContent.specSystemType, project?.type.label ?? CommonContent.emDash),
        ];
        return Wrap(
          spacing: BlackLightSpacing.md,
          runSpacing: BlackLightSpacing.md,
          children: specs
              .map((s) => SizedBox(
                    width: (constraints.maxWidth -
                            BlackLightSpacing.md * (colCount - 1)) /
                        colCount,
                    child: _SpecItem(label: s.$1, value: s.$2),
                  ))
              .toList(),
        );
      }),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final Project? project;

  const _FinancialCard({this.project});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: HomeownerDesignSummaryContent.financialOverviewTitle,
      child: LayoutBuilder(builder: (context, _) {
        final items = [
          (
            HomeownerDesignSummaryContent.finYearOneSavings,
            project?.yearOneSavings != null
                ? '\$${project!.yearOneSavings!.toStringAsFixed(0)}'
                : CommonContent.emDash,
            BlackLightColors.green
          ),
          (
            HomeownerDesignSummaryContent.fin25YearSavings,
            project?.yearOneSavings != null
                ? '\$${(project!.yearOneSavings! * 25 * 1.02).toStringAsFixed(0)}'
                : CommonContent.emDash,
            BlackLightColors.green
          ),
          (
            HomeownerDesignSummaryContent.finEstPayback,
            HomeownerDesignSummaryContent.finEstPaybackExample,
            BlackLightColors.textPrimary,
          ),
        ];
        return Row(
          children: items
              .expand((item) => [
                    Expanded(
                      child: _SpecItem(
                        label: item.$1,
                        value: item.$2,
                        valueColor: item.$3,
                      ),
                    ),
                    if (item != items.last)
                      Container(
                        width: 1,
                        height: 48,
                        color: BlackLightColors.border,
                        margin: const EdgeInsets.symmetric(
                            horizontal: BlackLightSpacing.md),
                      ),
                  ])
              .toList(),
        );
      }),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: HomeownerDesignSummaryContent.equipmentTitle,
      child: Column(
        children: [
          _EquipmentRow(
            icon: Icons.solar_power_outlined,
            category: HomeownerDesignSummaryContent.equipPanelsCategory,
            detail: HomeownerDesignSummaryContent.equipPanelsDetail,
          ),
          const Divider(height: BlackLightSpacing.md),
          _EquipmentRow(
            icon: Icons.electrical_services_outlined,
            category: HomeownerDesignSummaryContent.equipInverterCategory,
            detail: HomeownerDesignSummaryContent.equipInverterDetail,
          ),
          const Divider(height: BlackLightSpacing.md),
          _EquipmentRow(
            icon: Icons.monitor_outlined,
            category: HomeownerDesignSummaryContent.equipMonitoringCategory,
            detail: HomeownerDesignSummaryContent.equipMonitoringDetail,
          ),
        ],
      ),
    );
  }
}

class _EquipmentRow extends StatelessWidget {
  final IconData icon;
  final String category;
  final String detail;

  const _EquipmentRow({
    required this.icon,
    required this.category,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            borderRadius: BorderRadius.circular(BlackLightRadius.sm),
            border: Border.all(color: BlackLightColors.border),
          ),
          child: Icon(icon, size: 18, color: BlackLightColors.textBody),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category,
                  style: BlackLightTextStyles.body(
                          color: BlackLightColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(detail, style: BlackLightTextStyles.caption()),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BlackLightTextStyles.cardHeading()),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SpecItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: BlackLightTextStyles.captionBold().copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            style: BlackLightTextStyles.dataLarge(
                    color: valueColor ?? BlackLightColors.textPrimary)
                .copyWith(fontSize: 18)),
      ],
    );
  }
}
