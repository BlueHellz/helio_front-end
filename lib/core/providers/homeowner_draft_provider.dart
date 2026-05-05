import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';

/// Intake fields + preview project for anonymous design; cleared after save to API.
class HomeownerDesignDraft {
  const HomeownerDesignDraft({
    required this.previewProject,
    required this.intakeCustomData,
    required this.address,
  });

  final Project previewProject;
  final Map<String, dynamic> intakeCustomData;
  final String address;
}

class HomeownerDraftNotifier extends StateNotifier<HomeownerDesignDraft?> {
  HomeownerDraftNotifier() : super(null);

  void setDraft({
    required Project previewProject,
    required Map<String, dynamic> intakeCustomData,
    required String address,
  }) {
    state = HomeownerDesignDraft(
      previewProject: previewProject,
      intakeCustomData: intakeCustomData,
      address: address,
    );
  }

  void clear() => state = null;
}

final homeownerDraftProvider =
    StateNotifierProvider<HomeownerDraftNotifier, HomeownerDesignDraft?>(
  (ref) => HomeownerDraftNotifier(),
);
