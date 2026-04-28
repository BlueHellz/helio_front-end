import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/api.dart';
import '../../services/auth_api.dart';
import '../app_state.dart';

const _kAccess = 'bl_access_token';
const _kRefresh = 'bl_refresh_token';
const _kOrgId = 'bl_org_id';
const _kUserId = 'bl_user_id';
const _kUserRole = 'bl_user_role';
const _kFullName = 'bl_full_name';
const _kCompanyName = 'bl_company_name';

@immutable
class AuthSession {
  const AuthSession({
    this.bearerToken,
    this.refreshToken,
    this.orgId,
    this.userId,
    this.userRole,
    this.fullName,
    this.companyName,
  });

  final String? bearerToken;
  final String? refreshToken;
  final String? orgId;
  final String? userId;
  final String? userRole;
  final String? fullName;
  final String? companyName;

  bool get isLoggedIn =>
      bearerToken != null && bearerToken!.trim().isNotEmpty;

  AuthSession copyWith({
    String? bearerToken,
    String? refreshToken,
    String? orgId,
    String? userId,
    String? userRole,
    String? fullName,
    String? companyName,
  }) {
    return AuthSession(
      bearerToken: bearerToken ?? this.bearerToken,
      refreshToken: refreshToken ?? this.refreshToken,
      orgId: orgId ?? this.orgId,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
    );
  }
}

/// Maps API role strings to app [UserRole].
UserRole userRoleFromApiString(String? role) {
  switch ((role ?? '').toLowerCase().trim()) {
    case 'homeowner':
      return UserRole.homeowner;
    case 'installer':
    case 'organization':
    case 'org':
      return UserRole.organization;
    case 'drone_operator':
    case 'droneoperator':
    case 'drone operator':
      return UserRole.droneOperator;
    default:
      return UserRole.homeowner;
  }
}

/// Maps [UserRole] to API `role` field for signup.
String apiRoleString(UserRole role) {
  switch (role) {
    case UserRole.homeowner:
      return 'homeowner';
    case UserRole.organization:
      return 'installer';
    case UserRole.droneOperator:
      return 'drone_operator';
    case UserRole.none:
      return 'homeowner';
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  final api = AuthApi();
  ref.onDispose(api.dispose);
  return api;
});

class SessionNotifier extends StateNotifier<AuthSession> {
  SessionNotifier(this._ref)
      : _storage = const FlutterSecureStorage(),
        super(const AuthSession());

  final Ref _ref;
  final FlutterSecureStorage _storage;

  AuthApi get _authApi => _ref.read(authApiProvider);

  Future<void> restoreFromStorage() async {
    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    if (access == null || access.isEmpty) {
      state = const AuthSession();
      return;
    }
    state = AuthSession(
      bearerToken: access,
      refreshToken: refresh,
      orgId: await _storage.read(key: _kOrgId),
      userId: await _storage.read(key: _kUserId),
      userRole: await _storage.read(key: _kUserRole),
      fullName: await _storage.read(key: _kFullName),
      companyName: await _storage.read(key: _kCompanyName),
    );
  }

  Future<void> _persist(AuthSession s) async {
    if (!s.isLoggedIn) {
      await _clearStorageOnly();
      return;
    }
    await _storage.write(key: _kAccess, value: s.bearerToken ?? '');
    await _storage.write(key: _kRefresh, value: s.refreshToken ?? '');
    await _storage.write(key: _kOrgId, value: s.orgId ?? '');
    await _storage.write(key: _kUserId, value: s.userId ?? '');
    await _storage.write(key: _kUserRole, value: s.userRole ?? '');
    await _storage.write(key: _kFullName, value: s.fullName ?? '');
    await _storage.write(key: _kCompanyName, value: s.companyName ?? '');
  }

  Future<void> _clearStorageOnly() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kOrgId);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUserRole);
    await _storage.delete(key: _kFullName);
    await _storage.delete(key: _kCompanyName);
  }

  /// Apply login/signup/refresh response and persist.
  Future<void> applyAuthResult(AuthResult r) async {
    final session = AuthSession(
      bearerToken: r.accessToken,
      refreshToken: r.refreshToken,
      orgId: r.orgId,
      userId: r.userId,
      userRole: r.role,
      fullName: r.fullName,
      companyName: r.companyName,
    );
    state = session;
    await _persist(session);
  }

  /// Replaces session (persists when [persist] is true).
  void replaceSession({
    String? bearerToken,
    String? refreshToken,
    String? orgId,
    String? userId,
    String? userRole,
    String? fullName,
    String? companyName,
    bool persist = true,
  }) {
    final next = AuthSession(
      bearerToken: bearerToken,
      refreshToken: refreshToken,
      orgId: orgId,
      userId: userId,
      userRole: userRole,
      fullName: fullName,
      companyName: companyName,
    );
    state = next;
    if (persist) {
      unawaited(_persist(next));
    }
  }

  void setSession({String? bearerToken, String? orgId}) {
    state = state.copyWith(bearerToken: bearerToken, orgId: orgId);
    unawaited(_persist(state));
  }

  /// Refresh access token using stored refresh token. Returns true if successful.
  Future<bool> tryRefreshAccessToken() async {
    final refresh = state.refreshToken ?? await _storage.read(key: _kRefresh);
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final result = await _authApi.refresh(refreshToken: refresh);
      await applyAuthResult(result);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clear() async {
    state = const AuthSession();
    await _clearStorageOnly();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, AuthSession>((ref) {
  return SessionNotifier(ref);
});

final apiProvider = Provider<BlackLightApi>((ref) {
  return BlackLightApi(
    readHeaders: () {
      final s = ref.read(sessionProvider);
      final h = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final t = s.bearerToken?.trim();
      if (t != null && t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
      return h;
    },
    tryRefresh: () => ref.read(sessionProvider.notifier).tryRefreshAccessToken(),
  );
});
