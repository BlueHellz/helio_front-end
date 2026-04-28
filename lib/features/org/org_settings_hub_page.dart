import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_mode_wrapper.dart';
import '../../core/providers/org_providers.dart';
import '../../theme/blacklight_theme.dart';
import 'settings/field_library_page.dart';
import 'settings/intake_builder_page.dart';
import 'settings/pipeline_builder_page.dart';
import 'settings/role_management_page.dart';

class OrgSettingsHubPage extends ConsumerWidget {
  const OrgSettingsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(designModeProvider);
    final enabled = mode.valueOrNull ?? false;

    Future<void> toggleDesign(bool v) async {
      await ref.read(designModeProvider.notifier).setEnabled(v);
      await ref.read(designModeProvider.notifier).refresh();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: DesignModeWrapper(
            sectionId: 'org_settings_hub',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(OrgOrgSettingsHubContent.pageTitle, style: BlackLightTextStyles.sectionHeading()),
                const SizedBox(height: BlackLightSpacing.md),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    OrgOrgSettingsHubContent.designModeTitle,
                    style: BlackLightTextStyles.bodyBold(),
                  ),
                  subtitle: Text(
                    enabled
                        ? OrgOrgSettingsHubContent.designModeOnSubtitle
                        : OrgOrgSettingsHubContent.designModeOffSubtitle,
                    style: BlackLightTextStyles.caption(),
                  ),
                  value: enabled,
                  onChanged: (v) => toggleDesign(v),
                ),
                const SizedBox(height: BlackLightSpacing.lg),
                _tile(context, OrgOrgSettingsHubContent.tileFieldLibrary, Icons.list_alt_outlined, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FieldLibraryPage(),
                    ),
                  );
                }),
                _tile(context, OrgOrgSettingsHubContent.tileRoleManagement, Icons.manage_accounts_outlined,
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RoleManagementPage(),
                    ),
                  );
                }),
                _tile(context, OrgOrgSettingsHubContent.tilePipelineBuilder, Icons.account_tree_outlined,
                    () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PipelineBuilderPage(),
                    ),
                  );
                }),
                _tile(context, OrgOrgSettingsHubContent.tileIntakeBuilder, Icons.view_quilt_outlined, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IntakeBuilderPage(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: BlackLightColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          side: const BorderSide(color: BlackLightColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(BlackLightRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, size: 24, color: BlackLightColors.textBody),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: BlackLightTextStyles.cardHeading()),
                ),
                const Icon(Icons.chevron_right,
                    color: BlackLightColors.textCaption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
