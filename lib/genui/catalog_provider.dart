import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import '../catalog/component_catalog.dart';
import '../core/providers/session_providers.dart';

/// Stock A2UI core catalog. LIMYÈ visual design is applied via host [ThemeData]
/// (no per-widget styling from AI).
final limyeGenUiCatalogProvider = FutureProvider<Catalog>((ref) async {
  try {
    await ref.watch(apiProvider).getOrgCustomComponents();
  } catch (_) {}
  return CoreCatalogItems.asCatalog();
});

/// Org custom component rows for settings grids.
final orgCustomComponentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await ref.watch(apiProvider).getOrgCustomComponents();
  } catch (_) {
    return const [];
  }
});

/// Catalog + org registrations as a system prompt augmentation string.
String limyeCatalogPromptAugment(WidgetRef ref) {
  final custom = ref.read(orgCustomComponentsProvider).valueOrNull ?? const [];
  final schema = jsonEncode(ComponentCatalog.catalogSchema);
  final head = schema.length > 8000 ? '${schema.substring(0, 8000)}…' : schema;
  return 'LIMYÈ_COMPONENT_CATALOG_JSON: $head\nORG_CUSTOM_COMPONENTS: ${custom.isEmpty ? '[]' : jsonEncode(custom)}';
}
