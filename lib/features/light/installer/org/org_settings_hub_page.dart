import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blacklight_app/core/design_mode_wrapper.dart';
import 'package:blacklight_app/core/providers/org_providers.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'settings/field_library_page.dart';
import 'settings/intake_builder_page.dart';
import 'settings/pipeline_builder_page.dart';
import 'settings/role_management_page.dart';

class OrgSettingsHubPage extends ConsumerWidget {
  const OrgSettingsHubPage({super.key});

  static const double _maxContentWidth = 720;
  static const double _twoColBreakpoint = 560;
  static const double _wrapSpacing = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(designModeProvider);
    final enabled = mode.valueOrNull ?? false;

    Future<void> toggleDesign(bool v) async {
      await ref.read(designModeProvider.notifier).setEnabled(v);
      await ref.read(designModeProvider.notifier).refresh();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW =
            _maxContentWidth < constraints.maxWidth
                ? _maxContentWidth
                : constraints.maxWidth;
        final useTwoCol = maxW >= _twoColBreakpoint;
        final cardWidth =
            useTwoCol ? (maxW - _wrapSpacing) / 2 : maxW;

        final cards = <({
          String title,
          String subtitle,
          VoidCallback onTap,
        })>[
          (
            title: OrgOrgSettingsHubContent.cardCustomFieldsTitle,
            subtitle: OrgOrgSettingsHubContent.cardCustomFieldsSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FieldLibraryPage(),
              ),
            ),
          ),
          (
            title: OrgOrgSettingsHubContent.cardPipelineTitle,
            subtitle: OrgOrgSettingsHubContent.cardPipelineSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PipelineBuilderPage(),
              ),
            ),
          ),
          (
            title: OrgOrgSettingsHubContent.cardRolesTitle,
            subtitle: OrgOrgSettingsHubContent.cardRolesSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RoleManagementPage(),
              ),
            ),
          ),
          (
            title: OrgOrgSettingsHubContent.cardIntakeTitle,
            subtitle: OrgOrgSettingsHubContent.cardIntakeSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const IntakeBuilderPage(),
              ),
            ),
          ),
          (
            title: OrgOrgSettingsHubContent.cardAiPrefsTitle,
            subtitle: OrgOrgSettingsHubContent.cardAiPrefsSubtitle,
            onTap: () => AppFeedback.comingSoon(
                  context,
                  feature: OrgOrgSettingsHubContent.cardAiPrefsTitle,
                ),
          ),
          (
            title: OrgOrgSettingsHubContent.cardApiKeysTitle,
            subtitle: OrgOrgSettingsHubContent.cardApiKeysSubtitle,
            onTap: () => AppFeedback.comingSoon(
                  context,
                  feature: OrgOrgSettingsHubContent.cardApiKeysTitle,
                ),
          ),
          (
            title: OrgOrgSettingsHubContent.cardPhoneTitle,
            subtitle: OrgOrgSettingsHubContent.cardPhoneSubtitle,
            onTap: () => AppFeedback.comingSoon(
                  context,
                  feature: OrgOrgSettingsHubContent.cardPhoneTitle,
                ),
          ),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: DesignModeWrapper(
                sectionId: 'org_settings_hub',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      OrgOrgSettingsHubContent.pageTitle,
                      style:
                          BlackLightTextStyles.sectionHeading(
                              color: context.colors.onSurface),
                    ),
                    const SizedBox(height: BlackLightSpacing.md),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        OrgOrgSettingsHubContent.designModeTitle,
                        style: BlackLightTextStyles.bodyBold(
                            color: context.colors.onSurface),
                      ),
                      subtitle: Text(
                        enabled
                            ? OrgOrgSettingsHubContent.designModeOnSubtitle
                            : OrgOrgSettingsHubContent.designModeOffSubtitle,
                        style: BlackLightTextStyles.caption(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                      value: enabled,
                      onChanged: (v) => toggleDesign(v),
                    ),
                    const SizedBox(height: BlackLightSpacing.lg),
                    Wrap(
                      spacing: _wrapSpacing,
                      runSpacing: _wrapSpacing,
                      children: [
                        for (final c in cards)
                          SizedBox(
                            width: cardWidth,
                            child: _SettingsHubCard(
                              title: c.title,
                              subtitle: c.subtitle,
                              onTap: c.onTap,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Theme-aware card for settings hub tiles.
class _SettingsHubCard extends StatelessWidget {
  const _SettingsHubCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Material(
      color: c.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        side: BorderSide(color: c.outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BlackLightSpacing.sm + 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BlackLightTextStyles.bodyBold(
                        color: c.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: BlackLightTextStyles.body(
                        color: variant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right,
                  color: variant,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
