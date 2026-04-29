import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:blacklight_app/core/app_state.dart';
import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

class MobileSettings extends StatefulWidget {
  final String userName;
  final String? userEmail;
  final String companyName;
  final double hlioBalance;
  final String? walletAddress;
  final VoidCallback? onConnectWallet;
  final VoidCallback? onSignOut;

  const MobileSettings({
    super.key,
    required this.userName,
    this.userEmail,
    this.companyName = '',
    this.hlioBalance = 0.0,
    this.walletAddress,
    this.onConnectWallet,
    this.onSignOut,
  });

  @override
  State<MobileSettings> createState() => _MobileSettingsState();
}

class _MobileSettingsState extends State<MobileSettings> {
  bool _notificationsEmail = true;
  bool _notificationsPush = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(OrgSettingsAccountContent.pageTitle,
              style: BlackLightTextStyles.mobileH2(color: c.onSurface)),
          backgroundColor: c.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          pinned: true,
          shape: Border(
              bottom: BorderSide(color: c.outline, width: 1)),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(BlackLightSpacing.sm),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SettingsGroup(
                title: OrgSettingsAccountContent.sectionProfile,
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: OrgSettingsAccountContent.labelFullName,
                    subtitle:
                        widget.userName.isEmpty ? CommonContent.notSet : widget.userName,
                    onTap: () async {
                      final state = context.read<BlackLightAppState>();
                      final v = await AppFeedback.showEditStringDialog(
                        context,
                        title: RouterStrings.editFullNameTitle,
                        initial: state.userName,
                      );
                      if (v != null && v.isNotEmpty) {
                        state.updateLocalProfile(userName: v);
                      }
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.mail_outline,
                    title: OrgSettingsAccountContent.labelEmailAddress,
                    subtitle: widget.userEmail ?? CommonContent.notSet,
                    onTap: () => AppFeedback.comingSoon(
                          context,
                          feature: FeedbackStrings.featureEmailChanges,
                        ),
                  ),
                  if (widget.companyName.isNotEmpty ||
                      context.watch<BlackLightAppState>().role ==
                          UserRole.organization)
                    _SettingsTile(
                      icon: Icons.domain_outlined,
                      title: OrgSettingsAccountContent.labelCompany,
                      subtitle: widget.companyName.isEmpty
                          ? CommonContent.notSet
                          : widget.companyName,
                      onTap: () async {
                        final state = context.read<BlackLightAppState>();
                        final v = await AppFeedback.showEditStringDialog(
                          context,
                          title: RouterStrings.editCompanyNameTitle,
                          initial: state.companyName,
                        );
                        if (v != null) {
                          state.updateLocalProfile(companyName: v);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.sm),
              _SettingsGroup(
                title: OrgSettingsAccountContent.sectionWallet,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(BlackLightSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.surfaceMuted,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.outline),
                          ),
                          child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20,
                              color: variant),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(WalletContent.hlioBalanceLabel,
                                style: BlackLightTextStyles.mobileBody(
                                        color: variant)
                                    .copyWith(fontSize: 12)),
                            Row(
                              children: [
                                Text(
                                  widget.hlioBalance.toStringAsFixed(2),
                                  style: BlackLightTextStyles.data(
                                      color: c.onSurface),
                                ),
                                const SizedBox(width: 4),
                                Text(WalletContent.hlioTicker,
                                    style: BlackLightTextStyles.mobileBody(
                                        color: variant)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (widget.walletAddress == null)
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: widget.onConnectWallet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c.primary,
                                foregroundColor: c.onPrimary,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              child: Text(WalletContent.connectShort,
                                  style: BlackLightTextStyles.mobileLabelBold(
                                          color: c.onPrimary)
                                      .copyWith(fontSize: 12)),
                            ),
                          )
                        else
                          _ConnectedChip(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.sm),
              _SettingsGroup(
                title: OrgSettingsAccountContent.sectionNotifications,
                children: [
                  _SwitchTile(
                    icon: Icons.mail_outline,
                    title: OrgSettingsAccountContent.notifyEmailTitle,
                    value: _notificationsEmail,
                    onChanged: (v) => setState(() => _notificationsEmail = v),
                  ),
                  _SwitchTile(
                    icon: Icons.notifications_outlined,
                    title: OrgSettingsAccountContent.notifyPushTitle,
                    value: _notificationsPush,
                    onChanged: (v) => setState(() => _notificationsPush = v),
                  ),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.sm),
              _SettingsGroup(
                title: OrgSettingsAccountContent.sectionAccount,
                children: [
                  _SettingsTile(
                    icon: Icons.logout_outlined,
                    title: OrgSettingsAccountContent.signOutButton,
                    subtitle: OrgSettingsAccountContent.signOutTileSubtitle,
                    onTap: widget.onSignOut,
                    titleColor: c.error,
                    iconColor: c.error,
                    showChevron: false,
                  ),
                ],
              ),
              const SizedBox(height: BlackLightSpacing.xl),
              Center(
                child: Text(
                  OrgSettingsAccountContent.mobileLegalFooter,
                  style: BlackLightTextStyles.mobileBody(color: variant)
                      .copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: BlackLightSpacing.lg),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: BlackLightSpacing.xs, bottom: BlackLightSpacing.xs),
          child: Text(title.toUpperCase(),
              style: BlackLightTextStyles.mobileLabelBold(color: variant)
                  .copyWith(fontSize: 11)),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(BlackLightRadius.card),
            border: Border.all(color: c.outline),
          ),
          child: Column(
            children: children
                .expand((w) =>
                    [w, if (w != children.last) const Divider(height: 0)])
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BlackLightRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BlackLightSpacing.sm, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? variant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: BlackLightTextStyles.mobileBody(
                          color: titleColor ?? c.onSurface)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: BlackLightTextStyles.mobileBody(color: variant)
                            .copyWith(fontSize: 12)),
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: variant),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: BlackLightSpacing.sm, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: variant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: BlackLightTextStyles.mobileBody(color: c.onSurface)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: c.primary,
            activeTrackColor: c.primary,
          ),
        ],
      ),
    );
  }
}

class _ConnectedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: c.secondary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(OrgMobileInstallerContent.hlioConnectedLine,
              style: BlackLightTextStyles.mobileLabelBold(color: c.secondary)
                  .copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
