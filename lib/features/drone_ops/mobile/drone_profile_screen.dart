import 'package:flutter/material.dart';

import '../../../core/ui/app_feedback.dart';
import '../../../theme/blacklight_theme.dart';
import 'drone_operator_shell.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Drone Operator: Profile (mobile)
// All identity / stats fields default to empty until backend wires in.
// ─────────────────────────────────────────────

class DroneProfileScreen extends StatelessWidget {
  final String? operatorName;
  final String? operatorTier;
  final int missionsCompleted;
  final double averageRating;
  final String? droneModel;
  final String? operatingZip;
  final String? walletAddress;
  final VoidCallback? onConnectWallet;
  final VoidCallback? onSignOut;

  const DroneProfileScreen({
    super.key,
    this.operatorName,
    this.operatorTier,
    this.missionsCompleted = 0,
    this.averageRating = 0.0,
    this.droneModel,
    this.operatingZip,
    this.walletAddress,
    this.onConnectWallet,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DroneOperatorAppBar(
          title: 'Profile', showAvatar: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            BlackLightSpacing.sm, BlackLightSpacing.md, BlackLightSpacing.sm, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IdentityCard(
                name: operatorName, tier: operatorTier),
            const SizedBox(height: BlackLightSpacing.md),
            _StatsRow(
                missions: missionsCompleted,
                rating: averageRating),
            const SizedBox(height: BlackLightSpacing.md),
            _SectionHeading(label: 'Equipment'),
            const SizedBox(height: BlackLightSpacing.sm),
            _DetailCard(
              rows: [
                _DetailRow(
                  icon: Icons.flight_takeoff_outlined,
                  label: 'Primary drone',
                  value: droneModel ?? 'Not set',
                ),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Operating ZIP',
                  value: operatingZip ?? 'Not set',
                ),
              ],
            ),
            const SizedBox(height: BlackLightSpacing.md),
            _SectionHeading(label: 'Wallet'),
            const SizedBox(height: BlackLightSpacing.sm),
            _WalletCard(
              walletAddress: walletAddress,
              onConnect: onConnectWallet,
            ),
            const SizedBox(height: BlackLightSpacing.md),
            _SectionHeading(label: 'Account'),
            const SizedBox(height: BlackLightSpacing.sm),
            _SettingsList(onSignOut: onSignOut),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String? name;
  final String? tier;

  const _IdentityCard({this.name, this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_outline,
                size: 28, color: BlackLightColors.textBody),
          ),
          const SizedBox(width: BlackLightSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name == null || name!.isEmpty ? '—' : name!,
                  style: BlackLightTextStyles.mobileH2(),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BlackLightColors.surface,
                    border: Border.all(
                        color: BlackLightColors.accent, width: 1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tier == null || tier!.isEmpty
                        ? 'CERTIFIED · DRONE OPERATOR'
                        : tier!.toUpperCase(),
                    style: BlackLightTextStyles.captionBold(
                        color: BlackLightColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int missions;
  final double rating;

  const _StatsRow({required this.missions, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatTile(
                label: 'MISSIONS',
                value: missions.toString())),
        const SizedBox(width: BlackLightSpacing.sm),
        Expanded(
            child: _StatTile(
                label: 'RATING',
                value: rating == 0
                    ? '—'
                    : rating.toStringAsFixed(1))),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: BlackLightTextStyles.captionBold(
                  color: BlackLightColors.textBody)),
          const SizedBox(height: 4),
          Text(value, style: BlackLightTextStyles.dataLarge()),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String label;

  const _SectionHeading({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(),
        style: BlackLightTextStyles.captionBold(
            color: BlackLightColors.textBody));
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});
}

class _DetailCard extends StatelessWidget {
  final List<_DetailRow> rows;

  const _DetailCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          final isLast = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: BlackLightSpacing.sm,
                vertical: BlackLightSpacing.sm),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom:
                          BorderSide(color: BlackLightColors.border)),
            ),
            child: Row(
              children: [
                Icon(r.icon, size: 18, color: BlackLightColors.textBody),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(r.label,
                        style: BlackLightTextStyles.mobileBody(
                            color: BlackLightColors.textBody))),
                Text(r.value,
                    style: BlackLightTextStyles.mobileBody(
                            color: BlackLightColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String? walletAddress;
  final VoidCallback? onConnect;

  const _WalletCard({this.walletAddress, this.onConnect});

  @override
  Widget build(BuildContext context) {
    final connected =
        walletAddress != null && walletAddress!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 20, color: BlackLightColors.textBody),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(connected ? 'Connected wallet' : 'No wallet connected',
                    style: BlackLightTextStyles.mobileH3()),
                const SizedBox(height: 2),
                Text(
                  connected ? walletAddress! : 'Link a wallet to receive payouts.',
                  style: BlackLightTextStyles.mobileBody(
                      color: BlackLightColors.textBody),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: connected ? null : onConnect,
            style: OutlinedButton.styleFrom(
              foregroundColor: BlackLightColors.textPrimary,
              side: const BorderSide(color: BlackLightColors.border),
              shape: const StadiumBorder(),
            ),
            child: Text(connected ? 'Manage' : 'Connect'),
          ),
        ],
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  final VoidCallback? onSignOut;

  const _SettingsList({this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {
              AppFeedback.comingSoon(
                context,
                feature: 'Notification settings',
              );
            },
          ),
          const Divider(height: 1),
          _SettingsItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy',
            onTap: () {
              AppFeedback.showInfoDialog(
                context,
                title: 'Privacy',
                message:
                    'Drone operator privacy controls will be available in a future release.',
              );
            },
          ),
          const Divider(height: 1),
          _SettingsItem(
            icon: Icons.support_agent_outlined,
            label: 'Help & support',
            onTap: () {
              AppFeedback.showInfoDialog(
                context,
                title: 'Help & support',
                message:
                    'Contact your operator lead or in-app help once support is live.',
              );
            },
          ),
          const Divider(height: 1),
          _SettingsItem(
            icon: Icons.logout,
            label: 'Sign out',
            destructive: true,
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? BlackLightColors.error
        : BlackLightColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BlackLightSpacing.sm,
            vertical: BlackLightSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: BlackLightTextStyles.mobileBody(color: color)
                      .copyWith(fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: BlackLightColors.textCaption),
          ],
        ),
      ),
    );
  }
}
