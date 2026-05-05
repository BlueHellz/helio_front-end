import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';

/// Account + HLIO wallet (homeowner), replacing org settings hub.
class HomeownerWalletPage extends StatelessWidget {
  const HomeownerWalletPage({
    super.key,
    required this.userName,
    this.hlioBalance = 0.0,
    this.walletAddress,
    this.onConnectWallet,
    this.onSignOut,
    this.onEditUserName,
    this.onEditEmail,
  });

  final String userName;
  final double hlioBalance;
  final String? walletAddress;
  final VoidCallback? onConnectWallet;
  final VoidCallback? onSignOut;
  final VoidCallback? onEditUserName;
  final VoidCallback? onEditEmail;

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
            Text(HomeownerSettingsContent.pageTitle,
                style: BlackLightTextStyles.sectionHeading(color: c.onSurface)),
            const SizedBox(height: 4),
            Text(HomeownerSettingsContent.pageSubtitle,
                style: BlackLightTextStyles.body(color: variant)),
            const SizedBox(height: BlackLightSpacing.lg),
            _Card(
              title: HomeownerSettingsContent.sectionProfile,
              child: Column(
                children: [
                  _Row(
                    label: HomeownerSettingsContent.labelFullName,
                    value: userName.isEmpty ? CommonContent.notSet : userName,
                    onEdit: onEditUserName,
                  ),
                  const Divider(height: BlackLightSpacing.md),
                  _Row(
                    label: HomeownerSettingsContent.labelEmail,
                    value: CommonContent.notSet,
                    onEdit: onEditEmail,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            _Card(
              title: HomeownerSettingsContent.sectionWallet,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(WalletContent.hlioBalanceLabel,
                          style: BlackLightTextStyles.caption(color: variant)),
                      const SizedBox(width: 8),
                      Text(
                        hlioBalance.toStringAsFixed(2),
                        style: BlackLightTextStyles.dataLarge(color: c.onSurface),
                      ),
                      const SizedBox(width: 6),
                      Text(WalletContent.hlioTicker,
                          style: BlackLightTextStyles.body(color: variant)),
                    ],
                  ),
                  const SizedBox(height: BlackLightSpacing.md),
                  if (walletAddress == null)
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: onConnectWallet,
                        icon: const Icon(Icons.link, size: 16),
                        label: Text(WalletContent.connectWallet,
                            style: BlackLightTextStyles.caption().copyWith(
                                  color: c.onPrimary,
                                  fontWeight: FontWeight.w600,
                                )),
                      ),
                    )
                  else
                    Text(
                      walletAddress!,
                      style: BlackLightTextStyles.data(color: c.secondary),
                    ),
                ],
              ),
            ),
            const SizedBox(height: BlackLightSpacing.md),
            _Card(
              title: HomeownerSettingsContent.sectionSession,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(HomeownerSettingsContent.signOutHelp,
                        style: BlackLightTextStyles.body(color: variant)),
                  ),
                  OutlinedButton(
                    onPressed: onSignOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.error,
                      side: BorderSide(color: c.error),
                    ),
                    child: Text(HomeownerSettingsContent.signOutButton,
                        style: BlackLightTextStyles.body(color: c.error)
                            .copyWith(fontWeight: FontWeight.w500)),
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

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

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

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback? onEdit;

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
          TextButton(
            onPressed: onEdit,
            child: Text(ButtonsContent.edit,
                style: BlackLightTextStyles.caption(color: c.primary)
                    .copyWith(fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}
