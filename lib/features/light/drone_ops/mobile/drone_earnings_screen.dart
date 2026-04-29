import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';

import 'package:blacklight_app/core/ui/app_feedback.dart';
import 'package:blacklight_app/theme/blacklight_theme.dart';
import 'drone_operator_shell.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Drone Operator: Earnings (mobile)
// HLIO balance + payout milestones (product schema) + transactions list.
// All user data (balance, transactions) is empty until backend wires in.
// ─────────────────────────────────────────────

class DroneEarningsScreen extends StatelessWidget {
  final double hlioBalance;
  final List<DroneTransaction> transactions;

  const DroneEarningsScreen({
    super.key,
    this.hlioBalance = 0.0,
    this.transactions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const DroneOperatorAppBar(title: DroneOpsContent.mobileAppBarEarnings),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            BlackLightSpacing.sm, BlackLightSpacing.md, BlackLightSpacing.sm, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceCard(balance: hlioBalance),
            const SizedBox(height: BlackLightSpacing.md),
            Text(DroneOpsContent.earningsMilestonesTitle,
                style: BlackLightTextStyles.mobileH3()),
            const SizedBox(height: 4),
            Text(
                DroneOpsContent.earningsMilestonesSubtitle,
                style: BlackLightTextStyles.mobileBody(
                    color: BlackLightColors.textCaption)),
            const SizedBox(height: BlackLightSpacing.sm),
            const _MilestonesList(),
            const SizedBox(height: BlackLightSpacing.md),
            Row(
              children: [
                Text(DroneOpsContent.earningsRecentTitle,
                    style: BlackLightTextStyles.mobileH3()),
                const Spacer(),
                InkWell(
                  onTap: () => AppFeedback.comingSoon(
                        context,
                        feature: DroneOpsContent.earningsFeatureFullList,
                      ),
                  child: Text(DroneOpsContent.earningsSeeAll,
                      style: BlackLightTextStyles.mobileLabelBold(
                          color: BlackLightColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: BlackLightSpacing.sm),
            if (transactions.isEmpty)
              const _EmptyTx()
            else
              Column(
                children: transactions
                    .map((t) => _TxRow(tx: t))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class DroneTransaction {
  final String id;
  final String label;
  final double amountHlio;
  final DateTime timestamp;
  final bool isCredit;

  const DroneTransaction({
    required this.id,
    required this.label,
    required this.amountHlio,
    required this.timestamp,
    this.isCredit = true,
  });
}

class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DroneOpsContent.totalBalance,
              style: BlackLightTextStyles.captionBold(
                  color: BlackLightColors.textBody)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balance.toStringAsFixed(2),
                  style: BlackLightTextStyles.dataLarge()
                      .copyWith(fontSize: 36)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(DroneOpsContent.hlioTicker,
                    style: BlackLightTextStyles.mobileBody(
                        color: BlackLightColors.textBody)),
              ),
            ],
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: BlackLightSpacing.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () => AppFeedback.comingSoon(
                          context,
                          feature: DroneOpsContent.featureWithdrawals,
                        ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BlackLightColors.textPrimary,
                      side: const BorderSide(color: BlackLightColors.border),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(DroneOpsContent.withdraw,
                        style: BlackLightTextStyles.mobileButton(
                            color: BlackLightColors.textPrimary)),
                  ),
                ),
              ),
              const SizedBox(width: BlackLightSpacing.sm),
              Expanded(
                child: SizedBox(
                  height: BlackLightSpacing.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => AppFeedback.comingSoon(
                          context,
                          feature: DroneOpsContent.featureSendingHlio,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlackLightColors.accent,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text(DroneOpsContent.send,
                        style: BlackLightTextStyles.mobileButton()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestonesList extends StatelessWidget {
  const _MilestonesList();

  // Product schema — these are milestone definitions, not user data.
  static final _milestones = [
    (
      Icons.flight_takeoff_outlined,
      DroneOpsContent.milestone1Title,
      DroneOpsContent.milestone1Body,
      DroneOpsContent.milestone1Share,
    ),
    (
      Icons.task_alt_outlined,
      DroneOpsContent.milestone2Title,
      DroneOpsContent.milestone2Body,
      DroneOpsContent.milestone2Share,
    ),
    (
      Icons.solar_power_outlined,
      DroneOpsContent.milestone3Title,
      DroneOpsContent.milestone3Body,
      DroneOpsContent.milestone3Share,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _milestones
          .map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MilestoneRow(
                    icon: m.$1, title: m.$2, body: m.$3, share: m.$4),
              ))
          .toList(),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String share;

  const _MilestoneRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 20, color: BlackLightColors.accent),
          ),
          const SizedBox(width: BlackLightSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BlackLightTextStyles.mobileH3()),
                const SizedBox(height: 2),
                Text(body,
                    style: BlackLightTextStyles.mobileBody(
                        color: BlackLightColors.textBody)),
              ],
            ),
          ),
          const SizedBox(width: BlackLightSpacing.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(
                  color: BlackLightColors.accent, width: 1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(share,
                style: BlackLightTextStyles.captionBold(
                    color: BlackLightColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final DroneTransaction tx;

  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final sign = tx.isCredit ? '+' : '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.isCredit ? Icons.south_west : Icons.north_east,
              color: tx.isCredit
                  ? BlackLightColors.green
                  : BlackLightColors.textBody,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.label, style: BlackLightTextStyles.mobileH3()),
                Text(_formatDate(tx.timestamp),
                    style: BlackLightTextStyles.mobileBody(
                        color: BlackLightColors.textCaption)),
              ],
            ),
          ),
          Text(
            '$sign${tx.amountHlio.toStringAsFixed(2)}${DroneOpsContent.missionPayoutSuffix}',
            style: BlackLightTextStyles.dataLarge().copyWith(
              fontSize: 16,
              color: tx.isCredit
                  ? BlackLightColors.green
                  : BlackLightColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime t) {
    final months = [
      DroneOpsContent.monthJan,
      DroneOpsContent.monthFeb,
      DroneOpsContent.monthMar,
      DroneOpsContent.monthApr,
      DroneOpsContent.monthMay,
      DroneOpsContent.monthJun,
      DroneOpsContent.monthJul,
      DroneOpsContent.monthAug,
      DroneOpsContent.monthSep,
      DroneOpsContent.monthOct,
      DroneOpsContent.monthNov,
      DroneOpsContent.monthDec,
    ];
    return '${months[t.month - 1]} ${t.day}';
  }
}

class _EmptyTx extends StatelessWidget {
  const _EmptyTx();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.receipt_long_outlined,
                size: 24, color: BlackLightColors.textBody),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          Text(EmptyStatesContent.noTransactionsTitle,
              style: BlackLightTextStyles.mobileH3(),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(EmptyStatesContent.noTransactionsSubtitle,
              style: BlackLightTextStyles.mobileBody(
                  color: BlackLightColors.textCaption),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
