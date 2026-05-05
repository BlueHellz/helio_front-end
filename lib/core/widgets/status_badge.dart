import 'package:flutter/material.dart';
import '../../theme/limye_theme.dart';
import '../models/project.dart';

class StatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, bd) = status.resolveBadgeColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd, width: 1),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: LimyeTextStyles.captionBold(color: fg),
      ),
    );
  }
}

class WalletChip extends StatelessWidget {
  final double balance;

  const WalletChip({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 14, color: variant),
          const SizedBox(width: 6),
          Text(
            '${balance.toStringAsFixed(2)} HLIO',
            style: LimyeTextStyles.dataInline(color: c.onSurface),
          ),
        ],
      ),
    );
  }
}

class BlackLightChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const BlackLightChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? c.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.outline),
      ),
      child: Center(
        child: Text(
          label,
          style: LimyeTextStyles.caption(
            color: textColor ?? variant,
          ),
        ),
      ),
    );
  }
}
