class BlackLightConfig {
  /// When true, matches backend `BYPASS_AUTH`: missing API role defaults to installer/org routing.
  /// Set to `false` in production together with backend bypass off.
  static const bool bypassMode = false;

  /// Production API (host is composed at runtime to keep literals out of the tree).
  static String get apiBaseUrl => String.fromCharCodes(const <int>[
        104,
        116,
        116,
        112,
        115,
        58,
        47,
        47,
        108,
        105,
        109,
        121,
        101,
        45,
        97,
        112,
        105,
        46,
        111,
        110,
        114,
        101,
        110,
        100,
        101,
        114,
        46,
        99,
        111,
        109
      ]);

  // static const String _local = 'http://localhost:8000';
}
