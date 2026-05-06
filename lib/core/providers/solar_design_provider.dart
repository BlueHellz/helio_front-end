import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:limye_app/core/models/solar_design_data.dart';

/// Source data for [InteractiveDesignCanvas]; null [SolarDesignViewState.data] means waiting / not loaded yet.
class SolarDesignNotifier extends StateNotifier<SolarDesignViewState> {
  SolarDesignNotifier() : super(const SolarDesignViewState());

  void setDesign(SolarDesignData? data, {bool hasBackendError = false}) {
    state = SolarDesignViewState(
      data: data,
      hasBackendError: hasBackendError,
      intakeStreetLine: state.intakeStreetLine,
      intakeCity: state.intakeCity,
      intakeState: state.intakeState,
      intakeZip: state.intakeZip,
      intakeOwnerName: state.intakeOwnerName,
      intakeEmail: state.intakeEmail,
    );
  }

  void setBackendError({bool value = true}) {
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: value,
      intakeStreetLine: state.intakeStreetLine,
      intakeCity: state.intakeCity,
      intakeState: state.intakeState,
      intakeZip: state.intakeZip,
      intakeOwnerName: state.intakeOwnerName,
      intakeEmail: state.intakeEmail,
    );
  }

  void clear() => state = const SolarDesignViewState();

  void setIntakeContext({
    required String streetLine,
    required String city,
    required String stateCode,
    required String zip,
    required String ownerName,
    String? email,
  }) {
    final e = email?.trim();
    final z = zip.trim();
    final c = city.trim();
    final st = stateCode.trim();
    final line = streetLine.trim();
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: state.hasBackendError,
      intakeStreetLine: line.isEmpty ? null : line,
      intakeCity: c.isEmpty ? null : c,
      intakeState: st.isEmpty ? null : st,
      intakeZip: z.isEmpty ? null : z,
      intakeOwnerName: ownerName.trim().isEmpty ? null : ownerName.trim(),
      intakeEmail: e == null || e.isEmpty ? null : e,
    );
  }

  /// First chat reply treated as a free-form address line (no structured city/state/zip).
  void setIntakeFromChatReply(String line) {
    final t = line.trim();
    if (t.isEmpty) return;
    state = SolarDesignViewState(
      data: state.data,
      hasBackendError: state.hasBackendError,
      intakeStreetLine: t,
      intakeCity: null,
      intakeState: null,
      intakeZip: null,
      intakeOwnerName: state.intakeOwnerName,
      intakeEmail: state.intakeEmail,
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
