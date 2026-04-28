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
  try {
    final dynamic m = jsonDecode(body);
    if (m is Map<String, dynamic>) {
      final detail = m['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return detail.first.toString();
      }
      if (m['message'] != null) return m['message'].toString();
    }
  } catch (_) {}
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
  final user = json['user'];
  String? userId;
  String? orgId;
  String? role;
  String? fullName;
  String? email;
  String? companyName;
  if (user is Map<String, dynamic>) {
    userId = (user['id'] ?? user['user_id'])?.toString();
    orgId = (user['org_id'] ?? user['orgId'])?.toString();
    role = user['role']?.toString();
    fullName =
        (user['full_name'] ?? user['fullName'] ?? user['name'])?.toString();
    email = user['email']?.toString();
    companyName =
        (user['company_name'] ?? user['companyName'])?.toString();
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
      return parseAuthJson(map);
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
      return parseAuthJson(map);
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
      return parseAuthJson(map);
    }
    throw AuthApiException(r.statusCode, authErrorMessageFromBody(r.body));
  }

  void dispose() => _client.close();
}
