import 'package:flutter/foundation.dart';

/// Client-side view model for the anonymous solar estimate (API + local rules).
@immutable
class SolarEstimatePresentation {
  const SolarEstimatePresentation({
    required this.systemSizeKw,
    required this.panelCount,
    required this.annualProductionKwh,
    required this.totalSystemCostUsd,
    required this.equipmentCostUsd,
    required this.laborCostUsd,
    required this.permittingCostUsd,
    required this.savings25YearUsd,
    required this.paybackYears,
    required this.federalItcUsd,
    required this.stateLocalNote,
  });

  final double systemSizeKw;
  final int panelCount;
  final int annualProductionKwh;
  final double totalSystemCostUsd;
  final double equipmentCostUsd;
  final double laborCostUsd;
  final double permittingCostUsd;
  final double savings25YearUsd;
  final double paybackYears;
  final double federalItcUsd;
  final String stateLocalNote;
}
