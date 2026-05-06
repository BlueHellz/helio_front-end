import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/models/project.dart';
import 'package:kooyoh_app/core/models/solar_estimate_presentation.dart';
import 'package:kooyoh_app/core/models/solar_design_data.dart';
import 'package:kooyoh_app/core/providers/session_providers.dart';
import 'package:kooyoh_app/core/providers/solar_design_provider.dart';
import 'package:kooyoh_app/core/solar/solar_design_calculator.dart';
import 'package:kooyoh_app/services/api.dart';
import 'package:kooyoh_app/services/public_api.dart';

double? _readUsd(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v is num) return v.toDouble();
  }
  return null;
}

/// Prefer nested maps like `estimate`, `proposal`, `data`, `project`.
Map<String, dynamic> _estimatePayloadRoot(Map<String, dynamic> root) {
  for (final key in ['estimate', 'proposal', 'data', 'financials']) {
    final n = root[key];
    if (n is Map<String, dynamic> && n.isNotEmpty) {
      final inner = _estimatePayloadRoot(n);
      if (inner.isNotEmpty) return inner;
    }
  }
  final project = root['project'];
  if (project is Map<String, dynamic>) return project;
  return root;
}

SolarEstimatePresentation buildSolarEstimatePresentation({
  required Map<String, dynamic> apiRoot,
  required Project mergedProject,
  required RecalculatedFinancials localFinancials,
  required int annualProductionKwhRounded,
}) {
  final nested = _estimatePayloadRoot(apiRoot);

  var total =
      _readUsd(nested, const [
            'totalSystemCostUsd',
            'total_system_cost_usd',
            'totalCostUsd',
          ]) ??
      localFinancials.totalSystemCostUsd;

  if (total <= 0 || total.isNaN) total = localFinancials.totalSystemCostUsd;

  var equip = _readUsd(nested, const [
        'equipmentCostUsd',
        'equipment_cost_usd',
      ]) ??
      total * 0.42;

  var labor = _readUsd(nested, const [
        'laborCostUsd',
        'labor_cost_usd',
      ]) ??
      total * 0.38;

  var permit = _readUsd(nested, const [
        'permittingCostUsd',
        'permitting_cost_usd',
        'permitsCostUsd',
      ]) ??
      total * 0.20;

  final sumParts = equip + labor + permit;
  if (sumParts > 1 && total > 1) {
    final scale = total / sumParts;
    equip *= scale;
    labor *= scale;
    permit *= scale;
  }

  final savings25 = _readUsd(nested, const [
        'savings25YearUsd',
        'savings_25_year_usd',
        'cumulativeSavingsUsd',
      ]) ??
      localFinancials.savings25YearUsd;

  final payRaw = mergedProject.estimatedPaybackYears ??
      _readUsd(nested, const [
            'estimatedPaybackYears',
            'estimated_payback_years',
            'paybackYears',
          ]) ??
      localFinancials.paybackYears;

  var itc = localFinancials.incentives.isNotEmpty
      ? localFinancials.incentives.first.amountUsd
      : 0.0;
  final itcFromApi = _readUsd(nested, const [
        'federalItcUsd',
        'federal_itc_usd',
        'itcAmountUsd',
      ]);
  if (itcFromApi != null && itcFromApi >= 0) {
    itc = itcFromApi;
  }

  return SolarEstimatePresentation(
    systemSizeKw:
        mergedProject.systemSizeKw ?? localFinancials.systemSizeKw,
    panelCount:
        mergedProject.panelCount ?? localFinancials.panelCount,
    annualProductionKwh: annualProductionKwhRounded,
    totalSystemCostUsd: total,
    equipmentCostUsd: equip,
    laborCostUsd: labor,
    permittingCostUsd: permit,
    savings25YearUsd: savings25,
    paybackYears: payRaw,
    federalItcUsd: itc,
    stateLocalNote: DesignEstimateChatContent.stateLocalSubtitle,
  );
}

@immutable
class AiDesignEstimateState {
  const AiDesignEstimateState({
    this.loading = false,
    this.presentation,
    this.showError = false,
  });

  final bool loading;
  final SolarEstimatePresentation? presentation;
  final bool showError;

  AiDesignEstimateState copyWith({
    bool? loading,
    SolarEstimatePresentation? presentation,
    bool clearPresentation = false,
    bool? showError,
  }) {
    return AiDesignEstimateState(
      loading: loading ?? this.loading,
      presentation: clearPresentation ? null : (presentation ?? this.presentation),
      showError: showError ?? this.showError,
    );
  }
}

/// Anonymous estimate POST for the homeowner AI chat design rail.
class AiDesignEstimateNotifier extends StateNotifier<AiDesignEstimateState> {
  AiDesignEstimateNotifier(this._ref) : super(const AiDesignEstimateState());

  final Ref _ref;

  void reset() => state = const AiDesignEstimateState();

  Future<bool> requestEstimate() async {
    final designVs = _ref.read(designProvider);
    final data = designVs.data;

    final address = (designVs.intakeMailingAddressOneLine ?? '').trim();
    if (data == null || data.roofSegments.isEmpty || address.isEmpty) {
      return false;
    }

    state = state.copyWith(
      loading: true,
      showError: false,
      clearPresentation: true,
    );

    try {
      final live = _ref.read(interactiveDesignLiveProvider);
      final panels = panelsForConfiguration(data: data, live: live);
      final financials =
          recalculateSolarFinancials(panels: panels, segments: data.roofSegments);
      final annualKwhRounded = annualProductionKwhForDesign(
            data: data,
            financials: financials,
          )
              .round();

      final stub = projectStubForEstimateMerge(
        address: address,
        ownerName: designVs.intakeOwnerName,
        financials: financials,
        annualProductionKwh: annualKwhRounded.toDouble(),
      );

      final custom = solarDesignAiChatCustomData(
        data: data,
        panels: panels,
        financials: financials,
      );
      final owner = (designVs.intakeOwnerName ?? '').trim();
      final body = projectCreateBody(
        address: address,
        projectType: 'residential',
        customData: custom,
        clientName: owner.isEmpty ? null : owner,
      );

      final public = _ref.read(publicKooyohApiProvider);
      final json = await public.postEstimate(body);
      if (json.isEmpty) {
        state = state.copyWith(loading: false, showError: true);
        return false;
      }

      final merged = projectFromPublicDesignJson(stub, json);
      final presentation = buildSolarEstimatePresentation(
        apiRoot: json,
        mergedProject: merged,
        localFinancials: financials,
        annualProductionKwhRounded: (merged.annualProductionKwh ?? annualKwhRounded.toDouble())
            .round(),
      );

      state = AiDesignEstimateState(
        loading: false,
        presentation: presentation,
        showError: false,
      );
      return true;
    } on PublicApiException {
      state = state.copyWith(loading: false, showError: true);
      return false;
    } catch (_) {
      state = state.copyWith(loading: false, showError: true);
      return false;
    }
  }
}

final aiDesignEstimateProvider =
    StateNotifierProvider<AiDesignEstimateNotifier, AiDesignEstimateState>(
  (ref) => AiDesignEstimateNotifier(ref),
);
