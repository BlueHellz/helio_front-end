import 'package:flutter/material.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/models/solar_estimate_presentation.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

/// Scrollable anonymous estimate breakdown (premium, border-only surfaces).
class SolarEstimateSummaryView extends StatelessWidget {
  const SolarEstimateSummaryView({super.key, required this.presentation});

  final SolarEstimatePresentation presentation;

  static String _formatThousands(num n) {
    final raw = n.round().abs().toString();
    final buf = StringBuffer();
    if (n.round() < 0) buf.write('-');
    final len = raw.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(',');
      buf.write(raw[i]);
    }
    return buf.toString();
  }

  static String _usdRounded(num value) =>
      '${'\$'}${_formatThousands(value.round())}';

  @override
  Widget build(BuildContext context) {
    final p = presentation;
    final outline = context.colors.outline;

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KooyohSpacing.sm),
        child: Text(
          title,
          style: KooyohTextStyles.bodyBold(color: context.colors.onSurface),
        ),
      );
    }

    Widget metricRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KooyohSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: KooyohTextStyles.caption(
                  color: context.colors.onSurfaceMuted,
                ),
              ),
            ),
            Text(
              value,
              style: KooyohTextStyles.data(color: context.colors.onSurface),
            ),
          ],
        ),
      );
    }

    Widget moneyRow(String label, double amount) {
      return metricRow(label, _usdRounded(amount));
    }

    Widget cardWrap({required Widget child}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(KooyohSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(KooyohRadius.md),
          border: Border.all(color: outline, width: 1),
        ),
        child: child,
      );
    }

    final payback = p.paybackYears.isFinite
        ? '${p.paybackYears.toStringAsFixed(1)}'
            '${DesignEstimateChatContent.paybackYearsSuffix}'
        : InteractiveCanvasContent.paybackUnavailable;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DesignEstimateChatContent.yourSolarEstimateTitle,
              style: KooyohTextStyles.cardHeading(
                color: context.colors.onSurface,
              ),
            ),
            SizedBox(height: KooyohSpacing.sm + KooyohSpacing.xs / 4),
            sectionTitle(DesignEstimateChatContent.designSummarySection),
            cardWrap(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  metricRow(
                    HomeownerDesignSummaryContent.specSystemSize,
                    '${p.systemSizeKw.toStringAsFixed(1)} kW',
                  ),
                  metricRow(
                    HomeownerDesignSummaryContent.specPanelCount,
                    '${p.panelCount}',
                  ),
                  metricRow(
                    HomeownerDesignSummaryContent.specAnnualProduction,
                    '${_formatThousands(p.annualProductionKwh)} kWh',
                  ),
                ],
              ),
            ),
            SizedBox(height: KooyohSpacing.md),
            sectionTitle(DesignEstimateChatContent.costBreakdownTitle),
            cardWrap(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  moneyRow(DesignEstimateChatContent.totalSystemCost,
                      p.totalSystemCostUsd),
                  const SizedBox(height: KooyohSpacing.xs),
                  moneyRow(DesignEstimateChatContent.equipmentCost,
                      p.equipmentCostUsd),
                  moneyRow(
                      DesignEstimateChatContent.laborCost, p.laborCostUsd),
                  moneyRow(DesignEstimateChatContent.permittingCost,
                      p.permittingCostUsd),
                ],
              ),
            ),
            SizedBox(height: KooyohSpacing.md),
            sectionTitle(DesignEstimateChatContent.savingsSection),
            cardWrap(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  moneyRow(DesignEstimateChatContent.savings25Year,
                      p.savings25YearUsd),
                  metricRow(DesignEstimateChatContent.paybackPeriod, payback),
                ],
              ),
            ),
            SizedBox(height: KooyohSpacing.md),
            sectionTitle(DesignEstimateChatContent.incentivesSection),
            cardWrap(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  moneyRow(
                    InteractiveCanvasContent.incentiveFederalItc,
                    p.federalItcUsd,
                  ),
                  SizedBox(height: KooyohSpacing.sm),
                  Text(
                    p.stateLocalNote,
                    style: KooyohTextStyles.caption(
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: KooyohSpacing.md + KooyohSpacing.xs / 2),
            Text(
              DesignEstimateChatContent.disclaimer,
              style: KooyohTextStyles.caption(
                color: context.colors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
