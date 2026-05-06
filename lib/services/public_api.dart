import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Anonymous design / estimate calls (no Bearer token).
class PublicApiException implements Exception {
  PublicApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'PublicApiException($statusCode)';
}

class PublicLimyeApi {
  PublicLimyeApi({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _base = baseUrl ?? BlackLightConfig.apiBaseUrl;

  final http.Client _client;
  final String _base;

  Uri _u(String path) => Uri.parse('$_base/api/v1$path');

  Future<Map<String, dynamic>> postDesign(Map<String, dynamic> body) async {
    final r = await _client.post(
      _u('/design'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decodeObject(r);
  }

  Future<Map<String, dynamic>> postEstimate(Map<String, dynamic> body) async {
    final r = await _client.post(
      _u('/estimate'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decodeObject(r);
  }

  Future<Map<String, dynamic>> postSaveDesignEmail(
      Map<String, dynamic> body) async {
    final r = await _client.post(
      _u('/design/save-email'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decodeObject(r);
  }

  Map<String, dynamic> _decodeObject(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return <String, dynamic>{};
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
      if (d is Map) return d.cast<String, dynamic>();
      return <String, dynamic>{};
    }
    throw PublicApiException(r.statusCode, r.body);
  }

  void dispose() => _client.close();
}
