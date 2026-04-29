import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_providers.dart';

class DesignModeNotifier extends StateNotifier<AsyncValue<bool>> {
  DesignModeNotifier(this._ref) : super(const AsyncValue.data(false)) {
    _ref.listen(sessionProvider, (_, __) => refresh(), fireImmediately: true);
  }

  final Ref _ref;

  Future<void> refresh() async {
    final token = _ref.read(sessionProvider).bearerToken;
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(false);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final v = await _ref.read(apiProvider).getDesignMode();
      state = AsyncValue.data(v);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _ref.read(apiProvider).setDesignMode(enabled);
    state = AsyncValue.data(enabled);
  }
}

final designModeProvider =
    StateNotifierProvider<DesignModeNotifier, AsyncValue<bool>>((ref) {
  return DesignModeNotifier(ref);
});

final customFieldsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getCustomFields();
});

final pipelinesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiProvider);
  return api.getPipelines();
});

/// Stages for one pipeline (Flow Mesh + CRM sources).
final pipelineStagesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, pipelineId) async {
  final api = ref.watch(apiProvider);
  return api.getStages(pipelineId);
});

/// Flow Mesh edges (`GET …/edges` or `custom_data.flow_mesh_edges`).
final pipelineEdgesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, pipelineId) async {
  final api = ref.watch(apiProvider);
  return api.getPipelineEdges(pipelineId);
});

/// Selected Flow Mesh stage id (canvas).
final selectedNodeProvider = StateProvider<String?>((ref) => null);

/// `{ residential: [...ids], commercial: [...], industrial: [...] }` merged from API.
final intakeLayoutFamily = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, projectType) async {
  final api = ref.watch(apiProvider);
  return api.getIntakeLayout(projectType);
});
