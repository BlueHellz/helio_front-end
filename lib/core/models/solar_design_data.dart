import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single roof plane with canvas polygon and sun potential metadata.
@immutable
class RoofSegmentData {
  const RoofSegmentData({
    required this.id,
    required this.polygon,
    required this.orientationScore,
    required this.annualSunshineKwhPerKw,
  });

  final String id;
  final List<Offset> polygon;
  final double orientationScore;
  final double annualSunshineKwhPerKw;
}

/// One solar panel on the interactive canvas (mutable copy of Google Solar layout).
@immutable
class CanvasSolarPanel {
  const CanvasSolarPanel({
    required this.id,
    required this.roofSegmentId,
    required this.center,
    this.portrait = true,
  });

  final String id;
  final String roofSegmentId;
  final Offset center;
  final bool portrait;

  CanvasSolarPanel copyWith({
    String? id,
    String? roofSegmentId,
    Offset? center,
    bool? portrait,
  }) {
    return CanvasSolarPanel(
      id: id ?? this.id,
      roofSegmentId: roofSegmentId ?? this.roofSegmentId,
      center: center ?? this.center,
      portrait: portrait ?? this.portrait,
    );
  }
}

/// Pre-designed layout option from Google Solar API.
@immutable
class PanelConfigurationData {
  const PanelConfigurationData({
    required this.id,
    required this.label,
    required this.panels,
  });

  final String id;
  final String label;
  final List<CanvasSolarPanel> panels;

  PanelConfigurationData copyWith({List<CanvasSolarPanel>? panels}) {
    return PanelConfigurationData(
      id: id,
      label: label,
      panels: panels ?? this.panels,
    );
  }
}

/// Backend snapshot of financials (baseline before local edits).
@immutable
class SolarFinancialsSnapshot {
  const SolarFinancialsSnapshot({
    required this.panelCount,
    required this.systemSizeKw,
    required this.annualProductionKwh,
    required this.savings25YearUsd,
    required this.paybackYears,
    required this.totalSystemCostUsd,
    required this.incentives,
  });

  final int panelCount;
  final double systemSizeKw;
  final double annualProductionKwh;
  final double savings25YearUsd;
  final double paybackYears;
  final double totalSystemCostUsd;
  final List<SolarIncentiveLine> incentives;
}

@immutable
class SolarIncentiveLine {
  /// When null, the UI resolves the label (e.g. Federal ITC) from the content registry.
  const SolarIncentiveLine({this.label, required this.amountUsd});

  final String? label;
  final double amountUsd;
}

/// Live recalculation output (client-side rules).
@immutable
class RecalculatedFinancials {
  const RecalculatedFinancials({
    required this.panelCount,
    required this.systemSizeKw,
    required this.annualProductionKwh,
    required this.savings25YearUsd,
    required this.paybackYears,
    required this.totalSystemCostUsd,
    required this.incentives,
  });

  final int panelCount;
  final double systemSizeKw;
  final double annualProductionKwh;
  final double savings25YearUsd;
  final double paybackYears;
  final double totalSystemCostUsd;
  final List<SolarIncentiveLine> incentives;
}

/// Full payload for the interactive canvas (from API or demo seed).
@immutable
class SolarDesignData {
  const SolarDesignData({
    required this.roofSegments,
    required this.panelConfigs,
    this.activeConfigIndex = 0,
    required this.initialFinancials,
    /// When set (e.g. API DC yearly yield), display metrics may prefer this value.
    this.yearlyEnergyDcKwh,
  });

  final List<RoofSegmentData> roofSegments;
  final List<PanelConfigurationData> panelConfigs;
  final int activeConfigIndex;
  final SolarFinancialsSnapshot initialFinancials;

  /// Optional annual DC energy (kWh) from backend; overrides recalculated production in UI when set.
  final double? yearlyEnergyDcKwh;

  PanelConfigurationData? get activeConfig {
    if (panelConfigs.isEmpty) return null;
    final i = activeConfigIndex.clamp(0, panelConfigs.length - 1);
    return panelConfigs[i];
  }

  /// Demo layout for design-flow preview (replace with API data in production).
  static SolarDesignData demo() {
    const left = 900.0;
    const top = 1100.0;
    final segSouth = RoofSegmentData(
      id: 'seg_south',
      polygon: [
        const Offset(left, top),
        Offset(left + 920, top - 40),
        Offset(left + 980, top + 420),
        Offset(left + 40, top + 480),
      ],
      orientationScore: 0.93,
      annualSunshineKwhPerKw: 1520,
    );
    final segWest = RoofSegmentData(
      id: 'seg_west',
      polygon: [
        Offset(left - 320, top + 80),
        Offset(left - 40, top + 40),
        Offset(left + 20, top + 440),
        Offset(left - 280, top + 500),
      ],
      orientationScore: 0.72,
      annualSunshineKwhPerKw: 1280,
    );
    final segNorth = RoofSegmentData(
      id: 'seg_north',
      polygon: [
        Offset(left + 200, top - 280),
        Offset(left + 760, top - 320),
        Offset(left + 820, top - 40),
        Offset(left + 240, top),
      ],
      orientationScore: 0.55,
      annualSunshineKwhPerKw: 980,
    );
    final segPoor = RoofSegmentData(
      id: 'seg_shade',
      polygon: [
        Offset(left + 1020, top + 200),
        Offset(left + 1280, top + 180),
        Offset(left + 1300, top + 380),
        Offset(left + 1040, top + 420),
      ],
      orientationScore: 0.38,
      annualSunshineKwhPerKw: 720,
    );

    const panelKw = 0.4;
    double annualForPanels(List<CanvasSolarPanel> list) {
      var kwh = 0.0;
      for (final p in list) {
        final seg = [segSouth, segWest, segNorth, segPoor]
            .firstWhere((s) => s.id == p.roofSegmentId);
        kwh += panelKw * seg.annualSunshineKwhPerKw;
      }
      return kwh;
    }

    final panels = <CanvasSolarPanel>[
      CanvasSolarPanel(
        id: 'gp_1',
        roofSegmentId: segSouth.id,
        center: Offset(left + 220, top + 120),
        portrait: true,
      ),
      CanvasSolarPanel(
        id: 'gp_2',
        roofSegmentId: segSouth.id,
        center: Offset(left + 420, top + 100),
        portrait: true,
      ),
      CanvasSolarPanel(
        id: 'gp_3',
        roofSegmentId: segSouth.id,
        center: Offset(left + 620, top + 200),
        portrait: true,
      ),
      CanvasSolarPanel(
        id: 'gp_4',
        roofSegmentId: segWest.id,
        center: Offset(left - 200, top + 220),
        portrait: false,
      ),
      CanvasSolarPanel(
        id: 'gp_5',
        roofSegmentId: segWest.id,
        center: Offset(left - 120, top + 340),
        portrait: false,
      ),
      CanvasSolarPanel(
        id: 'gp_6',
        roofSegmentId: segNorth.id,
        center: Offset(left + 480, top - 200),
        portrait: true,
      ),
    ];

    final n = panels.length;
    final systemKw = n * panelKw;
    const costPerKw = 2500.0;
    const rate = 0.17;
    const deg = 0.005;
    const itcRate = 0.30;
    final totalCost = systemKw * costPerKw;
    final annualKwh = annualForPanels(panels);
    var savings25 = 0.0;
    for (var y = 0; y < 25; y++) {
      final prod = annualKwh * math.pow(1 - deg, y.toDouble());
      savings25 += prod * rate;
    }
    final itc = totalCost * itcRate;
    final netCost = totalCost - itc;
    final y1dol = annualKwh * rate;
    final payback = y1dol > 1e-6 ? netCost / y1dol : double.nan;

    final initial = SolarFinancialsSnapshot(
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

    return SolarDesignData(
      roofSegments: [segSouth, segWest, segNorth, segPoor],
      panelConfigs: [
        PanelConfigurationData(
          id: 'google_default',
          label: 'Recommended',
          panels: panels,
        ),
      ],
      activeConfigIndex: 0,
      initialFinancials: initial,
      yearlyEnergyDcKwh: null,
    );
  }

}

/// Riverpod-facing state for the solar canvas data source.
@immutable
class SolarDesignViewState {
  const SolarDesignViewState({
    this.data,
    this.hasBackendError = false,
    this.intakeAddress,
    this.intakeOwnerName,
    this.intakeEmail,
  });

  final SolarDesignData? data;
  final bool hasBackendError;

  /// Guided intake fields for anonymous `/estimate` requests.
  final String? intakeAddress;
  final String? intakeOwnerName;
  final String? intakeEmail;
}

/// Latest interactive edit snapshot (financials + panel list).
@immutable
class InteractiveDesignLiveState {
  const InteractiveDesignLiveState({
    required this.financials,
    required this.panels,
    required this.activeConfigIndex,
    required this.configId,
  });

  final RecalculatedFinancials financials;
  final List<CanvasSolarPanel> panels;
  final int activeConfigIndex;
  final String configId;
}
