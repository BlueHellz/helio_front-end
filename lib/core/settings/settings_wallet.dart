import 'package:flutter/material.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

import '../../theme/blacklight_theme.dart';

class SettingsWallet extends StatefulWidget {
  final String userName;
  final String? userEmail;
  final String companyName;
  final double hlioBalance;
  final String? walletAddress;
  final VoidCallback? onConnectWallet;
  final VoidCallback? onSignOut;
  final VoidCallback? onEditUserName;
  final VoidCallback? onEditEmail;
  final VoidCallback? onEditCompany;

  const SettingsWallet({
    super.key,
    required this.userName,
    this.userEmail,
    this.companyName = '',
    this.hlioBalance = 0.0,
    this.walletAddress,
    this.onConnectWallet,
    this.onSignOut,
    this.onEditUserName,
    this.onEditEmail,
    this.onEditCompany,
  });

  @override
  State<SettingsWallet> createState() => _SettingsWalletState();
}

class _SettingsWalletState extends State<SettingsWallet> {
  bool _notificationsEmail = true;
  bool _notificationsBrowser = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BlackLightSpacing.gutter),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(OrgSettingsAccountContent.pageTitle,
                style: BlackLightTextStyles.sectionHeading(
                    color: c.onSurface)),
            const SizedBox(height: 4),
            Text(OrgSettingsAccountContent.pageSubtitle,
                style: BlackLightTextStyles.body(color: variant)),
            const SizedBox(height: BlackLightSpacing.lg),

            // Profile card
            _SettingsCard(
              title: OrgSettingsAccountContent.sectionProfile,
              child: Column(
                children: [
                  _SettingsRow(
                    label: OrgSettingsAccountContent.labelFullName,
                    value:
                        widget.userName.isEmpty
                            ? CommonContent.notSet
                            : widget.userName,
                    onEdit: widget.onEditUserName,
                  ),
                  const Divider(height: BlackLightSpacing.md),
                  _SettingsRow(
                    label: OrgSettingsAccountContent.labelEmailAddress,
                    value: widget.userEmail ?? CommonContent.notSet,
                    onEdit: widget.onEditEmail,
                  ),
                  if (widget.companyName.isNotEmpty || widget.onEditCompany != null) ...[
                    const Divider(height: BlackLightSpacing.md),
                    _SettingsRow(
                      label: OrgSettingsAccountContent.labelCompany,
                      value: widget.companyName.isEmpty
                          ? CommonContent.notSet
                          : widget.companyName,
                      onEdit: widget.onEditCompany,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.md),

            // Wallet card
            _SettingsCard(
              title: OrgSettingsAccountContent.sectionWallet,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.outline),
                        ),
                        child: Icon(Icons.account_balance_wallet_outlined,
                            size: 22, color: variant),
                      ),
                      const SizedBox(width: BlackLightSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(WalletContent.hlioBalanceLabel,
                              style: BlackLightTextStyles.caption(
                                  color: variant)),
                          Row(
                            children: [
                              Text(widget.hlioBalance.toStringAsFixed(2),
                                  style: BlackLightTextStyles.dataLarge(
                                      color: c.onSurface)),
                              const SizedBox(width: 6),
                              Text(WalletContent.hlioTicker,
                                  style: BlackLightTextStyles.body(
                                      color: variant)),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (widget.walletAddress == null)
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: widget.onConnectWallet,
                            icon: const Icon(Icons.link, size: 16),
                            label: Text(WalletContent.connectWallet,
                                style: BlackLightTextStyles.caption()
                                    .copyWith(
                                        color: c.onPrimary,
                                        fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.primary,
                              foregroundColor: c.onPrimary,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        )
                      else
                        _AddressChip(address: widget.walletAddress!),
                    ],
                  ),
                  if (widget.walletAddress != null) ...[
                    const Divider(height: BlackLightSpacing.md),
                    _TxPlaceholder(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.md),

            // Notifications card
            _SettingsCard(
              title: OrgSettingsAccountContent.sectionNotifications,
              child: Column(
                children: [
                  _SwitchRow(
                    label: OrgSettingsAccountContent.notifyEmailTitle,
                    description: OrgSettingsAccountContent.notifyEmailBody,
                    value: _notificationsEmail,
                    onChanged: (v) => setState(() => _notificationsEmail = v),
                  ),
                  const Divider(height: BlackLightSpacing.md),
                  _SwitchRow(
                    label: OrgSettingsAccountContent.notifyBrowserTitle,
                    description: OrgSettingsAccountContent.notifyBrowserBody,
                    value: _notificationsBrowser,
                    onChanged: (v) => setState(() => _notificationsBrowser = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.md),

            // Danger zone
            _SettingsCard(
              title: OrgSettingsAccountContent.sectionAccount,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(OrgSettingsAccountContent.signOutDescription,
                        style: BlackLightTextStyles.body(color: variant)),
                  ),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: widget.onSignOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.error,
                        side: BorderSide(color: c.error),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(OrgSettingsAccountContent.signOutButton,
                          style: BlackLightTextStyles.body(color: c.error)
                              .copyWith(fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: BlackLightTextStyles.cardHeading(color: c.onSurface)),
          const SizedBox(height: BlackLightSpacing.sm),
          const Divider(),
          const SizedBox(height: BlackLightSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _SettingsRow({
    required this.label,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: BlackLightTextStyles.captionBold(color: variant)
                      .copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Text(value,
                  style: BlackLightTextStyles.body(color: c.onSurface)
                      .copyWith(fontSize: 14)),
            ],
          ),
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Text(OrgSettingsAccountContent.editLink,
                style:
                    BlackLightTextStyles.caption(color: c.primary)
                        .copyWith(fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: BlackLightTextStyles.body(color: c.onSurface)
                      .copyWith(fontSize: 14)),
              Text(description,
                  style: BlackLightTextStyles.caption(color: variant)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: c.primary,
          activeTrackColor: c.primary,
        ),
      ],
    );
  }
}

class _AddressChip extends StatelessWidget {
  final String address;

  const _AddressChip({required this.address});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final short = address.length > 12
        ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
        : address;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: c.secondary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(short,
              style: BlackLightTextStyles.data(color: c.secondary)),
        ],
      ),
    );
  }
}

class _TxPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(OrgSettingsAccountContent.transactionsHeading,
            style: BlackLightTextStyles.captionBold(color: variant)
                .copyWith(fontSize: 10)),
        const SizedBox(height: BlackLightSpacing.sm),
        Container(
          padding: const EdgeInsets.all(BlackLightSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceMuted,
            borderRadius: BorderRadius.circular(BlackLightRadius.md),
            border: Border.all(color: c.outline),
          ),
          child: Center(
            child: Text(
              OrgSettingsAccountContent.transactionsPlaceholder,
              style: BlackLightTextStyles.caption(color: variant),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
