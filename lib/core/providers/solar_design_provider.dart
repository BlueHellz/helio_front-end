import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/models/solar_design_data.dart';

/// Source data for [InteractiveDesignCanvas]; null [SolarDesignViewState.data] means waiting / not loaded yet.
class SolarDesignNotifier extends StateNotifier<SolarDesignViewState> {
  SolarDesignNotifier() : super(const SolarDesignViewState());

  void setDesign(SolarDesignData? data, {bool hasBackendError = false}) {
    state = SolarDesignViewState(data: data, hasBackendError: hasBackendError);
  }

  void setBackendError({bool value = true}) {
    state = SolarDesignViewState(data: state.data, hasBackendError: value);
  }

  void clear() => state = const SolarDesignViewState();

  /// Demo payload until the homeowner design API persists into this notifier.
  void seedDemoDesign() {
    state = SolarDesignViewState(data: SolarDesignData.demo());
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
