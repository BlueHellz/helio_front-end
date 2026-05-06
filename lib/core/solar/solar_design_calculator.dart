import 'dart:math' as math;

import 'package:limye_app/core/content/content_registry.dart';
import 'package:limye_app/core/models/project.dart';
import 'package:limye_app/core/models/solar_design_data.dart';

/// DC module size assumption (aligned with interactive canvas preview).
const double kSolarPanelKw = 0.4;

const double kCostPerKwUsd = 2500;
const double kElectricityRateUsdPerKwh = 0.17;
const double kAnnualDegradation = 0.005;
const double kFederalItcFraction = 0.30;

RecalculatedFinancials recalculateSolarFinancials({
  required List<CanvasSolarPanel> panels,
  required List<RoofSegmentData> segments,
}) {
  final segById = {for (final s in segments) s.id: s};
  final n = panels.length;
  final systemKw = n * kSolarPanelKw;
  final totalCost = systemKw * kCostPerKwUsd;
  var annualKwh = 0.0;
  for (final p in panels) {
    final seg = segById[p.roofSegmentId];
    if (seg == null) continue;
    annualKwh += kSolarPanelKw * seg.annualSunshineKwhPerKw;
  }
  var savings25 = 0.0;
  for (var y = 0; y < 25; y++) {
    savings25 += annualKwh *
        math.pow(1 - kAnnualDegradation, y) *
        kElectricityRateUsdPerKwh;
  }
  final itc = totalCost * kFederalItcFraction;
  final netCost = totalCost - itc;
  final y1 = annualKwh * kElectricityRateUsdPerKwh;
  final payback = y1 > 1e-6 ? netCost / y1 : double.nan;
  return RecalculatedFinancials(
    panelCount: n,
    systemSizeKw: systemKw,
    annualProductionKwh: annualKwh,
    savings25YearUsd: savings25,
    paybackYears: payback,
    totalSystemCostUsd: totalCost,
    incentives: [
      SolarIncentiveLine(amountUsd: itc),
    ],
  );
}

bool liveDesignStateMatchesCanvas(
    InteractiveDesignLiveState? live, SolarDesignData data) {
  if (live == null) return false;
  final cfg = data.activeConfig;
  if (cfg == null) return false;
  return live.configId == cfg.id &&
      live.activeConfigIndex == data.activeConfigIndex;
}

List<CanvasSolarPanel> panelsForConfiguration({
  required SolarDesignData data,
  InteractiveDesignLiveState? live,
}) {
  if (liveDesignStateMatchesCanvas(live, data)) {
    return live!.panels;
  }
  return data.activeConfig?.panels ?? const [];
}

double annualProductionKwhForDesign({
  required SolarDesignData data,
  required RecalculatedFinancials financials,
}) {
  return data.yearlyEnergyDcKwh ?? financials.annualProductionKwh;
}

/// JSON fragment for anonymous AI-chat design payloads (`/estimate`, save-email, etc.).
Map<String, dynamic> solarDesignAiChatCustomData({
  required SolarDesignData data,
  required List<CanvasSolarPanel> panels,
  required RecalculatedFinancials financials,
}) {
  return {
    'source': 'homeowner_ai_chat',
    'system_size_kw': financials.systemSizeKw,
    'panel_count': financials.panelCount,
    'annual_production_kwh': annualProductionKwhForDesign(
      data: data,
      financials: financials,
    ),
    'active_config_index': data.activeConfigIndex,
    'active_configuration_id': data.activeConfig?.id,
    'roof_segment_count': data.roofSegments.length,
    if (data.yearlyEnergyDcKwh != null)
      'yearly_energy_dc_kwh': data.yearlyEnergyDcKwh,
    'panel_ids': panels.map((e) => e.id).toList(),
  };
}

Project projectStubForEstimateMerge({
  required String address,
  required String? ownerName,
  required RecalculatedFinancials financials,
  required double annualProductionKwh,
}) {
  final name = (ownerName ?? '').trim();
  return Project(
    id: '',
    address: address,
    clientName: name.isEmpty ? CommonContent.emDash : name,
    status: ProjectStatus.designing,
    type: ProjectType.residential,
    date: DateTime.now(),
    systemSizeKw: financials.systemSizeKw,
    panelCount: financials.panelCount,
    annualProductionKwh: annualProductionKwh,
    yearOneSavings: null,
    estimatedPaybackYears: financials.paybackYears.isFinite
        ? financials.paybackYears
        : null,
  );
}
