import 'package:flutter/material.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/models/solar_design_data.dart';
import 'package:kooyoh_app/core/solar/solar_design_calculator.dart';

double? _readDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return null;
}

SolarFinancialsSnapshot _snapshotFromRecalc(RecalculatedFinancials r) {
  return SolarFinancialsSnapshot(
    panelCount: r.panelCount,
    systemSizeKw: r.systemSizeKw,
    annualProductionKwh: r.annualProductionKwh,
    savings25YearUsd: r.savings25YearUsd,
    paybackYears: r.paybackYears,
    totalSystemCostUsd: r.totalSystemCostUsd,
    incentives: r.incentives,
  );
}

List<Offset> _parsePolygon(dynamic v) {
  if (v is! List || v.isEmpty) return const [];
  final pts = <Offset>[];
  for (final item in v) {
    if (item is Map) {
      final m = Map<String, dynamic>.from(item);
      final x = _readDouble(m['x'] ?? m['X'] ?? m['dx']);
      final y = _readDouble(m['y'] ?? m['Y'] ?? m['dy']);
      if (x != null && y != null) pts.add(Offset(x, y));
    } else if (item is List && item.length >= 2) {
      final x = _readDouble(item[0]);
      final y = _readDouble(item[1]);
      if (x != null && y != null) pts.add(Offset(x, y));
    }
  }
  return pts;
}

List<RoofSegmentData> _parseRoofSegments(Map<String, dynamic> m) {
  final raw = m['roof_segments'] ?? m['roofSegments'] ?? m['segments'];
  if (raw is! List || raw.isEmpty) return const [];

  final out = <RoofSegmentData>[];
  for (var i = 0; i < raw.length; i++) {
    final e = raw[i];
    if (e is! Map) continue;
    final map = Map<String, dynamic>.from(e);
    final id = (map['id'] ??
            map['segment_id'] ??
            map['segmentId'] ??
            'roof_seg_$i')
        .toString();
    final poly =
        _parsePolygon(map['polygon'] ?? map['vertices'] ?? map['points']);
    if (poly.length < 3) continue;
    final orientation = _readDouble(
          map['orientation_score'] ??
              map['orientationScore'] ??
              map['score'],
        ) ??
        0.72;
    final sun = _readDouble(
          map['annual_sunshine_kwh_per_kw'] ??
              map['annualSunshineKwhPerKw'] ??
              map['sunshine_kwh_per_kw'],
        ) ??
        1200.0;
    out.add(
      RoofSegmentData(
        id: id,
        polygon: poly,
        orientationScore: orientation.clamp(0.0, 1.0),
        annualSunshineKwhPerKw: sun,
      ),
    );
  }
  return out;
}

CanvasSolarPanel? _parsePanel(Map<String, dynamic> map, int index) {
  final id = (map['id'] ?? 'panel_$index').toString();
  final segId = (map['roof_segment_id'] ??
          map['roofSegmentId'] ??
          map['segment_id'] ??
          map['segmentId'] ??
          '')
      .toString();
  if (segId.isEmpty) return null;

  double? cx;
  double? cy;
  final c = map['center'] ?? map['position'];
  if (c is Map) {
    final cm = Map<String, dynamic>.from(c);
    cx = _readDouble(cm['x'] ?? cm['dx']);
    cy = _readDouble(cm['y'] ?? cm['dy']);
  }
  cx ??= _readDouble(map['x'] ?? map['center_x'] ?? map['centerX']);
  cy ??= _readDouble(map['y'] ?? map['center_y'] ?? map['centerY']);
  if (cx == null || cy == null) return null;

  final portrait = map['portrait'] is bool ? map['portrait'] as bool : true;
  return CanvasSolarPanel(
    id: id,
    roofSegmentId: segId,
    center: Offset(cx, cy),
    portrait: portrait,
  );
}

List<CanvasSolarPanel> _parsePanelsList(dynamic raw) {
  if (raw is! List || raw.isEmpty) return const [];
  final out = <CanvasSolarPanel>[];
  for (var i = 0; i < raw.length; i++) {
    final e = raw[i];
    if (e is! Map) continue;
    final p = _parsePanel(Map<String, dynamic>.from(e), i);
    if (p != null) out.add(p);
  }
  return out;
}

PanelConfigurationData? _parseConfigEntry(dynamic raw, int index) {
  if (raw is! Map) return null;
  final m = Map<String, dynamic>.from(raw);
  final id = (m['id'] ?? 'config_$index').toString();
  final label = (m['label'] ??
          m['name'] ??
          InteractiveCanvasContent.panelConfigFallbackLabel(index))
      .toString();
  final panels = _parsePanelsList(
    m['panels'] ?? m['solar_panels'] ?? m['solarPanels'],
  );
  if (panels.isEmpty) return null;
  return PanelConfigurationData(id: id, label: label, panels: panels);
}

List<PanelConfigurationData> _parsePanelConfigurations(Map<String, dynamic> m) {
  final cfgs =
      m['panel_configurations'] ?? m['panelConfigs'] ?? m['configurations'];
  if (cfgs is List && cfgs.isNotEmpty) {
    final out = <PanelConfigurationData>[];
    for (var i = 0; i < cfgs.length; i++) {
      final c = _parseConfigEntry(cfgs[i], i);
      if (c != null) out.add(c);
    }
    return out;
  }

  final flat = _parsePanelsList(
    m['panels'] ?? m['solar_panels'] ?? m['solarPanels'],
  );
  if (flat.isEmpty) return const [];

  final cfgId = (m['active_configuration_id'] ??
          m['activeConfigurationId'] ??
          'api_default')
      .toString();
  return [
    PanelConfigurationData(
      id: cfgId,
      label: InteractiveCanvasContent.apiDefaultPanelConfigLabel,
      panels: flat,
    ),
  ];
}

Iterable<Map<String, dynamic>> _candidateMaps(Map<String, dynamic> root) sync* {
  yield root;
  for (final key in ['project', 'data', 'payload', 'result', 'design']) {
    final v = root[key];
    if (v is Map<String, dynamic>) yield v;
    if (v is Map) yield Map<String, dynamic>.from(v);
  }
  for (final nested in [
    'solar_design',
    'solarDesign',
    'interactive_canvas',
    'interactiveCanvas',
    'canvas',
  ]) {
    final v = root[nested];
    if (v is Map<String, dynamic>) yield v;
    if (v is Map) yield Map<String, dynamic>.from(v);
  }
}

SolarDesignData? _tryParseDesignMap(Map<String, dynamic> m) {
  final segments = _parseRoofSegments(m);
  if (segments.isEmpty) return null;

  var configs = _parsePanelConfigurations(m);
  final idxRaw = m['active_config_index'] ?? m['activeConfigIndex'];
  var activeIdx = 0;
  if (idxRaw is int) {
    activeIdx = idxRaw;
  } else if (idxRaw is num) {
    activeIdx = idxRaw.toInt();
  }

  if (configs.isEmpty) {
    activeIdx = 0;
  } else {
    activeIdx = activeIdx.clamp(0, configs.length - 1);
  }

  final panelsForFin = configs.isEmpty
      ? const <CanvasSolarPanel>[]
      : configs[activeIdx.clamp(0, configs.length - 1)].panels;

  final fin = recalculateSolarFinancials(
    panels: panelsForFin,
    segments: segments,
  );

  final yearlyDc = _readDouble(
    m['yearly_energy_dc_kwh'] ?? m['yearlyEnergyDcKwh'],
  );

  return SolarDesignData(
    roofSegments: segments,
    panelConfigs: configs,
    activeConfigIndex: activeIdx,
    initialFinancials: _snapshotFromRecalc(fin),
    yearlyEnergyDcKwh: yearlyDc,
  );
}

/// Builds [SolarDesignData] from a `/design` (or wrapped) JSON map when roof
/// geometry is present. Returns null if no drawable roof segments were found.
SolarDesignData? solarDesignDataFromPublicDesignJson(
  Map<String, dynamic> root,
) {
  final seen = <Map<String, dynamic>>{};
  for (final c in _candidateMaps(root)) {
    if (seen.contains(c)) continue;
    seen.add(c);
    final parsed = _tryParseDesignMap(c);
    if (parsed != null) return parsed;
  }
  return null;
}
