import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';

/// Intake fields + preview project for anonymous design; cleared after save to API.
class HomeownerDesignDraft {
  const HomeownerDesignDraft({
    required this.previewProject,
    required this.intakeCustomData,
    required this.address,
    this.hasFullProposal = false,
  });

  final Project previewProject;
  final Map<String, dynamic> intakeCustomData;
  final String address;
  /// True after the user runs the public estimate endpoint (full proposal).
  final bool hasFullProposal;
}

class HomeownerDraftNotifier extends StateNotifier<HomeownerDesignDraft?> {
  HomeownerDraftNotifier() : super(null);

  void setDraft({
    required Project previewProject,
    required Map<String, dynamic> intakeCustomData,
    required String address,
    bool hasFullProposal = false,
  }) {
    state = HomeownerDesignDraft(
      previewProject: previewProject,
      intakeCustomData: intakeCustomData,
      address: address,
      hasFullProposal: hasFullProposal,
    );
  }

  void updatePreview(
    Project previewProject, {
    bool? hasFullProposal,
  }) {
    final d = state;
    if (d == null) return;
    state = HomeownerDesignDraft(
      previewProject: previewProject,
      intakeCustomData: d.intakeCustomData,
      address: d.address,
      hasFullProposal: hasFullProposal ?? d.hasFullProposal,
    );
  }

  void clear() => state = null;
}

final homeownerDraftProvider =
    StateNotifierProvider<HomeownerDraftNotifier, HomeownerDesignDraft?>(
  (ref) => HomeownerDraftNotifier(),
);
