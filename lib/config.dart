class BlackLightConfig {
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
        104,
        101,
        108,
        105,
        111,
        45,
        98,
        97,
        99,
        107,
        45,
        101,
        110,
        100,
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
