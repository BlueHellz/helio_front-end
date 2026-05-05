import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../config.dart';

/// Public auth endpoints (no Bearer header).
class AuthApiException implements Exception {
  AuthApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'AuthApiException($statusCode): $message';
}

String authErrorMessageFromBody(String body) {
  if (body.trim().isEmpty) {
    return 'Something went wrong. Please try again.';
  }
  try {
    final dynamic m = jsonDecode(body);
    if (m is Map) {
      final map = Map<String, dynamic>.from(m);
      final detail = map['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      if (detail is Map) {
        final msg = detail['msg'] ?? detail['message'];
        if (msg != null) return msg.toString();
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return first.toString();
      }
      for (final key in ['message', 'error', 'title']) {
        final v = map[key];
        if (v is String && v.isNotEmpty) return v;
      }
    }
    if (m is String && m.isNotEmpty) return m;
  } catch (_) {
    final t = body.trim();
    if (t.length <= 280) return t;
    return '${t.substring(0, 280)}…';
  }
  return 'Something went wrong. Please try again.';
}

class AuthResult {
  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.orgId,
    this.role,
    this.fullName,
    this.email,
    this.companyName,
  });

  final String accessToken;
  final String refreshToken;
  final String? userId;
  final String? orgId;
  final String? role;
  final String? fullName;
  final String? email;
  final String? companyName;
}

/// Merges nested `data` / `result` / `tokens` shapes so [parseAuthJson] sees tokens + user at one level.
Map<String, dynamic> normalizeAuthResponseMap(Map<String, dynamic> raw) {
  final out = Map<String, dynamic>.from(raw);

  void mergeNested(String key) {
    final v = out[key];
    if (v is Map) {
      final inner = Map<String, dynamic>.from(v);
      for (final e in inner.entries) {
        final existing = out[e.key];
        final missing = existing == null ||
            (existing is String && existing.isEmpty);
        if (missing) {
          out[e.key] = e.value;
        }
      }
    }
  }

  mergeNested('data');
  mergeNested('result');

  final tokens = out['tokens'];
  if (tokens is Map) {
    final t = Map<String, dynamic>.from(tokens);
    out.putIfAbsent('access_token', () => t['access_token'] ?? t['accessToken']);
    out.putIfAbsent('refresh_token', () => t['refresh_token'] ?? t['refreshToken']);
  }

  return out;
}

String? readRoleFromMap(Map<String, dynamic> map) {
  dynamic r =
      map['role'] ?? map['user_role'] ?? map['userRole'] ?? map['type'];
  if (r is Map) {
    r = r['value'] ?? r['name'] ?? r['role'];
  }
  final s = r?.toString().trim();
  if (s == null || s.isEmpty) return null;
  return s;
}

AuthResult parseAuthJson(Map<String, dynamic> json) {
  final access = (json['access_token'] ??
          json['accessToken'] ??
          json['token'] ??
          '')
      .toString();
  final refresh =
      (json['refresh_token'] ?? json['refreshToken'] ?? '').toString();
  String? userId;
  String? orgId;
  String? role = readRoleFromMap(json);
  String? fullName;
  String? email;
  String? companyName;

  Map<String, dynamic>? userMap;
  final u = json['user'] ?? json['profile'];
  if (u is Map) {
    userMap = Map<String, dynamic>.from(u);
  } else {
    final d = json['data'];
    if (d is Map && d['user'] is Map) {
      userMap = Map<String, dynamic>.from(d['user'] as Map);
    }
  }

  if (userMap != null) {
    userId = (userMap['id'] ?? userMap['user_id'] ?? userMap['uuid'])?.toString();
    orgId = (userMap['org_id'] ??
            userMap['orgId'] ??
            userMap['organization_id'] ??
            userMap['organizationId'])
        ?.toString();
    role = readRoleFromMap(userMap) ?? role;
    fullName =
        (userMap['full_name'] ?? userMap['fullName'] ?? userMap['name'])
            ?.toString();
    email = userMap['email']?.toString();
    companyName =
        (userMap['company_name'] ?? userMap['companyName'])?.toString();
  }
  final r = role?.toLowerCase().trim();
  if ((companyName == null || companyName.isEmpty) &&
      (r == 'installer' || r == 'organization' || r == 'org')) {
    companyName = fullName;
  }
  return AuthResult(
    accessToken: access,
    refreshToken: refresh,
    userId: userId,
    orgId: orgId,
    role: role,
    fullName: fullName,
    email: email,
    companyName: companyName,
  );
}

class AuthApi {
  AuthApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? BlackLightConfig.apiBaseUrl;

  final http.Client _client;
  final String _base;

  Uri _auth(String path) => Uri.parse('$_base/api/v1/auth$path');

  Map<String, String> get _jsonHeaders => <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  void _ensureTokens(AuthResult r, int statusCode) {
    if (r.accessToken.trim().isEmpty) {
      throw AuthApiException(
        statusCode,
        'No access token in response. Check API JSON keys (access_token / user).',
      );
    }
  }

  AuthResult _parseAuthSuccessResponse(http.Response r) {
    if (r.body.isEmpty) {
      throw AuthApiException(r.statusCode, 'Empty response');
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(r.body);
    } catch (_) {
      throw AuthApiException(
        r.statusCode,
        authErrorMessageFromBody(r.body),
      );
    }
    if (decoded is! Map) {
      throw AuthApiException(r.statusCode, 'Invalid response format');
    }
    final map = normalizeAuthResponseMap(
      Map<String, dynamic>.from(decoded),
    );
    final result = parseAuthJson(map);
    _ensureTokens(result, r.statusCode);
    return result;
  }

  /// Merge profile/org from GET `/api/v1/auth/me` when available.
  /// Never throws; never replaces [current] with a result that dropped the access token.
  Future<AuthResult> enrichWithMe(AuthResult current) async {
    if (current.accessToken.isEmpty) return current;
    final uri = Uri.parse('$_base/api/v1/auth/me');
    try {
      final r = await _client.get(
        uri,
        headers: <String, String>{
          ..._jsonHeaders,
          'Authorization': 'Bearer ${current.accessToken}',
        },
      );
      if (r.statusCode >= 200 && r.statusCode < 300 && r.body.isNotEmpty) {
        final dynamic decoded = jsonDecode(r.body);
        if (decoded is! Map) {
          developer.log(
            'enrichWithMe: /api/v1/auth/me JSON was not an object',
            name: 'AuthApi',
          );
          return current;
        }
        final map = Map<String, dynamic>.from(decoded);
        final merged = parseAuthJson(<String, dynamic>{
          'access_token': current.accessToken,
          'refresh_token': current.refreshToken,
          'user': map['user'] ?? map,
        });
        if (merged.accessToken.trim().isEmpty) {
          developer.log(
            'enrichWithMe: merge dropped access token; keeping signup/login response',
            name: 'AuthApi',
          );
          return current;
        }
        return AuthResult(
          accessToken: merged.accessToken,
          refreshToken: merged.refreshToken.isNotEmpty
              ? merged.refreshToken
              : current.refreshToken,
          userId: merged.userId ?? current.userId,
          orgId: merged.orgId ?? current.orgId,
          role: merged.role ?? current.role,
          fullName: merged.fullName ?? current.fullName,
          email: merged.email ?? current.email,
          companyName: merged.companyName ?? current.companyName,
        );
      }
      developer.log(
        'enrichWithMe: /api/v1/auth/me HTTP ${r.statusCode}, using login/signup response',
        name: 'AuthApi',
      );
    } catch (e, st) {
      developer.log(
        'enrichWithMe: /api/v1/auth/me failed, using login/signup response',
        name: 'AuthApi',
        error: e,
        stackTrace: st,
      );
    }
    return current;
  }

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? companyName,
  }) async {
    final r = await _client.post(
      _auth('/signup'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        if (companyName != null && companyName.trim().isNotEmpty)
          'company_name': companyName.trim(),
      }),
    );
    // 200 OK or 201 Created — same JSON shape as login; no extra login call.
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseAuthSuccessResponse(r);
    }
    throw AuthApiException(r.statusCode, authErrorMessageFromBody(r.body));
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final r = await _client.post(
      _auth('/login'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
      }),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseAuthSuccessResponse(r);
    }
    throw AuthApiException(r.statusCode, authErrorMessageFromBody(r.body));
  }

  Future<AuthResult> refresh({required String refreshToken}) async {
    final r = await _client.post(
      _auth('/refresh'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'refresh_token': refreshToken,
      }),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseAuthSuccessResponse(r);
    }
    throw AuthApiException(r.statusCode, authErrorMessageFromBody(r.body));
  }

  void dispose() => _client.close();
}
