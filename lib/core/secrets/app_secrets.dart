import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads non-committed configuration from [assets/env.json] (gitignored).
/// Falls back to [assets/env.json.example] so builds work before the local
/// file is created. Never logs token values.
class AppSecrets {
  AppSecrets({required this.mapboxAccessToken});

  final String mapboxAccessToken;

  static AppSecrets? _cache;

  static Future<AppSecrets> load() async {
    if (_cache != null) return _cache!;
    String raw;
    try {
      raw = await rootBundle.loadString('assets/env.json');
    } catch (_) {
      raw = await rootBundle.loadString('assets/env.json.example');
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final token =
        (map['mapboxAccessToken'] as String? ?? '').trim();
    _cache = AppSecrets(mapboxAccessToken: token);
    return _cache!;
  }
}
