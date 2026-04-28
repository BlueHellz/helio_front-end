import 'dart:convert';

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
    if (m is Map<String, dynamic>) {
      final detail = m['detail'];
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
        final v = m[key];
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

AuthResult parseAuthJson(Map<String, dynamic> json) {
  final access =
      (json['access_token'] ?? json['accessToken'] ?? '').toString();
  final refresh =
      (json['refresh_token'] ?? json['refreshToken'] ?? '').toString();
  final user = json['user'] ?? json['data'];
  String? userId;
  String? orgId;
  String? role = json['role']?.toString();
  String? fullName;
  String? email;
  String? companyName;
  if (user is Map<String, dynamic>) {
    userId = (user['id'] ?? user['user_id'] ?? user['uuid'])?.toString();
    orgId = (user['org_id'] ??
            user['orgId'] ??
            user['organization_id'] ??
            user['organizationId'])
        ?.toString();
    role = user['role']?.toString() ?? role;
    fullName =
        (user['full_name'] ?? user['fullName'] ?? user['name'])?.toString();
    email = user['email']?.toString();
    companyName =
        (user['company_name'] ?? user['companyName'])?.toString();
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
      throw AuthApiException(statusCode, 'No access token returned.');
    }
  }

  /// Merge profile/org from GET `/api/v1/auth/me` or `/api/v1/me` when available.
  Future<AuthResult> enrichWithMe(AuthResult current) async {
    if (current.accessToken.isEmpty) return current;
    const paths = ['/api/v1/auth/me', '/api/v1/me'];
    for (final path in paths) {
      final uri = Uri.parse('$_base$path');
      try {
        final r = await _client.get(
          uri,
          headers: <String, String>{
            ..._jsonHeaders,
            'Authorization': 'Bearer ${current.accessToken}',
          },
        );
        if (r.statusCode >= 200 &&
            r.statusCode < 300 &&
            r.body.isNotEmpty) {
          final map = jsonDecode(r.body) as Map<String, dynamic>;
          final merged = parseAuthJson(<String, dynamic>{
            'access_token': current.accessToken,
            'refresh_token': current.refreshToken,
            'user': map['user'] ?? map,
          });
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
      } catch (_) {
        continue;
      }
    }
    return current;
  }

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final r = await _client.post(
      _auth('/signup'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      }),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) {
        throw AuthApiException(r.statusCode, 'Empty response');
      }
      final map = jsonDecode(r.body) as Map<String, dynamic>;
      final result = parseAuthJson(map);
      _ensureTokens(result, r.statusCode);
      return result;
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
      if (r.body.isEmpty) {
        throw AuthApiException(r.statusCode, 'Empty response');
      }
      final map = jsonDecode(r.body) as Map<String, dynamic>;
      final result = parseAuthJson(map);
      _ensureTokens(result, r.statusCode);
      return result;
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
      if (r.body.isEmpty) {
        throw AuthApiException(r.statusCode, 'Empty response');
      }
      final map = jsonDecode(r.body) as Map<String, dynamic>;
      final result = parseAuthJson(map);
      _ensureTokens(result, r.statusCode);
      return result;
    }
    throw AuthApiException(r.statusCode, authErrorMessageFromBody(r.body));
  }

  void dispose() => _client.close();
}
