import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'package:blacklight_app/core/models/project.dart';
import 'package:blacklight_app/core/illustrations/geometric_illustrations.dart';
import 'package:blacklight_app/core/widgets/status_badge.dart';

class MobileProjectDetail extends StatelessWidget {
  final Project project;
  final VoidCallback? onOpenChat;
  final VoidCallback? onBack;

  const MobileProjectDetail({
    super.key,
    required this.project,
    this.onOpenChat,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: onBack ?? () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: BlackLightColors.textBody),
        ),
        title: Text(project.clientName,
            style: BlackLightTextStyles.mobileH2(),
            overflow: TextOverflow.ellipsis),
        backgroundColor: BlackLightColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
            bottom: BorderSide(color: BlackLightColors.border, width: 1)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: BlackLightSpacing.sm),
            child: GestureDetector(
              onTap: onOpenChat,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BlackLightColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(OrgMobileProjectDetailContent.chatTab,
                    style: BlackLightTextStyles.mobileLabelBold(
                            color: Colors.white)
                        .copyWith(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BlackLightSpacing.sm),
        child: Column(
          children: [
            // Status + address header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(BlackLightSpacing.sm),
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                borderRadius: BorderRadius.circular(BlackLightRadius.card),
                border: Border.all(color: BlackLightColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(status: project.status),
                      const SizedBox(width: 8),
                      Text(project.type.label,
                          style: BlackLightTextStyles.mobileBody(
                                  color: BlackLightColors.textCaption)
                              .copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(project.address, style: BlackLightTextStyles.mobileH3()),
                  const SizedBox(height: 4),
                  Text(project.clientName,
                      style: BlackLightTextStyles.mobileBody()),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.sm),

            // Roof preview
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: BlackLightColors.surface,
                borderRadius: BorderRadius.circular(BlackLightRadius.card),
                border: Border.all(color: BlackLightColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BlackLightRadius.card),
                child: ActiveRoofDesign(height: 200, width: double.infinity),
              ),
            ),
            const SizedBox(height: BlackLightSpacing.sm),

            // Specs
            _MobileCard(
              title: OrgMobileProjectDetailContent.systemSpecsCardTitle,
              child: Column(
                children: [
                  _SpecRow(
                      label: OrgMobileProjectDetailContent.labelSystemSize,
                      value: project.systemSizeKw != null
                          ? '${project.systemSizeKw!.toStringAsFixed(1)}${OrgCrmBoardContent.kwSuffix}'
                          : CommonContent.emDash),
                  const Divider(height: BlackLightSpacing.md),
                  _SpecRow(
                      label: OrgMobileProjectDetailContent.labelPanelCount,
                      value: project.panelCount?.toString() ?? CommonContent.emDash),
                  const Divider(height: BlackLightSpacing.md),
                  _SpecRow(
                      label: OrgMobileProjectDetailContent.labelAnnualOutput,
                      value: project.annualProductionKwh != null
                          ? '${(project.annualProductionKwh! / 1000).toStringAsFixed(1)} MWh'
                          : CommonContent.emDash),
                  const Divider(height: BlackLightSpacing.md),
                  _SpecRow(
                      label: OrgMobileProjectDetailContent.labelYearOneSavings,
                      value: project.yearOneSavings != null
                          ? '\$${project.yearOneSavings!.toStringAsFixed(0)}'
                          : CommonContent.emDash,
                      valueColor: BlackLightColors.green),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.sm),

            // Client
            _MobileCard(
              title: OrgMobileProjectDetailContent.clientCardTitle,
              child: Column(
                children: [
                  _ClientRow(
                      icon: Icons.person_outline, value: project.clientName),
                  if (project.clientEmail != null) ...[
                    const Divider(height: BlackLightSpacing.sm),
                    _ClientRow(
                        icon: Icons.mail_outline, value: project.clientEmail!),
                  ],
                  if (project.clientPhone != null) ...[
                    const Divider(height: BlackLightSpacing.sm),
                    _ClientRow(
                        icon: Icons.phone_outlined,
                        value: project.clientPhone!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.lg),

            // Open in chat CTA
            SizedBox(
              width: double.infinity,
              height: BlackLightSpacing.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: onOpenChat,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(OrgMobileProjectDetailContent.openInAiChat,
                    style: BlackLightTextStyles.mobileButton()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlackLightColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: BlackLightSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _MobileCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BlackLightTextStyles.mobileH3()),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SpecRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: BlackLightTextStyles.mobileBody()),
        Text(value,
            style: BlackLightTextStyles.data(
                color: valueColor ?? BlackLightColors.textPrimary)),
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ClientRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: BlackLightColors.textCaption),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: BlackLightTextStyles.mobileBody(
                  color: BlackLightColors.textPrimary),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
