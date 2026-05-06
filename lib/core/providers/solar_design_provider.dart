import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/models/solar_design_data.dart';
/// Source data for [InteractiveDesignCanvas]; null [SolarDesignViewState.data] means waiting / not loaded yet.
class SolarDesignNotifier extends StateNotifier<SolarDesignViewState> {
  SolarDesignNotifier() : super(const SolarDesignViewState());

  void setDesign(SolarDesignData? data, {bool hasBackendError = false}) {
    state = SolarDesignViewState(
      data: data,
      hasBackendError: hasBackendError,
      intakeAddress: state.intakeAddress,
      intakeOwnerName: state.intakeOwnerName,
      intakeEmail: state.intakeEmail,
    );
  }

  void setBackendError({bool value = true}) {
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: value,
      intakeAddress: state.intakeAddress,
      intakeOwnerName: state.intakeOwnerName,
      intakeEmail: state.intakeEmail,
    );
  }

  void clear() => state = const SolarDesignViewState();

  void setIntakeContext({
    required String address,
    required String ownerName,
    String? email,
  }) {
    final e = email?.trim();
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: state.hasBackendError,
      intakeAddress: address.trim().isEmpty ? null : address.trim(),
      intakeOwnerName: ownerName.trim().isEmpty ? null : ownerName.trim(),
      intakeEmail: e == null || e.isEmpty ? null : e,
    );
  }
}

/// Homeowner AI chat solar canvas + Riverpod bindings.
final designProvider =
    StateNotifierProvider<SolarDesignNotifier, SolarDesignViewState>(
  (ref) => SolarDesignNotifier(),
);

/// Last live recalculation emitted by [InteractiveDesignCanvas] after user edits.
final interactiveDesignLiveProvider =
    StateProvider<InteractiveDesignLiveState?>((ref) => null);
