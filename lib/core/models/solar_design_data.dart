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

/// Full payload for the interactive canvas (built from the public design API response).
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

}

/// Riverpod-facing state for the solar canvas data source.
@immutable
class SolarDesignViewState {
  const SolarDesignViewState({
    this.data,
    this.hasBackendError = false,
    this.intakeStreetLine,
    this.intakeCity,
    this.intakeState,
    this.intakeZip,
    this.intakeOwnerName,
    this.intakeEmail,
  });

  final SolarDesignData? data;
  final bool hasBackendError;

  /// Street line (building number and street).
  final String? intakeStreetLine;

  /// City segment of the mailing address.
  final String? intakeCity;

  /// U.S. state postal abbreviation (e.g. TX).
  final String? intakeState;

  /// Five-digit ZIP.
  final String? intakeZip;

  /// Guided intake fields for anonymous `/estimate` requests.
  final String? intakeOwnerName;
  final String? intakeEmail;

  /// One line for API payloads: `123 Main St, Austin, TX 78701` when complete.
  String? get intakeMailingAddressOneLine {
    final street = (intakeStreetLine ?? '').trim();
    final city = (intakeCity ?? '').trim();
    final st = (intakeState ?? '').trim();
    final zip = (intakeZip ?? '').trim();
    if (street.isEmpty && city.isEmpty && st.isEmpty && zip.isEmpty) {
      return null;
    }
    if (street.isNotEmpty &&
        city.isNotEmpty &&
        st.isNotEmpty &&
        zip.isNotEmpty) {
      return '$street, $city, $st $zip';
    }
    final parts = <String>[
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (st.isNotEmpty) st,
      if (zip.isNotEmpty) zip,
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Header subtitle: formatted mailing line or null when nothing captured yet.
  String? get intakeFormattedDisplay => intakeMailingAddressOneLine;
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
