import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../core/models/project.dart';

typedef AuthHeadersBuilder = Map<String, String> Function();
typedef TokenRefreshFn = Future<bool> Function();

/// HTTP client for the Helio backend. All paths use the `/api/v1` prefix.
class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode)';
}

class BlackLightApi {
  BlackLightApi({
    http.Client? client,
    String? baseUrl,
    required AuthHeadersBuilder readHeaders,
    required TokenRefreshFn tryRefresh,
  })  : _readHeaders = readHeaders,
        _tryRefresh = tryRefresh,
        _client = client ?? http.Client(),
        _base = baseUrl ?? BlackLightConfig.apiBaseUrl;

  final http.Client _client;
  final String _base;
  final AuthHeadersBuilder _readHeaders;
  final TokenRefreshFn _tryRefresh;

  Uri _u(String path, [Map<String, String>? query]) =>
      Uri.parse('$_base/api/v1$path').replace(queryParameters: query);

  Future<http.Response> _withRetry(
    Future<http.Response> Function(Map<String, String> h) send,
  ) async {
    var res = await send(_readHeaders());
    if (res.statusCode == 401) {
      final ok = await _tryRefresh();
      if (ok) {
        res = await send(_readHeaders());
      }
    }
    return res;
  }

  Future<http.Response> _get(Uri uri) =>
      _withRetry((h) => _client.get(uri, headers: h));

  Future<http.Response> _post(Uri uri, {Object? body}) =>
      _withRetry((h) => _client.post(uri, headers: h, body: body));

  Future<http.Response> _patch(Uri uri, {Object? body}) =>
      _withRetry((h) => _client.patch(uri, headers: h, body: body));

  Future<http.Response> _put(Uri uri, {Object? body}) =>
      _withRetry((h) => _client.put(uri, headers: h, body: body));

  Future<dynamic> _decode(http.Response r) async {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return null;
      return jsonDecode(r.body);
    }
    throw ApiException(r.statusCode, r.body);
  }

  // ─── Projects ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listProjects({
    String? projectType,
  }) async {
    final r = await _get(
      _u(
        '/projects',
        <String, String>{
          if (projectType != null) 'project_type': projectType,
        },
      ),
    );
    final d = await _decode(r);
    if (d is List) return d.cast<Map<String, dynamic>>();
    if (d is Map && d['items'] is List) {
      return (d['items'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> body) async {
    final r = await _post(
      _u('/projects'),
      body: jsonEncode(body),
    );
    final d = await _decode(r);
    return (d as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getProject(String id) async {
    final r = await _get(_u('/projects/$id'));
    final d = await _decode(r);
    return (d as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateProject(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _patch(
      _u('/projects/$id'),
      body: jsonEncode(body),
    );
    final d = await _decode(r);
    return (d as Map).cast<String, dynamic>();
  }

  // ─── Design / layout / financials (project-scoped) ─────────────

  Future<Map<String, dynamic>> getProjectRoof(String projectId) async {
    final r = await _get(_u('/projects/$projectId/roof'));
    final d = await _decode(r);
    if (d is Map) return d.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getProjectLayout(String projectId) async {
    final r = await _get(_u('/projects/$projectId/layout'));
    final d = await _decode(r);
    if (d is Map) return d.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getProjectFinancials(String projectId) async {
    final r = await _get(_u('/projects/$projectId/financials'));
    final d = await _decode(r);
    if (d is Map) return d.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  Future<List<int>> getProjectReportPdf(String projectId) async {
    final r = await _get(_u('/projects/$projectId/report'));
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return r.bodyBytes;
    }
    throw ApiException(r.statusCode, r.body);
  }

  // ─── Wallet ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWallet() async {
    final r = await _get(_u('/wallet'));
    final d = await _decode(r);
    if (d is Map) return d.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateWallet(Map<String, dynamic> body) async {
    final r = await _put(
      _u('/wallet'),
      body: jsonEncode(body),
    );
    final d = await _decode(r);
    return (d as Map).cast<String, dynamic>();
  }

  // ─── Chat ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getProjectMessages(String projectId) async {
    final r = await _get(
      _u('/projects/$projectId/messages'),
    );
    final d = await _decode(r);
    if (d is List) return d.cast<Map<String, dynamic>>();
    if (d is Map && d['items'] is List) {
      return (d['items'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<Map<String, dynamic>> postProjectMessage(
    String projectId,
    Map<String, dynamic> body,
  ) async {
    final r = await _post(
      _u('/projects/$projectId/messages'),
      body: jsonEncode(body),
    );
    final d = await _decode(r);
    return (d as Map).cast<String, dynamic>();
  }

  void dispose() => _client.close();
}

Project projectFromApiMap(Map<String, dynamic> j) {
  final id = j['id']?.toString() ?? '';
  final address = (j['address'] ?? '').toString();
  final clientName = (j['clientName'] ??
          j['client_name'] ??
          j['homeowner_name'] ??
          '')
      .toString();
  final status = parseProjectStatusFromApi(j['status'] as String?) ??
      ProjectStatus.designing;
  final typeStr = (j['type'] ?? j['project_type'] ?? 'residential').toString();
  ProjectType type = ProjectType.residential;
  for (final v in ProjectType.values) {
    if (v.name == typeStr) {
      type = v;
      break;
    }
  }
  DateTime date = DateTime.now();
  final dateRaw = j['date'] ?? j['created_at'];
  if (dateRaw is String) {
    date = DateTime.tryParse(dateRaw) ?? date;
  }
  return Project(
    id: id,
    address: address,
    clientName: clientName.isEmpty ? '—' : clientName,
    status: status,
    type: type,
    date: date,
    systemSizeKw: (j['systemSizeKw'] ?? j['system_size_kw']) is num
        ? ((j['systemSizeKw'] ?? j['system_size_kw']) as num).toDouble()
        : null,
    panelCount: _readInt(j['panelCount'] ?? j['panel_count']),
    annualProductionKwh: (j['annualProductionKwh'] ?? j['annual_production_kwh'])
            is num
        ? ((j['annualProductionKwh'] ?? j['annual_production_kwh']) as num)
            .toDouble()
        : null,
    yearOneSavings: (j['yearOneSavings'] ?? j['year_one_savings']) is num
        ? ((j['yearOneSavings'] ?? j['year_one_savings']) as num).toDouble()
        : null,
  );
}

/// Builds a create-project body with snake_case keys expected by many APIs.
Map<String, dynamic> projectCreateBody({
  required String address,
  required String projectType,
  Map<String, dynamic>? customData,
  String? clientName,
}) {
  return <String, dynamic>{
    'address': address,
    'project_type': projectType,
    if (customData != null) 'custom_data': customData,
    if (clientName != null) 'client_name': clientName,
  };
}

ProjectStatus? parseProjectStatusFromApi(String? s) {
  if (s == null || s.isEmpty) return null;
  for (final v in ProjectStatus.values) {
    if (v.name == s) return v;
  }
  return null;
}

int? _readInt(dynamic v) {
  if (v is int) return v;
  return null;
}
