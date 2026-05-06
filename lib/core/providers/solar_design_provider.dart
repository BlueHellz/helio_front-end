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
    );
  }

  void setBackendError({bool value = true}) {
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: value,
      intakeAddress: state.intakeAddress,
      intakeOwnerName: state.intakeOwnerName,
    );
  }

  void clear() => state = const SolarDesignViewState();

  void setIntakeContext({required String address, required String ownerName}) {
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: state.hasBackendError,
      intakeAddress: address.trim().isEmpty ? null : address.trim(),
      intakeOwnerName: ownerName.trim().isEmpty ? null : ownerName.trim(),
    );
  }

  /// Demo payload until the homeowner design API persists into this notifier.
  void seedDemoDesign() {
    state = SolarDesignViewState(
      data: SolarDesignData.demo(),
      hasBackendError: false,
      intakeAddress: state.intakeAddress,
      intakeOwnerName: state.intakeOwnerName,
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
